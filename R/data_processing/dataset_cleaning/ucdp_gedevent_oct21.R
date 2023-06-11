library(dplyr)
library(demutils)


db <- pg_connect()

ucdp_gedevent_oct21 <- read_datasets("ucdp_gedevent_oct21", db, original = TRUE)


# Clean column names
names(ucdp_gedevent_oct21) <- clean_column_names(names(ucdp_gedevent_oct21))

# Create unit columns
ucdp_gedevent_oct21$u_ucdp_gedid_oct21_id <- 
  ucdp_gedevent_oct21$id

ucdp_gedevent_oct21$u_ucdp_gedid_oct21_country <- 
  ucdp_gedevent_oct21$country

ucdp_gedevent_oct21$u_ucdp_gedid_oct21_year <- 
  as.integer(ucdp_gedevent_oct21$year)

ucdp_gedevent_oct21$u_ucdp_gedid_oct21_dyad_new_id <- 
  as.integer(ucdp_gedevent_oct21$dyad_new_id)

ucdp_gedevent_oct21$u_ucdp_gedid_oct21_conflict_new_id <- 
  as.integer(ucdp_gedevent_oct21$conflict_new_id)

ucdp_gedevent_oct21$u_ucdp_gedid_oct21_side_a_new_id <- 
  as.integer(ucdp_gedevent_oct21$side_a_new_id)

ucdp_gedevent_oct21$u_ucdp_gedid_oct21_side_b_new_id <- 
  as.integer(ucdp_gedevent_oct21$side_b_new_id)

# Check for duplicates in column names
no_duplicate_names(ucdp_gedevent_oct21)


write_dataset(ucdp_gedevent_oct21, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_gedevent_oct21_cleaned.rds"),
           tag = "ucdp_gedevent_oct21",
           overwrite = TRUE)