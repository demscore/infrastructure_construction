library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_gc_cy <- read_datasets("complab_migpol_gc_cy", db, original = TRUE)

no_duplicates(complab_migpol_gc_cy, c("country_full_name", "year"))

# Clean column names
names(complab_migpol_gc_cy) <- clean_column_names(names(complab_migpol_gc_cy))

# Create unit columns
complab_migpol_gc_cy$u_complab_country_year_country <- 
  complab_migpol_gc_cy$country_full_name

complab_migpol_gc_cy$u_complab_country_year_country_code <- 
  toupper(complab_migpol_gc_cy$iso3)

complab_migpol_gc_cy$u_complab_country_year_year <- 
  as.integer(complab_migpol_gc_cy$year)

complab_migpol_gc_cy %<>%
  mutate(u_complab_country_year_country = case_when(
    u_complab_country_year_country == "Slovak Republic" ~ "Slovakia",
    u_complab_country_year_country == "HRV" ~ "Croatia",
    u_complab_country_year_country == "Russian Federation" ~ "Russia",
    u_complab_country_year_country == "Czechoslovakia" ~ "Czechia",
    u_complab_country_year_country == "São Tomé & Príncipe" ~ "Sao Tome & Principe",
    u_complab_country_year_country_code == "CIV" ~ "Ivory Coast",
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
    u_complab_country_year_country_code == "CIV" ~ "IVR",
    TRUE ~ u_complab_country_year_country_code
  )) 

complab_migpol_gc_cy$u_complab_country_year_country <- 
  gsub("&amp;", "\\&", complab_migpol_gc_cy$u_complab_country_year_country)

# Remove duplicate obes, i.e. where country_full_name is NA
complab_migpol_gc_cy %<>% filter(!is.na(u_complab_country_year_country))

# Final check for duplicates in column names
no_duplicate_names(complab_migpol_gc_cy)

write_dataset(complab_migpol_gc_cy,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_migpol_gc_cy_cleaned.rds"),
              tag = "complab_migpol_gc_cy",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(complab_migpol_gc_cy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets_dta/complab_migpol_gc_cy_cleaned.dta"),
           overwrite = TRUE)

write_file(complab_migpol_gc_cy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets_csv/complab_migpol_gc_cy_cleaned.csv"),
           overwrite = TRUE)