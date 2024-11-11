library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_impic_antidisc <- read_datasets("complab_migpol_impic_antidisc", db, original = TRUE)

# Clean column names
names(complab_migpol_impic_antidisc) <- clean_column_names(names(complab_migpol_impic_antidisc))

# Create unit columns
complab_migpol_impic_antidisc$u_complab_country_year_country <- 
  complab_migpol_impic_antidisc$country_full_name

complab_migpol_impic_antidisc$u_complab_country_year_country_code <- 
  complab_migpol_impic_antidisc$iso3

complab_migpol_impic_antidisc$u_complab_country_year_year <- 
  as.integer(complab_migpol_impic_antidisc$year)

complab_migpol_impic_antidisc %<>%
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

complab_migpol_impic_antidisc$u_complab_country_year_country <- 
  gsub("&amp;", "\\&", complab_migpol_impic_antidisc$u_complab_country_year_country)

# Final check for duplicates in column names
no_duplicate_names(complab_migpol_impic_antidisc)

write_dataset(complab_migpol_impic_antidisc,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_migpol_impic_antidisc_cleaned.rds"),
              tag = "complab_migpol_impic_antidisc",
              overwrite = TRUE)