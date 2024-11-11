library(dplyr)
library(demutils)


db <- pg_connect()

ucdp_brd_dyadic <- read_datasets("ucdp_brd_dyadic", db, original = TRUE)

# Clean column names
names(ucdp_brd_dyadic) <- clean_column_names(names(ucdp_brd_dyadic))

# Check for duplicates
no_duplicates(ucdp_brd_dyadic, c("dyad_id", "year")) # TRUE
no_duplicates(ucdp_brd_dyadic, c("conflict_id", "year")) # FALSE

# Create unit columns

#dyad_year
ucdp_brd_dyadic$u_ucdp_dyad_year_dyad_id <- 
  as.character(ucdp_brd_dyadic$dyad_id)

ucdp_brd_dyadic$u_ucdp_dyad_year_year <- 
  ucdp_brd_dyadic$year

# create location column for unit selectors
ucdp_brd_dyadic$u_ucdp_dyad_year_location <- 
  ucdp_brd_dyadic$location

# Check for duplicates in column names
no_duplicate_names(ucdp_brd_dyadic)


write_dataset(ucdp_brd_dyadic, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_brd_dyadic_cleaned.rds"),
           tag = "ucdp_brd_dyadic",
           overwrite = TRUE)
