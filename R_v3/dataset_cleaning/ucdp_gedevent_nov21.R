library(dplyr)
library(demutils)


db <- pg_connect()

ucdp_gedevent_nov21 <- read_datasets("ucdp_gedevent_nov21", db, original = TRUE)

# Clean column names
names(ucdp_gedevent_nov21) <- clean_column_names(names(ucdp_gedevent_nov21))

# Create unit columns
ucdp_gedevent_nov21$u_ucdp_gedid_nov21_id<- 
  ucdp_gedevent_nov21$id

ucdp_gedevent_nov21$u_ucdp_gedid_nov21_country <- 
  ucdp_gedevent_nov21$country

ucdp_gedevent_nov21$u_ucdp_gedid_nov21_year <- 
  as.integer(ucdp_gedevent_nov21$year)

ucdp_gedevent_nov21$u_ucdp_gedid_nov21_dyad_new_id <- 
  as.integer(ucdp_gedevent_nov21$dyad_new_id)

ucdp_gedevent_nov21$u_ucdp_gedid_nov21_conflict_new_id <- 
  as.integer(ucdp_gedevent_nov21$conflict_new_id)

ucdp_gedevent_nov21$u_ucdp_gedid_nov21_side_a_new_id <- 
  as.integer(ucdp_gedevent_nov21$side_a_new_id)

ucdp_gedevent_nov21$u_ucdp_gedid_nov21_side_b_new_id <- 
  as.integer(ucdp_gedevent_nov21$side_b_new_id)

# Check for duplicates in column names
no_duplicate_names(ucdp_gedevent_nov21)


write_dataset(ucdp_gedevent_nov21, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_gedevent_nov21_cleaned.rds"),
           tag = "ucdp_gedevent_nov21",
           overwrite = TRUE)