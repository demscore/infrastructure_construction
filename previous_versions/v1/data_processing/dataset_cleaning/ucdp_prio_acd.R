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