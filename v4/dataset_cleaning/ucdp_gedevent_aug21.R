library(dplyr)
library(demutils)


db <- pg_connect()

ucdp_gedevent_aug21 <- read_datasets("ucdp_gedevent_aug21", db, original = TRUE)

#Use function to clean column names
names(ucdp_gedevent_aug21) <- clean_column_names(names(ucdp_gedevent_aug21))

# Duplicate columns for unit tabels
ucdp_gedevent_aug21$u_ucdp_gedid_aug21_id <- ucdp_gedevent_aug21$id

# Fix datecols in deco before those can be added" When done delete line 36 and 37
#ucdp_gedevent_aug21$u_ucdp_gedid_aug21_date_start <- 
#  as.Date(ucdp_gedevent_aug21$date_start)

#ucdp_gedevent_aug21$u_ucdp_gedid_aug21_date_end <- 
#  as.Date(ucdp_gedevent_aug21$date_end)

ucdp_gedevent_aug21$u_ucdp_gedid_aug21_country <- 
  ucdp_gedevent_aug21$country

ucdp_gedevent_aug21$u_ucdp_gedid_aug21_year <- 
  as.integer(ucdp_gedevent_aug21$year)

ucdp_gedevent_aug21$u_ucdp_gedid_aug21_dyad_new_id <- 
  as.integer(ucdp_gedevent_aug21$dyad_new_id)

ucdp_gedevent_aug21$u_ucdp_gedid_aug21_conflict_new_id <- 
  as.integer(ucdp_gedevent_aug21$conflict_new_id)

ucdp_gedevent_aug21$u_ucdp_gedid_aug21_side_a_new_id <- 
  as.integer(ucdp_gedevent_aug21$side_a_new_id)

ucdp_gedevent_aug21$u_ucdp_gedid_aug21_side_b_new_id <- 
  as.integer(ucdp_gedevent_aug21$side_b_new_id)

# Check for duplicates in column names
no_duplicate_names(ucdp_gedevent_aug21)


write_dataset(ucdp_gedevent_aug21, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_gedevent_aug21_cleaned.rds"),
           tag = "ucdp_gedevent_aug21",
           overwrite = TRUE)
