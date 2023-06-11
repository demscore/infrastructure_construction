library(dplyr)
library(demutils)

db <- pg_connect()


ucdp_gedevent_dec21 <- read_datasets("ucdp_gedevent_dec21", db)


# Clean column names
names(ucdp_gedevent_dec21) <- clean_column_names(names(ucdp_gedevent_dec21))

# Create unit columns
ucdp_gedevent_dec21$u_ucdp_gedid_dec21_id <- 
  ucdp_gedevent_dec21$id

ucdp_gedevent_dec21$u_ucdp_gedid_dec21_country <- 
  ucdp_gedevent_dec21$country

ucdp_gedevent_dec21$u_ucdp_gedid_dec21_year <- 
  as.integer(ucdp_gedevent_dec21$year)

ucdp_gedevent_dec21$u_ucdp_gedid_dec21_dyad_new_id <- 
  as.integer(ucdp_gedevent_dec21$dyad_new_id)

ucdp_gedevent_dec21$u_ucdp_gedid_dec21_conflict_new_id <- 
  as.integer(ucdp_gedevent_dec21$conflict_new_id)

ucdp_gedevent_dec21$u_ucdp_gedid_dec21_side_a_new_id <- 
  as.integer(ucdp_gedevent_dec21$side_a_new_id)

ucdp_gedevent_dec21$u_ucdp_gedid_dec21_side_b_new_id <- 
  as.integer(ucdp_gedevent_dec21$side_b_new_id)

# Check for duplicates in column names
no_duplicate_names(ucdp_gedevent_dec21)


write_dataset(ucdp_gedevent_dec21, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_gedevent_dec21_cleaned.rds"),
           tag = "ucdp_gedevent_dec_21",
           overwrite = TRUE)