# Load libraries
library(dplyr)
library(demutils)
db <- pg_connect()

ucdp_term_conflict <- read_datasets("ucdp_term_conflict", db, original = TRUE)


#Use function to clean column names
names(ucdp_term_conflict) <- clean_column_names(names(ucdp_term_conflict))

no_duplicates(ucdp_term_conflict, c("conflictep_id", "year"))
no_duplicates(ucdp_term_conflict, c("conflict_id", "year"))

#Duplicate columns for unit tables
ucdp_term_conflict$u_ucdp_conflict_year_conflict_id <- 
  ucdp_term_conflict$conflict_id

ucdp_term_conflict$u_ucdp_conflict_year_year <- 
  ucdp_term_conflict$year

# Save 
write_dataset(ucdp_term_conflict, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_term_conflict_cleaned.rds"),
           tag = "ucdp_term_conflict",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(ucdp_term_conflict,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/ucdp_term_conflict_cleaned.dta"),
           overwrite = TRUE)

write_file(ucdp_term_conflict,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/ucdp_term_conflict_cleaned.csv"),
           overwrite = TRUE)
