library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_impic_rd <- read_datasets("complab_migpol_impic_rd", db, original = TRUE)
names(complab_migpol_impic_rd) <- gsub("impic_", "", names(complab_migpol_impic_rd), perl = TRUE)

# Clean column names
names(complab_migpol_impic_rd) <- clean_column_names(names(complab_migpol_impic_rd))

# Remove duplicate obes, i.e. where country_full_name is NA
complab_migpol_impic_rd %<>% filter(!is.na(country_full_name))

no_duplicates(complab_migpol_impic_rd, c("country_full_name", "year", "track"))

# Create unit columns
complab_migpol_impic_rd$u_complab_country_year_track_country <- 
  complab_migpol_impic_rd$country_full_name

complab_migpol_impic_rd$u_complab_country_year_track_country_code <- 
  complab_migpol_impic_rd$iso3

complab_migpol_impic_rd$u_complab_country_year_track_year <- 
  as.integer(complab_migpol_impic_rd$year)

complab_migpol_impic_rd$u_complab_country_year_track_track <- 
  as.integer(complab_migpol_impic_rd$track)

complab_migpol_impic_rd %<>%
  mutate(u_complab_country_year_track_country = case_when(
    u_complab_country_year_track_country == "Slovak Republic" ~ "Slovakia",
    u_complab_country_year_track_country == "Korea, Rep." ~ "South Korea",
    u_complab_country_year_track_country == "Korea" ~ "South Korea",
    u_complab_country_year_track_country == "HRV" ~ "Croatia",
    u_complab_country_year_track_country == "Russian Federation" ~ "Russia",
    u_complab_country_year_track_country_code == "XKX" ~ "Kosovo",
    TRUE ~ u_complab_country_year_track_country
  )) %>%
  mutate(u_complab_country_year_track_country_code = case_when(
    u_complab_country_year_track_country_code == "Slovak Republic" ~ "SVK",
    u_complab_country_year_track_country_code == "Croatia" ~ "HRV",
    u_complab_country_year_track_country_code == "BUL" ~ "BGR",
    u_complab_country_year_track_country_code == "GRE" ~ "GRC",
    u_complab_country_year_track_country_code == "IRE" ~ "IRL",
    u_complab_country_year_track_country_code == "POR" ~ "PRT",
    TRUE ~ u_complab_country_year_track_country_code
  )) %>%
  filter(!is.na(u_complab_country_year_track_track))

complab_migpol_impic_rd$u_complab_country_year_track_country <- 
  gsub("&amp;", "\\&", complab_migpol_impic_rd$u_complab_country_year_track_country)



# Final check for duplicates in column names
no_duplicate_names(complab_migpol_impic_rd)

write_dataset(complab_migpol_impic_rd,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_migpol_impic_rd_cleaned.rds"),
              tag = "complab_migpol_impic_rd",
              overwrite = TRUE)

# Create static files in dta and csv format

write_file(complab_migpol_impic_rd,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets_csv/complab_migpol_impic_rd_cleaned.csv"),
           overwrite = TRUE)
