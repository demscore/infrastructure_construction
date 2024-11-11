library(dplyr)
library(demutils)
db <- pg_connect()

ucdp_onset_intra_multiple <- read_datasets("ucdp_onset_intra_multiple", db, original = TRUE)

# Clean column names function
names(ucdp_onset_intra_multiple) <- clean_column_names(names(ucdp_onset_intra_multiple))

# Check for duplicates in column names
no_duplicates(ucdp_onset_intra_multiple, c("gwno_a", "year", "conflict_ids"))


# Create unit columns
ucdp_onset_intra_multiple$u_ucdp_country_year_confl_gwno_a <- 
  ucdp_onset_intra_multiple$gwno_a

ucdp_onset_intra_multiple$u_ucdp_country_year_confl_name <- 
  ucdp_onset_intra_multiple$name

ucdp_onset_intra_multiple$u_ucdp_country_year_confl_year <- 
  ucdp_onset_intra_multiple$year

ucdp_onset_intra_multiple$u_ucdp_country_year_confl_conflict_id <- 
  ucdp_onset_intra_multiple$conflict_ids

# Unit columns must not have missing values, replace NAs with -66
ucdp_onset_intra_multiple %<>% mutate(u_ucdp_country_year_confl_conflict_id = 
                                  ifelse(is.na(u_ucdp_country_year_confl_conflict_id), -66, 
                                         u_ucdp_country_year_confl_conflict_id))


write_dataset(ucdp_onset_intra_multiple, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_onset_intra_multiple_cleaned.rds"),
              tag = "ucdp_onset_intra_multiple",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(ucdp_onset_intra_multiple,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/ucdp_onset_intra_multiple_cleaned.dta"),
           overwrite = TRUE)

write_file(ucdp_onset_intra_multiple,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/ucdp_onset_intra_multiple_cleaned.csv"),
           overwrite = TRUE)