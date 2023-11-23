library(dplyr)
library(demutils)

db <- pg_connect()

complab_grace <- read_datasets("complab_grace", db, original = TRUE)

# Clean column names
names(complab_grace) <- clean_column_names(names(complab_grace))

# Create unit columns
complab_grace$u_complab_country_year_country <- 
  complab_grace$country

#complab_grace$u_complab_country_year_country_nr <- 
#  as.numeric(complab_grace$ccode)

complab_grace$u_complab_country_year_country_code <- 
  complab_grace$iso3c

complab_grace$u_complab_country_year_year <- 
  as.integer(complab_grace$year)

complab_grace %<>%
  mutate(u_complab_country_year_country = case_when(
    u_complab_country_year_country == "Slovak Republic" ~ "Slovakia",
    u_complab_country_year_country == "Korea, Rep." ~ "South Korea",
    u_complab_country_year_country == "HRV" ~ "Croatia",
    u_complab_country_year_country == "Russian Federation" ~ "Russia",
    u_complab_country_year_country == "Czech Republic" ~ "Czechia",
    u_complab_country_year_country_code == "IVR" ~ "Ivory Coast",
    u_complab_country_year_country_code == "XKX" ~ "Kosovo",
    TRUE ~ u_complab_country_year_country
  )) %>%
  mutate(u_complab_country_year_country_code = case_when(
    u_complab_country_year_country_code == "Slovak Republic" ~ "SVK",
    u_complab_country_year_country_code == "Croatia" ~ "HRV",
    u_complab_country_year_country_code == "BUL" ~ "BGR",
    u_complab_country_year_country_code == "GRE" ~ "GRC",
    u_complab_country_year_country_code == "IRE" ~ "IRL",
    u_complab_country_year_country_code == "POR" ~ "PRT",
    TRUE ~ u_complab_country_year_country_code
  )) 


# Final check for duplicates in column names
no_duplicate_names(complab_grace)


write_dataset(complab_grace,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_grace_cleaned.rds"),
              tag = "complab_grace",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(complab_grace,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets_dta/complab_grace_cleaned.dta"),
              overwrite = TRUE)

write_file(complab_grace,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets_csv/complab_grace_cleaned.csv"),
              overwrite = TRUE)