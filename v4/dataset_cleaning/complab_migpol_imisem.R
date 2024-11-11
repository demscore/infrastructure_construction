library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_imisem <- read_datasets("complab_migpol_imisem", db, original = TRUE)
names(complab_migpol_imisem) <- gsub("imisem_", "", names(complab_migpol_imisem), perl = TRUE)

no_duplicates(complab_migpol_imisem, c("country_full_name", "year"))

# Clean column names
names(complab_migpol_imisem) <- clean_column_names(names(complab_migpol_imisem))

# Create unit columns
complab_migpol_imisem$u_complab_country_year_country <- 
  complab_migpol_imisem$country_full_name

complab_migpol_imisem$u_complab_country_year_country_code <- 
  complab_migpol_imisem$iso3

complab_migpol_imisem$u_complab_country_year_year <- 
  as.integer(complab_migpol_imisem$year)

complab_migpol_imisem %<>%
  mutate(u_complab_country_year_country = case_when(
    u_complab_country_year_country == "Slovak Republic" ~ "Slovakia",
    u_complab_country_year_country == "HRV" ~ "Croatia",
    u_complab_country_year_country == "Russian Federation" ~ "Russia",
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

complab_migpol_imisem$u_complab_country_year_country <- 
  gsub("&amp;", "\\&", complab_migpol_imisem$u_complab_country_year_country)

# Final check for duplicates in column names
no_duplicate_names(complab_migpol_imisem)

write_dataset(complab_migpol_imisem,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_migpol_imisem_cleaned.rds"),
              tag = "complab_migpol_imisem",
              overwrite = TRUE)
