library(dplyr)
library(demutils)


db <- pg_connect()

ucdp_gedevent_feb21 <- read_datasets("ucdp_gedevent_feb21", db, original = TRUE)

# Clean column names
names(ucdp_gedevent_feb21) <- clean_column_names(names(ucdp_gedevent_feb21))

# Create unit columns
ucdp_gedevent_feb21$u_ucdp_gedid_feb21_id <- 
  ucdp_gedevent_feb21$id

ucdp_gedevent_feb21$u_ucdp_gedid_feb21_country <- 
  ucdp_gedevent_feb21$country

ucdp_gedevent_feb21$u_ucdp_gedid_feb21_year <- 
  as.integer(ucdp_gedevent_feb21$year)

ucdp_gedevent_feb21$u_ucdp_gedid_feb21_dyad_new_id <- 
  as.integer(ucdp_gedevent_feb21$dyad_new_id)

ucdp_gedevent_feb21$u_ucdp_gedid_feb21_conflict_new_id <- 
  as.integer(ucdp_gedevent_feb21$conflict_new_id)

ucdp_gedevent_feb21$u_ucdp_gedid_feb21_side_a_new_id <- 
  as.integer(ucdp_gedevent_feb21$side_a_new_id)

ucdp_gedevent_feb21$u_ucdp_gedid_feb21_side_b_new_id <- 
  as.integer(ucdp_gedevent_feb21$side_b_new_id)

ucdp_gedevent_feb21$date_start <- 
  as.Date(ucdp_gedevent_feb21$date_start)

ucdp_gedevent_feb21$date_end <- 
  as.Date(ucdp_gedevent_feb21$date_end)

# Check for duplicates in column names
no_duplicate_names(ucdp_gedevent_feb21)


write_dataset(ucdp_gedevent_feb21, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_gedevent_feb21_cleaned.rds"),
           tag = "ucdp_gedevent_feb21",
           overwrite = TRUE)