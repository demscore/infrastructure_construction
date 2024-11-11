library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_impic_antidisc_rd <- read_datasets("complab_migpol_impic_antidisc_rd", db, original = TRUE)
names(complab_migpol_impic_antidisc_rd) <- gsub("impic_", "", names(complab_migpol_impic_antidisc_rd), perl = TRUE)

# Clean column names
names(complab_migpol_impic_antidisc_rd) <- clean_column_names(names(complab_migpol_impic_antidisc_rd))

no_duplicates(complab_migpol_impic_antidisc_rd, c("country_full_name", "year"))

# Create unit columns
complab_migpol_impic_antidisc_rd$u_complab_country_year_country <- 
  complab_migpol_impic_antidisc_rd$country_full_name

complab_migpol_impic_antidisc_rd$u_complab_country_year_country_code <- 
  complab_migpol_impic_antidisc_rd$iso3

complab_migpol_impic_antidisc_rd$u_complab_country_year_year <- 
  as.integer(complab_migpol_impic_antidisc_rd$year)

complab_migpol_impic_antidisc_rd %<>%
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

complab_migpol_impic_antidisc_rd$u_complab_country_year_country <- 
  gsub("&amp;", "\\&", complab_migpol_impic_antidisc_rd$u_complab_country_year_country)

# Final check for duplicates in column names
no_duplicate_names(complab_migpol_impic_antidisc_rd)

write_dataset(complab_migpol_impic_antidisc_rd,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_migpol_impic_antidisc_rd_cleaned.rds"),
              tag = "complab_migpol_impic_antidisc_rd",
              overwrite = TRUE)