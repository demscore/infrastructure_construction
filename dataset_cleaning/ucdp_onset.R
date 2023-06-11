# Load libraries
library(dplyr)
library(demutils)
db <- pg_connect()

ucdp_onset <- read_datasets("ucdp_onset", db, original = TRUE)

#Due to duplicates, creating an additional row ID column
ucdp_onset$u_ucdp_country_year_rowid_rowid <- seq_along(ucdp_onset$abc)

dubs_onset <- duplicates(ucdp_onset, c("name", "year"))

#Use function to clean column names
names(ucdp_onset) <- clean_column_names(names(ucdp_onset))


#Duplicate columns for unit tables. 
ucdp_onset$u_ucdp_country_year_rowid_country_code <- 
  ucdp_onset$abc

ucdp_onset$u_ucdp_country_year_rowid_name <- 
  ucdp_onset$name

ucdp_onset$u_ucdp_country_year_rowid_year <- 
  ucdp_onset$year


# Save data.frame with new column names
write_dataset(ucdp_onset, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_onset_cleaned.rds"),
           tag = "ucdp_onset",
           overwrite = TRUE)