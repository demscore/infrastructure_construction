#!/usr/bin/env Rscript
# Generate all data files from primary data!
# As one file per variable 



library(dplyr)
library(demutils)
library(vpipe)

# Connect to database and download tables
db <- pg_connect()
datasets <- load_datasets(db) %>% 
	filter(grepl(Sys.getenv("DATASET_VERSION"), 
		demscore_release, fixed = TRUE)) %>% 
	arrange(dataset_id)

# Load variables table
variables <- tbl(db, "variables") %>% collect(n = Inf) %>% filter(active)

# Set environment variables e.g. task_id 164
get_globals()

# Subset datasets based on current task
datasets %<>% filter(tag == Sys.getenv("VPIPE_TASK_NAME")) 
stopifnot(nrow(datasets) == 1L)


# Read dataset
info(datasets$tag)
ds <- read_datasets(datasets$tag, db, msg = FALSE)


# Determine primary units
primary_units <- 
	datasets %>% 
	pull(primary_units) %>% 
	strsplit(",") %>% 
	unlist
	
if (any(is.na(primary_units))) {
	stop("No primary units for dataset: " %^% subtag)
}

# These columns are only identifiers and do not contain data
all_unit_identifiers <- 
	lapply(primary_units, function(v) {
		names(read_unit_table(v))
	}) %>% unlist %>% unique %>% sort

# Loop over primary units
lapply(primary_units, function(v) {
	# v <- primary_units[1]
	info(v)
	utable <- read_unit_table(v)

	stopifnot(`There are duplicate rows in the unit table:` = 
			no_duplicates(utable, names(utable)))		
	id_names <- names(utable)
	stopifnot(`The columns do not contain the unit identifier: ` = 
		grepl(v, id_names))
	var_names <- names(ds)[!names(ds) %in% all_unit_identifiers]
	
	# Check if all variable names from the chosen dataset are in the variables table
	variables %<>% filter(dataset_id == datasets$dataset_id)
	stopifnot(var_names %in% variables$tag)
	
	diff <- setdiff(var_names, variables$tag)
	setdiff(variables$tag, var_names)

	# Remove rows with missing values in identifier columns from dataset
	# bool defines rows where both identifier columns are not NA.
	# Why is this necessary???
	bool <- ds %>% select(all_of(id_names)) %>%
		{!is.na(.)} %>% apply(., 1, all) # !anyNA() might be better
	subds <- ds[bool, ]

	 #subds %>% select(all_of(id_names)) %>%
      #duplicates(., id_names) %>%
	    #view
  
	# Make exception for ucdp_dyad_year unit to only merge on two identifiers, as there 
	# are inconsistencies in spelling across datasets in the dyad_year unit
	if(v == "u_ucdp_dyad_year") {
	  df <- left_join_dem(utable, select(subds, all_of(c(id_names, var_names))),
	                      by = c("u_ucdp_dyad_year_dyad_id", "u_ucdp_dyad_year_year"))
	}else {
	  df <- left_join_dem(utable, select(subds, all_of(c(id_names, var_names))),
	                      by = id_names)
	}  
	
	class(df) <- c(v, class(subds)[1], "data.frame")

	# Loop over variables and save one file per variable
	lapply(var_names, function(f) {
			write_file(
				select(df, all_of(f)), 
				file.path(Sys.getenv("ROOT_DIR"), 
					"unit_data", v, datasets$tag %^% "_" %^% f %^% ".rds"), 
				msg = FALSE, dir_create = TRUE)
	}) %>% invisible
}) %>% invisible
