library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_extsupp <- read_datasets("ucdp_extsupp", db, original = TRUE)

# Clean column names
names(ucdp_extsupp) <- clean_column_names(names(ucdp_extsupp))

# Duplicate checks
no_duplicates(ucdp_extsupp, c("dyadid_new", "year"))

# Create unit columns
ucdp_extsupp$u_ucdp_dyad_year_dyad_id <- 
  as.character(ucdp_extsupp$dyadid_new)

ucdp_extsupp$u_ucdp_dyad_year_year <- 
  as.integer(ucdp_extsupp$year)

# create location column for unit selectors
ucdp_extsupp$u_ucdp_dyad_year_location <- 
  ucdp_extsupp$location

# Check for duplicates in column names
no_duplicate_names(ucdp_extsupp)

# Save
write_dataset(ucdp_extsupp, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_extsupp_cleaned.rds"),
           tag = "ucdp_extsupp",
           overwrite = TRUE)