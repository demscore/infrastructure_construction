library(dplyr)
library(demutils)
db <- pg_connect()

ucdp_prio_acd <- read_datasets("ucdp_prio_acd", db, original = TRUE)

#Use function to clean column names
names(ucdp_prio_acd) <- clean_column_names(names(ucdp_prio_acd))

# Check for duplicates
no_duplicates(ucdp_prio_acd, c("conflict_id", "year"))

#Duplicate columns for unit tables
ucdp_prio_acd$u_ucdp_conflict_year_conflict_id <- 
  ucdp_prio_acd$conflict_id

ucdp_prio_acd$u_ucdp_conflict_year_year <- 
  ucdp_prio_acd$year

#Duplicate columns for unit tables
ucdp_prio_acd$u_ucdp_conflict_location_year_conflict_id <- 
  ucdp_prio_acd$conflict_id

ucdp_prio_acd$u_ucdp_conflict_location_year_year <- 
  ucdp_prio_acd$year

ucdp_prio_acd$u_ucdp_conflict_location_year_location <- 
  ucdp_prio_acd$location

ucdp_prio_acd$u_ucdp_conflict_location_year_gwno_loc <- 
  ucdp_prio_acd$gwno_loc

# Include location column for selective download interface
ucdp_prio_acd$u_ucdp_conflict_year_location <- 
  ucdp_prio_acd$location

# change date variables to only class Date (instead of IDate and Date)
ucdp_prio_acd$start_date <- 
  as.Date(ucdp_prio_acd$start_date) 

ucdp_prio_acd$start_date2 <- 
  as.Date(ucdp_prio_acd$start_date2)

ucdp_prio_acd$ep_end_date <- 
  as.Date(ucdp_prio_acd$ep_end_date)


# Save 
write_dataset(ucdp_prio_acd, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_prio_acd_cleaned.rds"),
           tag = "ucdp_prio_acd",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(ucdp_prio_acd,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/ucdp_prio_acd_cleaned.dta"),
           overwrite = TRUE)

write_file(ucdp_prio_acd,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/ucdp_prio_acd_cleaned.csv"),
           overwrite = TRUE)