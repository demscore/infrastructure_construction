#!/usr/bin/env Rscript

# Load libraries
library(dplyr)
library(demutils)
library(vpipe)

# Connect to database
db <- pg_connect()

# Download database tables
unit_trans <- DBI::dbGetQuery(db, "SELECT * FROM unit_trans;") 
variables <- DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;") 
datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;") 

# Filter and sort database tables
unit_trans %<>% filter(!is.na(finish), active)
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
# You can insert a task_id in the console if you want to debug a specific task.
# Run the script until here and enter the task_id
get_globals()

# Subset datasets based on current dataset
datasets %<>% filter(tag == Sys.getenv("VPIPE_TASK_NAME")) 
stopifnot(nrow(datasets) <= 1L)
ds <- datasets
if(nrow(ds) == 0L){
  stop ("There are no translations for this dataset yet.")
  } else {
  info("Starting with dataset " %^% ds$tag)
  }

# Exclude translations without matches. Currently, these are translations for 
# QoG Country and QoG Region Year
#pg_send_query(db, " UPDATE unit_trans
#SET active = FALSE 
#WHERE trans_id IN(203, 158, 241, 256, 79, 371, 280, 81, 159, 121, 167, 148, 191, 195, 187, 199, 396, 381, 201, 189, 197, 220, 205, 383, 313, 319, 323, 329, 336, 425, 349, 290);")



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
	
	# Sometimes it is only variables from a single dataset from a primary output 
	# unit that do not result in matches in the end OU. Then we do not wan to 
	# exclude the whole unit translation, but only the specific dataset-to-unit
	# combination.
	if (ds$tag == "ucdp_nonstate" & utranssub$finish == "u_ucdp_pa_conflict_year"|
	    ds$tag == "qog_ei" & utranssub$finish == "u_qog_resp_eqi_21"|
	    ds$tag == "qog_ei" & utranssub$finish == "u_qog_region"|
	    ds$tag == "qog_eureg_long" & utranssub$finish == "u_qog_region"|
	    ds$tag == "qog_eureg_wide1" & utranssub$finish == "u_qog_region"|
	    ds$tag == "qog_eureg_wide2" & utranssub$finish == "u_qog_region"|
	    ds$tag == "qog_eureg_long" & utranssub$finish == "u_qog_resp_eqi_21"|
	    ds$tag == "qog_eureg_wide1" & utranssub$finish == "u_qog_resp_eqi_21"|
	    ds$tag == "qog_eureg_wide2" & utranssub$finish == "u_qog_resp_eqi_21"|
	    ds$tag == "qog_eureg_wide2" & utranssub$finish == "u_qog_resp_eqi_17"|
	    ds$tag == "qog_eqi_long" & utranssub$finish == "u_qog_municipality_year"|
	    ds$tag == "qog_eqi_long" & utranssub$finish == "u_qog_agency_year"|
	    ds$tag == "qog_eqi_long" & utranssub$finish == "u_qog_agency_inst"|
	    ds$tag == "qog_eqi_long" & utranssub$finish == "u_qog_resp_eqi_1013"|
	    ds$tag == "qog_eqi_long" & utranssub$finish == "u_hdata_country_year"|
	    ds$tag == "qog_eqi_long" & utranssub$finish == "u_hdata_minister_date"|
	    ds$tag == "qog_eqi_cati_long" & utranssub$finish == "u_ucdp_dyad_location_year"|
	    ds$tag == "complab_spin_cbd" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_spin_cbd" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_spin_cbd" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_spin_plb" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_spin_plb" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_spin_outwb" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_spin_outwb" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_spin_outwb" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_grace" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_grace" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_grace" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_spin_hben" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_spin_hben" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_spin_hben" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_spin_samip" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_spin_samip" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_spin_samip" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_migpol_impic_pr" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_migpol_impic_pr" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_migpol_impic_pr" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_migpol_impic_antidisc" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_migpol_impic_antidisc" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_migpol_impic_antidisc" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_migpol_impic_antidisc_rd" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_migpol_impic_antidisc_rd" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_migpol_impic_antidisc_rd" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_migpol_impic" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_migpol_impic" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_migpol_impic" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_migpol_mipex" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_migpol_mipex" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_migpol_mipex" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_spin_scip" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_spin_scip" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_spin_sied" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_spin_sied" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_spin_ssfd" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_spin_ssfd" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_spin_ssfd" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_spin_ssfd" & utranssub$finish == "u_ucdp_conflict_location_year"|
	    ds$tag == "complab_spin_ssfd" & utranssub$finish == "u_ucdp_dyad_location_year"|
	    ds$tag == "complab_migpol_imisem" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_migpol_imisem" & utranssub$finish == "u_hdata_country_year"|
	    ds$tag == "complab_migpol_imisem" & utranssub$finish == "u_hdata_minister_date"|
	    ds$tag == "complab_migpol_imisem" & utranssub$finish == "u_qog_agency_year"|
	    ds$tag == "complab_migpol_imisem" & utranssub$finish == "u_qog_municipality_year"|
	    ds$tag == "complab_migpol_imisem" & utranssub$finish == "u_qog_country"|
	    ds$tag == "complab_migpol_imisem" & utranssub$finish == "u_qog_region"|
	    ds$tag == "complab_migpol_imisem" & utranssub$finish == "u_complab_country_year_track"|
	    ds$tag == "complab_migpol_gc_cy" & utranssub$finish == "u_hdata_cabinet_date"|
	    ds$tag == "complab_migpol_gc_cy" & utranssub$finish == "u_qog_country"|
	    ds$tag == "ucdp_onesided" & utranssub$finish == "u_ucdp_pa_dyad_year"|
	    ds$tag == "ucdp_onesided" & utranssub$finish == "u_ucdp_dyad_location_year"|
	    ds$tag == "ucdp_nscia" & utranssub$finish == "u_ucdp_pa_dyad_year"|
	    ds$tag == "ucdp_nscia" & utranssub$finish == "u_ucdp_dyad_location_year"|
	    ds$tag == "ucdp_vpp" & utranssub$finish == "u_ucdp_pa_dyad_year"|
	    ds$tag == "ucdp_vpp" & utranssub$finish == "u_ucdp_dyad_location_year"|
	    ds$tag == "ucdp_vpp" & utranssub$finish == "u_ucdp_gedid"|
	    ds$tag == "ucdp_extsupp" & utranssub$finish == "u_ucdp_pa_dyad_year"|
	    ds$tag == "ucdp_extsupp" & utranssub$finish == "u_ucdp_dyad_location_year"|
	    ##
	    ds$tag == "hdata_conflict_cy" & utranssub$finish == "u_ucdp_orgv_country_year"|
	    ds$tag == "hdata_conflict_cy" & utranssub$finish == "u_ucdp_gedid"|
	    ds$tag == "hdata_conflict_cy" & utranssub$finish == "u_repdem_cabinet_date"|
	    ds$tag == "hdata_conflict_cy" & utranssub$finish == "u_repdem_cabinet_month"|
	    ds$tag == "hdata_conflict_cy" & utranssub$finish == "u_repdem_cabinet_quarter"|
	    ds$tag == "hdata_conflict_cy" & utranssub$finish == "u_repdem_cabinet_year"|
	    ds$tag == "hdata_conflict_cy" & utranssub$finish == "u_complab_country_year_track"|
	    ds$tag == "hdata_conflict_cy" & utranssub$finish == "u_vdem_party_date_coder"|
	    ds$tag == "hdata_conflict_cy" & utranssub$finish == "u_qog_region_year"|
	    ds$tag == "hdata_conflict_cy" & utranssub$finish == "u_qog_agency_year"|
	    ds$tag == "qog_eqi_cati_long" & utranssub$finish == "u_ucdp_conflict_location_year"
	    
	    )
	  {
	 
	  next
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

  	stopifnot("Outdf has 0 rows. This means there are no matches in the end output unit for this translation. 
  	Double check the function, and eventually set the translation in the unit_trans table to FALSE or add 
  	a specific dataset-to-unit-combination to the list above." = ncol(outdf) > 0)
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
