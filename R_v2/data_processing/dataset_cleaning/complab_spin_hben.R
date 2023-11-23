library(dplyr)
library(demutils)

db <- pg_connect()

complab_spin_hben <- read_datasets("complab_spin_hben", db, original = TRUE)

# Clean column names
names(complab_spin_hben) <- clean_column_names(names(complab_spin_hben))

# Rename country variable to 'synchronize' complab country variable names in demscore
# The column storing numeric ids is renamed to country_nr (unless that is not the name already),
# and the column storing the country abbreviation character code is renamed to country_code

complab_spin_hben %<>% rename(country_nr = countrynr) 

# Duplicates check to identify units
no_duplicates(complab_spin_hben, c("country_nr", "year")) #TRUE


# Add unit columns
#complab_spin_hben$u_complab_country_year_country_nr <- 
#  as.numeric(complab_spin_hben$country_nr)

complab_spin_hben$u_complab_country_year_country <- 
  complab_spin_hben$country

complab_spin_hben$u_complab_country_year_year <- 
  as.integer(complab_spin_hben$year)

# Add country-code column
complab_spin_hben %<>% 
  mutate(u_complab_country_year_country_code = case_when(
    u_complab_country_year_country == "Australia" ~ "AUS",
    u_complab_country_year_country == "Austria" ~ "AUT",
    u_complab_country_year_country == "Belgium" ~ "BEL",
    u_complab_country_year_country == "Bulgaria"~ "BGR",
    u_complab_country_year_country == "Canada" ~ "CAN",
    u_complab_country_year_country == "Cyprus" ~ "CYP",
    u_complab_country_year_country == "Czech Republic" ~ "CZE",
    u_complab_country_year_country == "Denmark" ~ "DNK",
    u_complab_country_year_country == "Estonia" ~ "EST",
    u_complab_country_year_country == "Finland" ~ "FIN",
    u_complab_country_year_country == "France" ~ "FRA",
    u_complab_country_year_country == "Germany" ~ "DEU",
    u_complab_country_year_country == "Greece" ~ "GRC",
    u_complab_country_year_country == "Hungary" ~ "HUN",
    u_complab_country_year_country == "Iceland" ~ "ISL",
    u_complab_country_year_country == "Ireland" ~ "IRL",
    u_complab_country_year_country == "Italy" ~"ITA",
    u_complab_country_year_country == "Japan" ~ "JPN",
    u_complab_country_year_country == "Latvia" ~ "LVA",
    u_complab_country_year_country == "Lithuania" ~ "LTU",
    u_complab_country_year_country == "Luxembourg" ~ "LUX",
    u_complab_country_year_country == "Malta" ~ "MLT",
    u_complab_country_year_country == "Netherlands" ~ "NLD",
    u_complab_country_year_country == "New Zealand" ~ "NZL",
    u_complab_country_year_country == "Norway" ~ "NOR",
    u_complab_country_year_country == "Poland" ~ "POL",
    u_complab_country_year_country == "Portugal" ~ "PRT",
    u_complab_country_year_country == "Romania" ~ "ROU",
    u_complab_country_year_country == "Slovakia" ~ "SVK",
    u_complab_country_year_country == "Slovenia" ~ "SVN",
    u_complab_country_year_country == "Spain" ~ "ESP",
    u_complab_country_year_country == "Sweden" ~ "SWE",
    u_complab_country_year_country == "Switzerland" ~ "CHE",
    u_complab_country_year_country == "United Kingdom" ~ "GBR",
    u_complab_country_year_country == "United States" ~ "USA",
    u_complab_country_year_country == "Turkey" ~ "TUR",
    u_complab_country_year_country == "Brazil" ~ "BRA",
    u_complab_country_year_country == "Chile" ~ "CHL",
    u_complab_country_year_country == "Israel" ~ "ISR",
    u_complab_country_year_country == "South Korea" ~ "KOR",
    TRUE ~ u_complab_country_year_country)) %>%
  mutate(u_complab_country_year_country = case_when(
    u_complab_country_year_country == "Slovak Republic" ~ "Slovakia",
    u_complab_country_year_country == "Korea, Rep." ~ "South Korea",
    u_complab_country_year_country == "HRV" ~ "Croatia",
    u_complab_country_year_country == "Russian Federation" ~ "Russia",
    u_complab_country_year_country == "Czech Republic" ~ "Czechia",
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
  )) %>%
  mutate(u_complab_country_year_country = case_when(
    u_complab_country_year_country_code == "XKX" ~ "Kosovo",
    u_complab_country_year_country_code == "IVR" ~ "Ivory Coast",
    TRUE ~ u_complab_country_year_country
  ))

no_duplicate_names(complab_spin_hben)


write_dataset(complab_spin_hben,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_spin_hben_cleaned.rds"),
              tag = "complab_spin_hben",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(complab_spin_hben,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets_dta/complab_spin_hben_cleaned.dta"),
           overwrite = TRUE)

write_file(complab_spin_hben,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets_csv/complab_spin_hben_cleaned.csv"),
           overwrite = TRUE)