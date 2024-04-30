library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_cid_dy <- read_datasets("ucdp_cid_dy", db, original = TRUE)

# Clean column names
names(ucdp_cid_dy) <- clean_column_names(names(ucdp_cid_dy))

ucdp_cid_dy %<>%
  # Rename all columns that start with a number to start with n_
  rename_with(~paste0("n_", .), matches("^\\d"))

# Create unit columns

ucdp_cid_dy$u_ucdp_dyad_year_dyad_id <- 
  as.character(ucdp_cid_dy$dyad_id)

ucdp_cid_dy$u_ucdp_dyad_year_year <- 
  ucdp_cid_dy$year

# create location column for unit selectors
ucdp_cid_dy$u_ucdp_dyad_year_location <- NA

ucdp_cid_dy$u_ucdp_dyad_year_location[is.na(ucdp_cid_dy$u_ucdp_dyad_year_location)] <- 
  "no location specified in original dataset"

ucdp_cid_dy %<>% select(-v1)

dups <- duplicates(ucdp_cid_dy, c("u_ucdp_dyad_year_dyad_id", "u_ucdp_dyad_year_year"))


# Check for duplicates in column names
no_duplicate_names(ucdp_cid_dy)

write_dataset(ucdp_cid_dy, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_cid_dy_cleaned.rds"),
              tag = "ucdp_cid_dy",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(ucdp_cid_dy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/ucdp_cid_dy_cleaned.dta"),
           overwrite = TRUE)

write_file(ucdp_cid_dy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/ucdp_cid_dy_cleaned.csv"),
           overwrite = TRUE)
