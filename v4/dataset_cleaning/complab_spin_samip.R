library(dplyr)
library(demutils)

db <- pg_connect()

complab_spin_samip <- read_datasets("complab_spin_samip", db, original = TRUE)

# Clean column names
names(complab_spin_samip) <- clean_column_names(names(complab_spin_samip))

# Rename country variable to 'synchronize' complab country variable names in demscore
# The column storing numeric ids is renamed to country_nr (unless that is not the name already),
# and the column storing the country abbreviation character code is renamed to country_code

complab_spin_samip %<>% rename(country_code = country)

# Duplicates check to identify units
no_duplicates(complab_spin_samip, c("country_nr", "year")) #TRUE
no_duplicates(complab_spin_samip, c("country_code", "year")) #FALSE, special case for Norway and Italy


# Create unit columns
complab_spin_samip$u_complab_country_year_country_nr <- 
  complab_spin_samip$country_nr

# If using country_nr col instead: In order to keep country_nr as numeric, replacing 578x with 5780 and 380x with 3800
complab_spin_samip$u_complab_country_year_country_nr[complab_spin_samip$u_complab_country_year_country_nr == "578x"] <- "5780"
complab_spin_samip$u_complab_country_year_country_nr[complab_spin_samip$u_complab_country_year_country_nr == "380x"] <- "3800"

complab_spin_samip$u_complab_country_year_country_nr <- 
  as.numeric(complab_spin_samip$u_complab_country_year_country_nr)

complab_spin_samip$u_complab_country_year_country_code <- 
  complab_spin_samip$country_code

complab_spin_samip$u_complab_country_year_year <- 
  as.integer(complab_spin_samip$year)

# Add column country_fname (fullname) to not only have the character and numeric
# codes in the unit table, but also the full country names on which the dataset is translated
complab_spin_samip %<>% 
  mutate(u_complab_country_year_country = case_when(
    u_complab_country_year_country_code == "AUS" ~ "Australia",
    u_complab_country_year_country_code == "AUT" ~ "Austria",
    u_complab_country_year_country_code == "BEL" ~ "Belgium",
    u_complab_country_year_country_code == "BGR" ~ "Bulgaria",
    u_complab_country_year_country_code == "CAN" ~ "Canada",
    u_complab_country_year_country_code == "CYP" ~ "Cyprus",
    u_complab_country_year_country_code == "CZE" ~ "Czechia",
    u_complab_country_year_country_code == "DNK" ~ "Denmark",
    u_complab_country_year_country_code == "EST" ~ "Estonia",
    u_complab_country_year_country_code == "FIN" ~ "Finland",
    u_complab_country_year_country_code == "FRA" ~ "France",
    u_complab_country_year_country_code == "DEU" ~ "Germany",
    u_complab_country_year_country_code == "GRC" ~ "Greece",
    u_complab_country_year_country_code == "HUN" ~ "Hungary",
    u_complab_country_year_country_code == "ISL" ~ "Iceland",
    u_complab_country_year_country_code == "IRL" ~ "Ireland",
    country_nr == "380" ~ "Italy",
    country_nr == "380x" ~ "Italy_adjusted",
    u_complab_country_year_country_code == "JPN" ~ "Japan",
    u_complab_country_year_country_code == "LVA" ~ "Latvia",
    u_complab_country_year_country_code == "LTU" ~ "Lithuania",
    u_complab_country_year_country_code == "LUX" ~ "Luxembourg",
    u_complab_country_year_country_code == "MLT" ~ "Malta",
    u_complab_country_year_country_code == "NLD" ~ "Netherlands",
    u_complab_country_year_country_code == "NZL" ~ "New Zealand",
    country_nr == "578" ~ "Norway",
    country_nr == "578x" ~ "Norway_adjusted",
    u_complab_country_year_country_code == "POL" ~ "Poland",
    u_complab_country_year_country_code == "PRT" ~ "Portugal",
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
  mutate(u_complab_country_year_country_code = case_when(
    u_complab_country_year_country == "Italy_adjusted" ~ "ITL_adj",
    u_complab_country_year_country == "Norway_adjusted" ~ "NOR_adj",
    TRUE ~ u_complab_country_year_country_code
  )) %>%
  mutate(u_complab_country_year_country = case_when(
    u_complab_country_year_country == "Slovak Republic" ~ "Slovakia",
    u_complab_country_year_country == "Korea, Rep." ~ "South Korea",
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

# Final check for duplicates in column names
no_duplicate_names(complab_spin_samip)

# For now remove country_nr bc not all complab datasets have a country_nr column
complab_spin_samip %<>% select(-u_complab_country_year_country_nr)

#save
write_dataset(complab_spin_samip, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets/complab_spin_samip_cleaned.rds"),
           tag= "complab_spin_samip",
           overwrite = TRUE)