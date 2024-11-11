library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_cace <- read_datasets("ucdp_cace", db, original = TRUE)

# Clean column names
names(ucdp_cace) <- clean_column_names(names(ucdp_cace))

#removing last column because it has only NAs
ucdp_cace <- select(ucdp_cace, -last_col())

# Create unit columns
# UCDP CACE uses similar ids as UCDP GED, however, we create a separate unit table as the IDs in 
# UCDP CACE are based on the UCDP GED version 18.1., but Demscore includes UCDP GED version 21.1.
ucdp_cace$u_ucdp_gedid_sep_id <- 
  as.integer(ucdp_cace$id)

# Additional unit columns relevant for aggregation
ucdp_cace$u_ucdp_gedid_sep_country <- 
  ucdp_cace$country

ucdp_cace$u_ucdp_gedid_sep_year <- 
  as.integer(ucdp_cace$year)

ucdp_cace$u_ucdp_gedid_sep_dyad_new_id <- 
  as.integer(ucdp_cace$dyad_new_id)

ucdp_cace$u_ucdp_gedid_sep_conflict_new_id <- 
  as.integer(ucdp_cace$conflict_new_id)

ucdp_cace$u_ucdp_gedid_sep_side_a_new_id <- 
  as.integer(ucdp_cace$side_a_new_id)

ucdp_cace$u_ucdp_gedid_sep_side_b_new_id <- 
  as.integer(ucdp_cace$side_b_new_id)

# Check for duplicates in column names
no_duplicate_names(ucdp_cace)


write_dataset(ucdp_cace, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_cace_cleaned.rds"),
           tag = "ucdp_cace",
           overwrite = TRUE)
