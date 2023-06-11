library(dplyr)
library(demutils)
db <- pg_connect()

ucdp_onset_inter_v1 <- read_datasets("ucdp_onset_inter_v1", db, original = TRUE)

# Clean column names function
names(ucdp_onset_inter_v1) <- clean_column_names(names(ucdp_onset_inter_v1))

# Check for duplcates in unit columns
no_duplicates(ucdp_onset_inter_v1, c("name", "year", "conflict_ids"))

# Create unit columns
ucdp_onset_inter_v1$u_ucdp_country_year_confl_gwno_a <- 
  ucdp_onset_inter_v1$gwno_a

ucdp_onset_inter_v1$u_ucdp_country_year_confl_name <- 
  ucdp_onset_inter_v1$name

ucdp_onset_inter_v1$u_ucdp_country_year_confl_year <- 
  ucdp_onset_inter_v1$year

ucdp_onset_inter_v1$u_ucdp_country_year_confl_conflict_id <- 
  ucdp_onset_inter_v1$conflict_ids

# Unit columns must not have missing values, replace NAs with -66
ucdp_onset_inter_v1 %<>% mutate(u_ucdp_country_year_confl_conflict_id = 
                                  ifelse(is.na(u_ucdp_country_year_confl_conflict_id), -66, 
                                         u_ucdp_country_year_confl_conflict_id))


write_dataset(ucdp_onset_inter_v1, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_onset_inter_v1_cleaned.rds"),
              tag = "ucdp_onset_inter_v1",
              overwrite = TRUE)