library(dplyr)
library(demutils)
db <- pg_connect()

ucdp_onset_intra_v2 <- read_datasets("ucdp_onset_intra_v2", db, original = TRUE)

#Clean column names function
names(ucdp_onset_intra_v2) <- clean_column_names(names(ucdp_onset_intra_v2))

no_duplicates(ucdp_onset_intra_v2, c("gwno_a", "year"))
no_duplicates(ucdp_onset_intra_v2, c("name", "year"))

# Create unit columns
ucdp_onset_intra_v2$u_ucdp_country_year_gwno_a <- 
  as.character(ucdp_onset_intra_v2$gwno_a)

ucdp_onset_intra_v2$u_ucdp_country_year_name <- 
  ucdp_onset_intra_v2$name

ucdp_onset_intra_v2$u_ucdp_country_year_year <- 
  ucdp_onset_intra_v2$year


write_dataset(ucdp_onset_intra_v2, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_onset_intra_v2_cleaned.rds"),
              tag = "ucdp_onset_intra_v2",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(ucdp_onset_intra_v2,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/ucdp_onset_intra_v2_cleaned.dta"),
           overwrite = TRUE)

write_file(ucdp_onset_intra_v2,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/ucdp_onset_intra_v2_cleaned.csv"),
           overwrite = TRUE)