library(dplyr)
library(demutils)

db <- pg_connect()

complab_spin_sied <- read_datasets("complab_spin_sied", db, original = TRUE)

# Clean column names
names(complab_spin_sied) <- clean_column_names(names(complab_spin_sied))

# Rename country variable to 'synchronize' complab country variable names in demscore
# The column storing numeric ids is renamed to country_nr (unless that is not the name already),
# and the column storing the country abbreviation character code is renamed to country_code

complab_spin_sied %<>% rename(country_code = country) %>%
  rename(country_nr = countrynr)

# Duplicates check to identify units
no_duplicates(complab_spin_sied, c("country_nr", "year")) #TRUE
no_duplicates(complab_spin_sied, c("country_code", "year")) #TRUE


# Create unit columns
#complab_spin_sied$u_complab_country_year_country_nr <- 
#  as.numeric(complab_spin_sied$country_nr)

complab_spin_sied$u_complab_country_year_country_code <- 
  complab_spin_sied$country_code

complab_spin_sied$u_complab_country_year_year <- 
  as.integer(complab_spin_sied$year)

# Add column country_fname (fullname) to not only have the character and numeric
# codes in the unit table, but also the full country names on which the dataset is translated
complab_spin_sied %<>% 
  mutate(u_complab_country_year_country = case_when(
    u_complab_country_year_country_code == "AUS" ~ "Australia",
    u_complab_country_year_country_code == "AUT" ~ "Austria",
    u_complab_country_year_country_code == "BEL" ~ "Belgium",
    u_complab_country_year_country_code == "BUL" ~ "Bulgaria",
    u_complab_country_year_country_code == "CAN" ~ "Canada",
    u_complab_country_year_country_code == "CYP" ~ "Cyprus",
    u_complab_country_year_country_code == "CZE" ~ "Czechia",
    u_complab_country_year_country_code == "DNK" ~ "Denmark",
    u_complab_country_year_country_code == "EST" ~ "Estonia",
    u_complab_country_year_country_code == "FIN" ~ "Finland",
    u_complab_country_year_country_code == "FRA" ~ "France",
    u_complab_country_year_country_code == "DEU" ~ "Germany",
    u_complab_country_year_country_code == "GRE" ~ "Greece",
    u_complab_country_year_country_code == "HUN" ~ "Hungary",
    u_complab_country_year_country_code == "ISL" ~ "Iceland",
    u_complab_country_year_country_code == "IRE" ~ "Ireland",
    u_complab_country_year_country_code == "ITA" ~ "Italy",
    u_complab_country_year_country_code == "JPN" ~ "Japan",
    u_complab_country_year_country_code == "LVA" ~ "Latvia",
    u_complab_country_year_country_code == "LTU" ~ "Lithuania",
    u_complab_country_year_country_code == "LUX" ~ "Luxembourg",
    u_complab_country_year_country_code == "MLT" ~ "Malta",
    u_complab_country_year_country_code == "NLD" ~ "Netherlands",
    u_complab_country_year_country_code == "NZL" ~ "New Zealand",
    u_complab_country_year_country_code == "NOR" ~ "Norway",
    u_complab_country_year_country_code == "POL" ~ "Poland",
    u_complab_country_year_country_code == "POR" ~ "Portugal",
    u_complab_country_year_country_code == "ROU" ~ "Romania",
    u_complab_country_year_country_code == "SVK" ~ "Slovakia",
    u_complab_country_year_country_code == "SVN" ~ "Slovenia",
    u_complab_country_year_country_code == "ESP" ~ "Spain",
    u_complab_country_year_country_code == "SWE" ~ "Sweden",
    u_complab_country_year_country_code == "CHE" ~ "Switzerland",
    u_complab_country_year_country_code == "GBR" ~ "United Kingdom",
    u_complab_country_year_country_code == "USA" ~ "United States",
    u_complab_country_year_country_code == "TUR" ~ "Turkey",
    u_complab_country_year_country_code == "BRA" ~ "Brazil",
    u_complab_country_year_country_code == "CHL" ~ "Chile",
    u_complab_country_year_country_code == "ISR" ~ "Israel",
    u_complab_country_year_country_code == "KOR" ~ "South Korea",
    TRUE ~ u_complab_country_year_country_code)) %>%
  mutate(u_complab_country_year_country = case_when(
    u_complab_country_year_country == "Slovak Republic" ~ "Slovakia",
    u_complab_country_year_country == "HRV" ~ "Croatia",
    u_complab_country_year_country == "Russian Federation" ~ "Russia",
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


#Final check for duplicates in column names
no_duplicate_names(complab_spin_sied)


write_dataset(complab_spin_sied, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets/complab_spin_sied_cleaned.rds"),
           tag = "complab_spin_sied",
           overwrite = TRUE)