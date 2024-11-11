#!/usr/bin/env Rscript

# Load libraries
library(dplyr)
library(demutils)
library(vpipe)

# Connect to database
db <- pg_connect()

# Download database tables
project_aggregations <- tbl(db, "project_aggregations") %>% collect(n = Inf)
unit_trans <- tbl(db, "unit_trans") %>% collect(n = Inf)
variables <- tbl(db, "variables") %>% collect(n = Inf) %>% filter(active)
datasets <- tbl(db, "datasets") %>% collect(n = Inf)

# Filter and sort database tables
unit_trans %<>% filter(!is.na(finish))
datasets %<>%
	filter(grepl(Sys.getenv("DATASET_VERSION"), demscore_release)) %>%
	filter(!is.na(secondary_units)) %>%
	arrange(tag)

# Calculate translation distance for unit_trans table
unit_trans$distance <- 
	lapply(unit_trans$path, function(v) {
		strsplit(v, split = ",") %>% unlist %>% length
	}) %>% unlist

# Get global variables from pipeline tasks table
# Example task_id for vdem_cy: 272
get_globals()

# Subset datasets based on current dataset
datasets %<>% filter(tag == Sys.getenv("VPIPE_TASK_NAME")) 
#stopifnot(nrow(datasets) == 1L)
stopifnot(nrow(datasets) <= 1L)
ds <- datasets
if(nrow(ds) == 0L){
  stop ("There are no translations for this dataset yet.")
  } else {
  info("Starting with dataset " %^% ds$tag)
}



# Find primary units for this dataset and subset unit_trans
# See column start in unit_trans table
primary_units <- ds$primary_units %>% strsplit(., split = ",") %>% unlist
utrans <- unit_trans %>% filter(start %in% primary_units)
if (nrow(utrans) == 0L) {
	info("No translations for these primary units in unit_trans!: " %^% primary_units)
	return(NULL)
}

# Sort utrans table based on distance
utrans %<>% arrange(distance)

# Loop over unit translations (utrans rows)
for (i in 1:nrow(utrans)) {
	# i <- 6
	# Subset ith row
	utranssub <- utrans[i, , drop = FALSE]
	info("utrans row: " %^% i)

	# Get unit translation function
	translation_functions <- utranssub$path %>% 
		strsplit(., split = ",") %>% 
		unlist

	# Get latest function for doing the translation
	# If we are at distance level 2 then distance level 1 was already calculated
	# because utrans is sorted by distance level (etc.)!
	current_function <- translation_functions[length(translation_functions)]

	# Get the current output unit
	if (length(translation_functions) == 1L) {
		current_output_unit <- utranssub$start
	} else {
		current_output_unit <- 
			translation_functions[length(translation_functions) - 1] %>%
			gsub("^to_", "", .)
	}
			 
	info("Dataset: " %^% ds$tag %^% 
		 "; Unit translation from " %^% current_output_unit %^%
		 " to " %^% utranssub$finish %^% " using: " %^% 
		 current_function)

	# Load data from starting units for dataset
	df <- read_unit_data(current_output_unit, ds$tag, variables, datasets,
		msg = FALSE)

	# Run translation function
	fu <- get(current_function)
	outdf <- fu(df)

	# Remove unit columns 
	# We do not want to write them, since we have them in the 
	# unit tables.
	outdf %<>% select(-matches("^u_"))

  	stopifnot(ncol(outdf) > 0)
  	unit_table <- read_unit_table(current_function %>% gsub("^to_", "", .))
  
  	stopifnot(`output from translation function has different number of rows than end unit table` = 
            nrow(outdf) == nrow(unit_table))
  
  	stopifnot(gsub("^to_", "", current_function) == utranssub$finish)
  
	
		# Write files one per variable in target unit_data directory
	Map(function(v, nn) {
		subdf <- data.frame(v)
		names(subdf) <- get_variable_tag(nn, variables)
		class(subdf) <- c(
			utranssub$start, 
			get_dataset_tag(nn, variables, datasets), 
			"data.frame")
		write_file(subdf, file.path(Sys.getenv("ROOT_DIR"), 
			   	   "unit_data", utranssub$finish, paste0(nn, ".rds")),
					msg = FALSE, dir_create = TRUE)
	}, v = outdf, nn = names(outdf)) %>% invisible

# End loop over utrans rows
}
