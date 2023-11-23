library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_esd_dy <- read_datasets("ucdp_esd_dy", db, original = TRUE)

# Clean column names
names(ucdp_esd_dy) <- clean_column_names(names(ucdp_esd_dy))

#Identify unit columns
no_duplicates(ucdp_esd_dy, c("dyad_id", "year")) #TRUE
no_duplicates(ucdp_esd_dy, c("side_a_id", "side_b_id", "year")) #TRUE

# Create unit identifiers
ucdp_esd_dy$u_ucdp_dyad_year_dyad_id <-
  as.character(ucdp_esd_dy$dyad_id)

ucdp_esd_dy$u_ucdp_dyad_year_year <-
  as.integer(ucdp_esd_dy$year)

#Final check for duplicates in column names
no_duplicate_names(ucdp_esd_dy)

write_dataset(ucdp_esd_dy,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_esd_dy_cleaned.rds"),
              tag = "ucdp_esd_dy",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(ucdp_esd_dy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/ucdp_esd_dy_cleaned.dta"),
           overwrite = TRUE)

write_file(ucdp_esd_dy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/ucdp_esd_dy_cleaned.csv"),
           overwrite = TRUE)