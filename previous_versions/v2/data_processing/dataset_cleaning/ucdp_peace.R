library(dplyr)
library(demutils)
db <- pg_connect()

ucdp_peace <- read_datasets("ucdp_peace", db, original = TRUE)

#Clean column names function
names(ucdp_peace) <- clean_column_names(names(ucdp_peace))

no_duplicates(ucdp_peace, "paid")

# Duplicate columns for unit tables
ucdp_peace$u_ucdp_pa_paid <- 
  ucdp_peace$paid

ucdp_peace$u_ucdp_pa_pa_name <- 
  ucdp_peace$pa_name

ucdp_peace$u_ucdp_pa_year <-
  ucdp_peace$year

# Columns for additional units to merge to dyad-, conflict-, and actor-year units
ucdp_peace$u_ucdp_pa_conflict_year_paid <- 
  ucdp_peace$paid

ucdp_peace$u_ucdp_pa_conflict_year_conflict_id <-
  ucdp_peace$conflict_id

ucdp_peace$u_ucdp_pa_conflict_year_year <-
  ucdp_peace$year

ucdp_peace$u_ucdp_pa_dyad_year_paid <- 
  ucdp_peace$paid

ucdp_peace$u_ucdp_pa_dyad_year_dyad_id <-
  ucdp_peace$dyad_id

ucdp_peace$u_ucdp_pa_dyad_year_year <-
  ucdp_peace$year

ucdp_peace$u_ucdp_pa_country_year_paid <- 
  ucdp_peace$paid

ucdp_peace$u_ucdp_pa_country_year_country <-
  ucdp_peace$gwno

ucdp_peace$u_ucdp_pa_country_year_year <-
  ucdp_peace$year

# Change class from character to Date
ucdp_peace$pa_date <- 
  as.Date(ucdp_peace$pa_date)

ucdp_peace$duration <- 
  as.Date(ucdp_peace$duration)

ucdp_peace$dateintervalstart_meta <- 
  as.Date(ucdp_peace$dateintervalstart_meta)

ucdp_peace$dateintervalend_meta <- 
  as.Date(ucdp_peace$dateintervalend_meta)

# Save
write_dataset(ucdp_peace, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_peace_cleaned.rds"),
           tag = "ucdp_peace",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(ucdp_peace,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/ucdp_peace_cleaned.dta"),
           overwrite = TRUE)

write_file(ucdp_peace,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/ucdp_peace_cleaned.csv"),
           overwrite = TRUE)