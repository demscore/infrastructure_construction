library(dplyr)
library(demutils)

db <- pg_connect()

hdata_conflict_cy <- read_datasets("hdata_conflict_cy", db, original = TRUE)

# Remove dupl rows where isd_region for Kokand is missing and only keep rows for 
# New Zealand and Fiji where isd_region is 3 (remove where it is 4)

hdata_conflict_cy %<>%
  filter(!is.na(isd_region)) %>%
  filter(!(grepl("New Zealand|Fiji", isd_country) & isd_region == 4)) 

# Clean column names
names(hdata_conflict_cy) <- clean_column_names(names(hdata_conflict_cy))

any(is.na(hdata_conflict_cy$cow_code))

# Duplicate columns for unit tables
hdata_conflict_cy$u_hdata_country_year_country <- 
  hdata_conflict_cy$isd_country

hdata_conflict_cy$u_hdata_country_year_year <- 
  as.numeric(hdata_conflict_cy$year)

hdata_conflict_cy$u_hdata_country_year_cowcode <- 
  as.numeric(hdata_conflict_cy$cow_code)

hdata_conflict_cy$u_hdata_country_year_cowcode[is.na(hdata_conflict_cy$u_hdata_country_year_cowcode)] <- 
  as.numeric(-11111)

# Final duplicates check column names
no_duplicate_names(hdata_conflict_cy)

write_dataset(hdata_conflict_cy, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/hdata/cleaned_datasets/hdata_conflict_cy_cleaned.rds"),
              tag= "hdata_conflict_cy",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(hdata_conflict_cy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/hdata/cleaned_datasets_dta/hdata_conflict_cy_cleaned.dta"),
           overwrite = TRUE)

write_file(hdata_conflict_cy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/hdata/cleaned_datasets_csv/hdata_conflict_cy_cleaned.csv"),
           overwrite = TRUE)