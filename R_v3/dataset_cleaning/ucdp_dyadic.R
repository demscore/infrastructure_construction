library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_dyadic <- read_datasets("ucdp_dyadic", db, original = TRUE)

# Clean column names
names(ucdp_dyadic) <- clean_column_names(names(ucdp_dyadic))

# Create unit columns

ucdp_dyadic$u_ucdp_dyad_year_dyad_id <- 
  as.character(ucdp_dyadic$dyad_id)

ucdp_dyadic$u_ucdp_dyad_year_year <- 
  ucdp_dyadic$year

# create location column for unit selectors
ucdp_dyadic$u_ucdp_dyad_year_location <- 
  ucdp_dyadic$location

# Create columns for dyad-location-year unit
ucdp_dyadic$u_ucdp_dyad_location_year_dyad_id <- 
  as.character(ucdp_dyadic$dyad_id)

ucdp_dyadic$u_ucdp_dyad_location_year_year <- 
  ucdp_dyadic$year

ucdp_dyadic$u_ucdp_dyad_location_year_location <- 
  ucdp_dyadic$location

ucdp_dyadic$u_ucdp_dyad_location_year_gwno_loc <- 
  ucdp_dyadic$gwno_loc


# change date variables to only class Date (instead of IDate and Date)
ucdp_dyadic$start_date <- 
  as.Date(ucdp_dyadic$start_date) 

ucdp_dyadic$start_date2 <- 
  as.Date(ucdp_dyadic$start_date2)


# Check for duplicates in column names
no_duplicate_names(ucdp_dyadic)


write_dataset(ucdp_dyadic, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_dyadic_cleaned.rds"),
           tag = "ucdp_dyadic",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(ucdp_dyadic,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/ucdp_dyadic_cleaned.dta"),
           overwrite = TRUE)

write_file(ucdp_dyadic,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/ucdp_dyadic_cleaned.csv"),
           overwrite = TRUE)