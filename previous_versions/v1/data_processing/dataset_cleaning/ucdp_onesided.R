library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_onesided <- read_datasets("ucdp_onesided", db, original = TRUE)

#Use function to clean column names
names(ucdp_onesided) <- clean_column_names(names(ucdp_onesided))

# Check for duplicates
no_duplicates(ucdp_onesided, c("dyad_id", "year")) # TRUE
no_duplicates(ucdp_onesided, c("actor_id", "year")) # TRUE
no_duplicates(ucdp_onesided, c("conflict_id", "year")) # TRUE

# Duplicate columns for unit table
# dyad_year
ucdp_onesided$u_ucdp_dyad_year_dyad_id <- 
  as.character(ucdp_onesided$dyad_id)

ucdp_onesided$u_ucdp_dyad_year_year <- 
  ucdp_onesided$year

# Save
write_dataset(ucdp_onesided, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_onesided_cleaned.rds"),
           tag = "ucdp_onesided",
           overwrite = TRUE)