library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_gedevent_apr22 <- read_datasets("ucdp_gedevent_apr22", db, original = TRUE)

# Clean column names
names(ucdp_gedevent_apr22) <- clean_column_names(names(ucdp_gedevent_apr22))

# Create unit columns
ucdp_gedevent_apr22$u_ucdp_gedid_apr22_id <- 
  ucdp_gedevent_apr22$id

ucdp_gedevent_apr22$u_ucdp_gedid_apr22_country <- 
  ucdp_gedevent_apr22$country

ucdp_gedevent_apr22$u_ucdp_gedid_apr22_year <- 
  as.integer(ucdp_gedevent_apr22$year)

ucdp_gedevent_apr22$u_ucdp_gedid_apr22_dyad_new_id <- 
  as.integer(ucdp_gedevent_apr22$dyad_new_id)

ucdp_gedevent_apr22$u_ucdp_gedid_apr22_conflict_new_id <- 
  as.integer(ucdp_gedevent_apr22$conflict_new_id)

ucdp_gedevent_apr22$u_ucdp_gedid_apr22_side_a_new_id <- 
  as.integer(ucdp_gedevent_apr22$side_a_new_id)

ucdp_gedevent_apr22$u_ucdp_gedid_apr22_side_b_new_id <- 
  as.integer(ucdp_gedevent_apr22$side_b_new_id)

# Check for duplicates in column names
no_duplicate_names(ucdp_gedevent_apr22)

# change date variables to only class Date (instead of IDate and Date)
ucdp_gedevent_apr22$date_start <- 
  as.Date(ucdp_gedevent_apr22$date_start) 

ucdp_gedevent_apr22$date_end <- 
  as.Date(ucdp_gedevent_apr22$date_end)


write_dataset(ucdp_gedevent_apr22, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_gedevent_apr22_cleaned.rds"),
              tag = "ucdp_gedevent_apr22",
              overwrite = TRUE)