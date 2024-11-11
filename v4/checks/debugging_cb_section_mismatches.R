library(demutils)
library(dplyr)

db <- pg_connect()

project = "vdem"

citations <- DBI::dbGetQuery(db, "SELECT * FROM citations;") 
datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;") 
variables <- DBI::dbGetQuery(db, "SELECT * FROM variables;") 
units <- DBI::dbGetQuery(db, "SELECT * FROM units;") 
unit_trans <- DBI::dbGetQuery(db, "SELECT * FROM unit_trans;") 
methodology <- DBI::dbGetQuery(db, "SELECT * FROM methodology;") 
cb_section <- DBI::dbGetQuery(db, "SELECT * FROM cb_section;") 
projects <- DBI::dbGetQuery(db, "SELECT * FROM projects WHERE active IS TRUE;") 
codebook <- DBI::dbGetQuery(db, "SELECT * FROM codebook;") 
unit_variables <- DBI::dbGetQuery(db, "SELECT * FROM unit_variables;") 
thematic_datasets <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets;") 
thematic_datasets_variables <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets_variables;")
merge_scores <- DBI::dbGetQuery(db, "SELECT * FROM merge_scores;") 
country_years <- DBI::dbGetQuery(db, "SELECT * FROM country_years;")
country_dates <- DBI::dbGetQuery(db, "SELECT * FROM country_dates;")
conflict_location_years <- DBI::dbGetQuery(db, "SELECT * FROM conflict_location_years;")
region_years <- DBI::dbGetQuery(db, "SELECT * FROM region_years;")
plot_regions <- DBI::dbGetQuery(db, "SELECT * FROM plot_regions;")

DIR <- file.path(ROOT_DIR, "unit_data")
# Selectable variables are these minus those that disappear.
# New variables should always already exist in variables table!
variables %<>% dplyr::filter(active, cb_show)

# Sort and remove non-desired combinations
methodology %<>% 
  dplyr::arrange(unit_tag, dataset_tag) %>%
  dplyr::filter(show)


# Which ones disappear (per output unit)?
df_from_files <- lapply(1:nrow(methodology), function(i, variables, DIR) {
  meth <- methodology[i, ]
  # print(i)
  vars <- variables %>% 
    dplyr::arrange(variable_id) %>%
    dplyr::filter(dataset_id %in% c(meth$dataset_id),
                  !grepl("^u_", tag_long)) %$% tag_long
  
  ll <- file.path(DIR, meth$unit_tag, paste0(vars, ".rds"))
  # Remove those that do not have result
  vars <- vars[file.exists(ll)]
  
  if (length(vars) == 0) {
    print(paste0("No variables for unit: ", meth$unit_tag, ":: dataset ::", meth$dataset_tag))
    return(NULL)
  }
  
  data.frame(
    unit_tag = meth$unit_tag,
    dataset_tag = meth$dataset_tag,
    tag_long = vars)
}, variables = variables, DIR = DIR) %>% dplyr::bind_rows()

# Check unique cb_sections
check_rows <- 
  cb_section %>%
  dplyr::group_by(dataset_tag, cb_section_tag) %>%
  dplyr::filter(dplyr::n() > 1)  %>%
  dplyr::arrange(dataset_tag, cb_section_tag)
stopifnot(nrow(check_rows) == 0L)

outdf <-
  df_from_files %>%
  # Add variable names and cb_sections
  dplyr::left_join(dplyr::select(variables, tag_long, variable_name = name, tag, cb_section), 
                   by = c("tag_long")) %>%
  # Add codebook section identifiers and names
  dplyr::left_join(dplyr::select(cb_section, cb_section_tag, dataset_tag, cb_section_name),
                   by = c("dataset_tag", "cb_section" = "cb_section_tag")) %>%
  # Add dataset names
  dplyr::left_join(dplyr::select(datasets, dataset_tag = tag, dataset_name = name),
                   by = c("dataset_tag")) %>%
  # Add unit names
  dplyr::left_join(dplyr::select(units, unit_tag, unit_name),
                   by = c("unit_tag")) %>%
  dplyr::mutate(select_id = 1:nrow(.)) %>%
  dplyr::select(select_id, unit_tag, unit_name, dataset_tag, dataset_name, cb_section, cb_section_name,
                tag, tag_long, variable_name)

# Last checks!
stopifnot(!is.na(outdf$unit_name))
stopifnot(!is.na(outdf$dataset_name))
stopifnot(!is.na(outdf$cb_section))
stopifnot(!is.na(outdf$cb_section_name))
stopifnot(!is.na(outdf$variable_name))

outdf %<>% filter(is.na(cb_section_name)) %>% arrange(cb_section)
