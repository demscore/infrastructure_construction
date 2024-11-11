library(dplyr)
library(demutils)

DIR <- file.path(Sys.getenv('ROOT_DIR'), "unit_data")

db <- pg_connect()

# ------------------------------------------------------------------------------
# This script generates a dataframe counting the files in each unit directory.
# It also does some additional checks on all unit data, very useful to see where 
# things are going wrong!!
# ------------------------------------------------------------------------------

projects <- DBI::dbGetQuery(db, "SELECT * FROM projects WHERE active IS TRUE;")
datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;")
cb_section <- DBI::dbGetQuery(db, "SELECT * FROM cb_section;")
units <- DBI::dbGetQuery(db, "SELECT * FROM units WHERE active IS TRUE;")
variables <- DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;")
# active TRUE; cb_show TRUE for download interface and codebook.
methodology <- DBI::dbGetQuery(db, "SELECT * FROM methodology WHERE show IS TRUE;")

# Selectable variables are these minus those that disappear.
# New variables should always already exist in variables table!
variables %<>% filter(active)

# Sort and remove non-desired combinations
methodology %<>% 
	arrange(dataset_tag, unit_tag) %>%
	filter(show)



# Which ones disappear (per output unit)?
df_from_files <- lapply(1:nrow(methodology), function(i){
  # i <- 409
  
	meth <- methodology[i, ]
	print(i)
	vars <- variables %>% 
		arrange(variable_id) %>%
		filter(dataset_id %in% c(meth$dataset_id)) %$% tag_long

	ll <- file.path(DIR, meth$unit_tag, paste0(vars, ".rds"))
	# Remove those that do not have result
	vars <- vars[file.exists(ll)]
	
	if (length(vars) == 0) {
		print(paste0("No variables for unit: ", meth$unit_tag, ":: dataset ::", meth$dataset_tag))
		return(NULL)
	}

	df <- read_unit_data(
		meth$unit_tag, 
		meth$dataset_tag,
		variables,
		datasets, 
		msg = FALSE)
	any_not_na <- apply(df, 1, function(x) any(!is.na(x)))
	unit_df <- read_unit_table(meth$unit_tag)

	# This needs to be checked again
	mixed_df <- bind_cols(unit_df, df)
	country_col <- units %>% filter(unit_tag == meth$unit_tag) %$% country_col
	year_col <- units %>% filter(unit_tag == meth$unit_tag) %$% year_col

	outdf <- 
		data.frame(
			unit_tag = meth$unit_tag,
			dataset_tag = meth$dataset_tag,
			n_obs = sum(!is.na(df)))
	if (!is.na(country_col)) {
		outdf$n_countries <- mixed_df %>% filter(any_not_na) %>% 
			{.[[country_col]]} %>% na.omit %>% unique %>% length
	}

	if (!is.na(year_col)) {
		outdf$n_years <- mixed_df %>% filter(any_not_na) %>% 
			{.[[year_col]]} %>% na.omit %>% unique %>% length
	}

	return(outdf)

}) %>% bind_rows

df_from_files <- read_file(file.path(Sys.getenv("ROOT_DIR"), "checks/ds_to_units.rds"))



# What combinations exist in variables table but not in cb_section table?
df_from_files %>%
	arrange(dataset_tag, unit_tag) %>%
	left_join(select(methodology, unit_tag, dataset_tag, ordering),
		by = c("unit_tag", "dataset_tag")) %>%
	arrange(dataset_tag, ordering, unit_tag) %>%
	write_file("~/unit_data_checks.rds")

df_from_files %>% 
	arrange(dataset_tag, unit_tag) %>%
	left_join(select(methodology, unit_tag, dataset_tag, ordering),
		by = c("unit_tag", "dataset_tag")) %>%
	arrange(dataset_tag, ordering, unit_tag) %>%
	view
