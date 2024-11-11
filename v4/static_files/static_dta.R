library(dplyr)
library(demutils)

db <- pg_connect()

DEMSCORE_RELEASE <- Sys.getenv("DEMSCORE_RELEASE")
datasets <- DBI::dbGetQuery(db, paste0("SELECT * FROM datasets WHERE demscore_release = '", DEMSCORE_RELEASE, "';"))

tags <- unique(datasets$tag)

for(t in tags){
  
  print(t)
  
  exclude <- c("ucdp_ged", "repdem_basic_potcoal", "repdem_wecee_potcoal", "vdem_coder_level")
  
  t_df <- read_datasets(t, db)
  
  if(t %in% exclude) {
    
    next
  
  } else if (grepl("^qog", t)) {
    # QoG dataset: save in the QoG folder
    file_path_dta <- paste0("~/data/demscore_next_release/datasets/qog/cleaned_datasets_dta/", t, "_cleaned.dta")
    
  } else if (grepl("^ucdp", t) || grepl("^views_pgm", t) || grepl("^views_cm", t)) {
    # UCDP dataset (including views): save in the UCDP folder
    file_path_dta <- paste0("~/data/demscore_next_release/datasets/ucdp/cleaned_datasets_dta/", t, "_cleaned.dta")
    
  } else if (grepl("^repdem", t)) {
    # RepDem dataset: save in the RepDem folder
    file_path_dta <- paste0("~/data/demscore_next_release/datasets/repdem/cleaned_datasets_dta/", t, "_cleaned.dta")
    
  } else if (grepl("^vdem", t)) {
    # VDem dataset: save in the VDem folder
    file_path_dta <- paste0("~/data/demscore_next_release/datasets/vdem/cleaned_datasets_dta/", t, "_cleaned.dta")
    
  } else if (grepl("^hdata", t)) {
    # HData dataset: save in the HData folder
    file_path_dta <- paste0("~/data/demscore_next_release/datasets/hdata/cleaned_datasets_dta/", t, "_cleaned.dta")
    
  } else if (grepl("^complab", t)) {
    # Complab: save in the Complab folder
    file_path_dta <- paste0("~/data/demscore_next_release/datasets/complab/cleaned_datasets_dta/", t, "_cleaned.dta")
    
  } else {
    next  
  }
  
  # Save the DTA file
  write_file(t_df, file_path_dta, overwrite = TRUE)
  
  if (file.exists(file_path_dta)) {
    status <- 'done'
  } else {
    status <- 'error'
  }
  
  print(paste("Dataset:", t, "Status:", status))
  
  query <- paste0("UPDATE tasks SET status = '", status, "' WHERE task_name = '", t, "' AND module_name = 'static_dta';")
  DBI::dbSendQuery(db, query)
}