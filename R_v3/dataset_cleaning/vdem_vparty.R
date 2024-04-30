library(dplyr)
library(demutils)

db <- pg_connect()

vdem_vparty <- read_datasets("vdem_vparty", db, original = TRUE)

# Clean column names
names(vdem_vparty) <- clean_column_names(names(vdem_vparty))

# Duplicates check to identify units
no_duplicates(vdem_vparty, c("v2paid", "historical_date")) #TRUE
no_duplicates(vdem_vparty, c("v2paid", "country_name", "year")) #TRUE

# Change historical date to class date to avoid second class IDate
vdem_vparty$historical_date <- as.Date(vdem_vparty$historical_date)

# Create unit columns for party-country-year unit
vdem_vparty$u_vdem_party_country_year_v2paenname <- 
  vdem_vparty$v2paenname

vdem_vparty$u_vdem_party_country_year_v2paid <- 
  vdem_vparty$v2paid

vdem_vparty$u_vdem_party_country_year_year <- 
  vdem_vparty$year

vdem_vparty$u_vdem_party_country_year_country_name <- 
  vdem_vparty$country_name

vdem_vparty$u_vdem_party_country_year_country_text_id <-
  vdem_vparty$country_text_id

vdem_vparty %<>% 
  mutate(u_vdem_party_country_year_country_name = case_when(
  u_vdem_party_country_year_country_name == 'Czech Republic' ~ 'Czechia',
  u_vdem_party_country_year_country_name == 'Turkey' ~ 'Türkiye',
  TRUE ~ u_vdem_party_country_year_country_name
))

# Apply class
classdf <- lapply(vdem_vparty, class)

#save
write_dataset(vdem_vparty,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/vdem/cleaned_datasets/vdem_vparty_cleaned.rds"),
           tag = "vdem_vparty",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(vdem_vparty,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/vdem/cleaned_datasets_dta/vdem_vparty_cleaned.dta"),
           overwrite = TRUE)

write_file(vdem_vparty,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/vdem/cleaned_datasets_csv/vdem_vparty_cleaned.csv"),
           overwrite = TRUE)
