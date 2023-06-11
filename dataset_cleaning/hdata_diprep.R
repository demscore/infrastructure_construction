library(dplyr)
library(demutils)

db <- pg_connect()

hdata_diprep <- read_datasets("hdata_diprep", db, original = TRUE)

# Clean column names
names(hdata_diprep) <- clean_column_names(names(hdata_diprep))

any(is.na(hdata_diprep$cow_code2))

# Duplicate columns for unit tables
hdata_diprep$u_hdata_dyad_year_country_one <- 
  hdata_diprep$country_name1

hdata_diprep$u_hdata_dyad_year_country_two <- 
  hdata_diprep$country_name2

hdata_diprep$u_hdata_dyad_year_cowcode_one <- 
  hdata_diprep$cow_code1

hdata_diprep$u_hdata_dyad_year_cowcode_one[is.na(hdata_diprep$u_hdata_dyad_year_cowcode_one)] <- 
  as.integer(-11111)

hdata_diprep$u_hdata_dyad_year_cowcode_two <- 
  hdata_diprep$cow_code2

hdata_diprep$u_hdata_dyad_year_cowcode_two[is.na(hdata_diprep$u_hdata_dyad_year_cowcode_two)] <- 
  as.integer(-11111)

hdata_diprep$u_hdata_dyad_year_vdem_one <- 
  hdata_diprep$vdem_code1

hdata_diprep$u_hdata_dyad_year_vdem_two <- 
  hdata_diprep$vdem_code2

hdata_diprep$u_hdata_dyad_year_year <- 
  hdata_diprep$year

# Final duplicates check column names
no_duplicate_names(hdata_diprep)


write_dataset(hdata_diprep, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/hdata/cleaned_datasets/hdata_diprep_cleaned.rds"),
              tag= "hdata_diprep",
              overwrite = TRUE)