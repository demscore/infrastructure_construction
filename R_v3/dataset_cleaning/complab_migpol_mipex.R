library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_mipex <- read_datasets("complab_migpol_mipex", db, original = TRUE)
names(complab_migpol_mipex) <- gsub("mipex_", "", names(complab_migpol_mipex), perl = TRUE)

no_duplicates(complab_migpol_mipex, c("country_full_name", "year"))

# Clean column names
names(complab_migpol_mipex) <- clean_column_names(names(complab_migpol_mipex))

# Create unit columns
complab_migpol_mipex$u_complab_country_year_country <- 
  complab_migpol_mipex$country_full_name

complab_migpol_mipex$u_complab_country_year_country_code <- 
  complab_migpol_mipex$iso3

complab_migpol_mipex$u_complab_country_year_year <- 
  as.integer(complab_migpol_mipex$year)

complab_migpol_mipex %<>%
  mutate(u_complab_country_year_country = case_when(
    u_complab_country_year_country == "Slovak Republic" ~ "Slovakia",
    u_complab_country_year_country == "Korea, Rep." ~ "South Korea",
    u_complab_country_year_country == "Korea" ~ "South Korea",
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

complab_migpol_mipex$u_complab_country_year_country <- 
  gsub("&amp;", "\\&", complab_migpol_mipex$u_complab_country_year_country)

# Final check for duplicates in column names
no_duplicate_names(complab_migpol_mipex)

write_dataset(complab_migpol_mipex,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_migpol_mipex_cleaned.rds"),
              tag = "complab_migpol_mipex",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(complab_migpol_mipex,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets_dta/complab_migpol_mipex_cleaned.dta"),
           overwrite = TRUE)

write_file(complab_migpol_mipex,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets_csv/complab_migpol_mipex_cleaned.csv"),
           overwrite = TRUE)
