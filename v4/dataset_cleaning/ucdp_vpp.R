library(dplyr)
library(demutils)
db <- pg_connect()

ucdp_vpp <- read_datasets("ucdp_vpp", db, original = TRUE)

#Clean column names function
names(ucdp_vpp) <- clean_column_names(names(ucdp_vpp))

# Duplicate checks in unit columns
no_duplicates(ucdp_vpp, c("side_a_id", "side_b_id", "year"))
no_duplicates(ucdp_vpp, c("dyad_id", "year"))

# dyad_year
ucdp_vpp$u_ucdp_dyad_year_dyad_id <- 
  as.character(ucdp_vpp$dyad_id)

ucdp_vpp$u_ucdp_dyad_year_year <- 
  as.integer(ucdp_vpp$year)

# create location column for unit selectors
ucdp_vpp$u_ucdp_dyad_year_location <- 
  ucdp_vpp$location

# Check for duplicates in column names
no_duplicate_names(ucdp_vpp)

write_dataset(ucdp_vpp, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_vpp_cleaned.rds"),
              tag = "ucdp_vpp",
              overwrite = TRUE)
