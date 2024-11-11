library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_ged <- read_datasets("ucdp_ged", db, original = TRUE)


# Clean column names
names(ucdp_ged) <- clean_column_names(names(ucdp_ged))

#v <- names(ucdp_ged)
#v <- v [!v %in% c("id", "relid")]
#no_duplicates(ucdp_ged, v)
#df <- duplicates(ucdp_ged, v) %>%
#  arrange(dyad_new_id, date_start)

# Duplicate columns for unit tabels
ucdp_ged$u_ucdp_gedid_id <- ucdp_ged$id

ucdp_ged$date_start <- 
  as.Date(ucdp_ged$date_start)

ucdp_ged$date_end <- 
  as.Date(ucdp_ged$date_end)

ucdp_ged$u_ucdp_gedid_country <- 
  ucdp_ged$country

ucdp_ged$u_ucdp_gedid_gwno_a <- 
  ucdp_ged$gwnoa

ucdp_ged$u_ucdp_gedid_year <- 
  as.integer(ucdp_ged$year)

ucdp_ged$u_ucdp_gedid_dyad_new_id <- 
  as.integer(ucdp_ged$dyad_new_id)

ucdp_ged$u_ucdp_gedid_conflict_new_id <- 
  as.integer(ucdp_ged$conflict_new_id)

ucdp_ged$u_ucdp_gedid_side_a_new_id <- 
  ucdp_ged$side_a_new_id

ucdp_ged$u_ucdp_gedid_side_b_new_id <- 
  ucdp_ged$side_b_new_id


# Check for duplicates in column names
no_duplicate_names(ucdp_ged)


write_dataset(ucdp_ged, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_ged_cleaned.rds"),
           tag = "ucdp_ged",
           overwrite = TRUE)