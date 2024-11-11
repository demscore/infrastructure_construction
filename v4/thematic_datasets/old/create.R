library(dplyr)
library(demutils)

# Connect to database and load relevant reference tables------------------------
db <- pg_connect()

thematic_datasets<- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets;")
thematic_datasets_variables <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets_variables;")

###=============================================================================
# Choose table and unit_directory from which we want to create the thematic 
# dataset. That is usually u_demscore_country_year.
###=============================================================================

unit <- "u_complab_country_year"

unit_table <- read_unit_table(unit) 

DIR <- file.path(Sys.getenv("ROOT_DIR"), paste0("unit_data/", unit))

###=============================================================================
# Define function. The function takes as input the theme from the 
# thematic_datasets table as a character string. 
# The corresponding thematic_dataset_ids in the if else statement come from the 
# same table.
###=============================================================================

create_thematic_dataset <- function(theme) {
  
  #theme <- "environment"
  
  if (theme == "gender") {
    thematic_datasets_variables %<>% filter(thematic_dataset_id == 1)
  } else if (theme == "migration") {
    thematic_datasets_variables %<>% filter(thematic_dataset_id == 3)
  } else if (theme == "environment") {
    thematic_datasets_variables %<>% filter(thematic_dataset_id == 4)
  } else if (theme == "parties_and_elections") {
    thematic_datasets_variables %<>% filter(thematic_dataset_id == 5)
  } else {
    stop("Invalid theme input. Please provide an existing theme")
  }
  
  variable_names <- c(thematic_datasets_variables$tag_long)
  
  # Get all files in the directory
  all_files <- list.files(DIR)
  
  # Filter out .rds files that match variable names from thematic_datasets_variables
  rds_files <- all_files[all_files %in% paste0(variable_names, ".rds")]
  
  # Loop through each .rds file and read it into the list
  rds_data <- list()
  
  for (i in 1:length(rds_files)) {
    rds_data[[i]] <- read_file(file.path(DIR, rds_files[i]))
  }
  
  # Combine variables into a data.frame and add unit identifiers
  combined <- do.call(cbind, rds_data)
  
  thematic_dataset <- bind_cols(unit_table, combined)
  
  write_file(thematic_dataset, 
             file.path(Sys.getenv("ROOT_DIR"), "themes", paste0("thematic_dataset_", theme, ".csv")),
                       overwrite = TRUE)
  
}

df <- create_thematic_dataset("environment")
