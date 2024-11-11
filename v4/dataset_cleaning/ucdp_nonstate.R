library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_nonstate <- read_datasets("ucdp_nonstate", db, original = TRUE)

#Use function to clean column names
names(ucdp_nonstate) <- clean_column_names(names(ucdp_nonstate))

# Duplicate checks
no_duplicates(ucdp_nonstate, c("dyad_id", "year"))
no_duplicates(ucdp_nonstate, c("conflict_id", "year"))

#Duplicate columns for unit tables
# conflict_year
ucdp_nonstate$u_ucdp_conflict_year_conflict_id <- 
  ucdp_nonstate$conflict_id

ucdp_nonstate$u_ucdp_conflict_year_year <- 
  ucdp_nonstate$year

# Include location column for selective download interface
ucdp_nonstate$u_ucdp_conflict_year_location <- 
  ucdp_nonstate$location

# change date variables to only class Date (instead of IDate and Date)
ucdp_nonstate$start_date <- 
  as.Date(ucdp_nonstate$start_date) 

ucdp_nonstate$start_date2 <- 
  as.Date(ucdp_nonstate$start_date2)

ucdp_nonstate$ep_end_date <- 
  as.Date(ucdp_nonstate$ep_end_date)

# Save
write_dataset(ucdp_nonstate, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_nonstate_cleaned.rds"),
           tag = "ucdp_nonstate",
           overwrite = TRUE)