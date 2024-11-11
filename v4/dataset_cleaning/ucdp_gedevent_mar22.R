library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_gedevent_mar22 <- read_datasets("ucdp_gedevent_mar22", db, original = TRUE)


# Clean column names
names(ucdp_gedevent_mar22) <- clean_column_names(names(ucdp_gedevent_mar22))

# Create unit columns
ucdp_gedevent_mar22$u_ucdp_gedid_mar22_id <- 
  ucdp_gedevent_mar22$id

ucdp_gedevent_mar22$date_start <- 
  as.Date(ucdp_gedevent_mar22$date_start)

ucdp_gedevent_mar22$date_end <- 
  as.Date(ucdp_gedevent_mar22$date_end)

ucdp_gedevent_mar22$u_ucdp_gedid_mar22_country <- 
  ucdp_gedevent_mar22$country

ucdp_gedevent_mar22$u_ucdp_gedid_mar22_year <- 
  as.integer(ucdp_gedevent_mar22$year)

ucdp_gedevent_mar22$u_ucdp_gedid_mar22_dyad_new_id <- 
  as.integer(ucdp_gedevent_mar22$dyad_new_id)

ucdp_gedevent_mar22$u_ucdp_gedid_mar22_conflict_new_id <- 
  as.integer(ucdp_gedevent_mar22$conflict_new_id)

ucdp_gedevent_mar22$u_ucdp_gedid_mar22_side_a_new_id <- 
  as.integer(ucdp_gedevent_mar22$side_a_new_id)

ucdp_gedevent_mar22$u_ucdp_gedid_mar22_side_b_new_id <- 
  as.integer(ucdp_gedevent_mar22$side_b_new_id)

# Check for duplicates in column names
no_duplicate_names(ucdp_gedevent_mar22)

write_dataset(ucdp_gedevent_mar22, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_gedevent_mar22_cleaned.rds"),
              tag = "ucdp_gedevent_mar22",
              overwrite = TRUE)