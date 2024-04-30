library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_term_dyadic <- read_datasets("ucdp_term_dyadic", db, original = TRUE)

#Use function to clean column names
names(ucdp_term_dyadic) <- clean_column_names(names(ucdp_term_dyadic))

# Check for duplicates
no_duplicates(ucdp_term_dyadic, c("year", "dyad_id"))
no_duplicates(ucdp_term_dyadic, c("year", "side_a", "side_b"))

# Duplicate columns for unit_tables
ucdp_term_dyadic$u_ucdp_dyad_year_dyad_id <- 
  as.character(ucdp_term_dyadic$dyad_id)

ucdp_term_dyadic$u_ucdp_dyad_year_year <- 
  ucdp_term_dyadic$year

# create location column for unit selectors
ucdp_term_dyadic$u_ucdp_dyad_year_location <- 
  ucdp_term_dyadic$location


# Save 
write_dataset(ucdp_term_dyadic, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_term_dyadic_cleaned.rds"),
           tag = "ucdp_term_dyadic",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(ucdp_term_dyadic,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/ucdp_term_dyadic_cleaned.dta"),
           overwrite = TRUE)

write_file(ucdp_term_dyadic,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/ucdp_term_dyadic_cleaned.csv"),
           overwrite = TRUE)