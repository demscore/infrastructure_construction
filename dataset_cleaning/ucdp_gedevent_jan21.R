library(dplyr)
library(demutils)
 
db <- pg_connect()

ucdp_gedevent_jan21 <- read_datasets("ucdp_gedevent_jan21", db, original = TRUE)


# Clean column names
names(ucdp_gedevent_jan21) <- clean_column_names(names(ucdp_gedevent_jan21))

# Create unit columns
ucdp_gedevent_jan21$u_ucdp_gedid_jan21_id <- 
  ucdp_gedevent_jan21$id

ucdp_gedevent_jan21$date_start <- 
  as.Date(ucdp_gedevent_jan21$date_start)

ucdp_gedevent_jan21$date_end <- 
  as.Date(ucdp_gedevent_jan21$date_end)

ucdp_gedevent_jan21$u_ucdp_gedid_jan21_country <- 
  ucdp_gedevent_jan21$country

ucdp_gedevent_jan21$u_ucdp_gedid_jan21_year <- 
  as.integer(ucdp_gedevent_jan21$year)

ucdp_gedevent_jan21$u_ucdp_gedid_jan21_dyad_new_id <- 
  as.integer(ucdp_gedevent_jan21$dyad_new_id)

ucdp_gedevent_jan21$u_ucdp_gedid_jan21_conflict_new_id <- 
  as.integer(ucdp_gedevent_jan21$conflict_new_id)

ucdp_gedevent_jan21$u_ucdp_gedid_jan21_side_a_new_id <- 
  as.integer(ucdp_gedevent_jan21$side_a_new_id)

ucdp_gedevent_jan21$u_ucdp_gedid_jan21_side_b_new_id <- 
  as.integer(ucdp_gedevent_jan21$side_b_new_id)

# Check for duplicates in column names
no_duplicate_names(ucdp_gedevent_jan21)


write_dataset(ucdp_gedevent_jan21, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_gedevent_jan21_cleaned.rds"),
           tag = "ucdp_gedevent_jan21",
           overwrite = TRUE)