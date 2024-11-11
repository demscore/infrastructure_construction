library(dplyr)
library(demutils)

db <- pg_connect()

complab_spin_scip <- read_datasets("complab_spin_scip", db, original = TRUE)

# Clean column names
names(complab_spin_scip) <- clean_column_names(names(complab_spin_scip))

# Creat unit identifiers
complab_spin_scip$country <- as.numeric(complab_spin_scip$country)

complab_spin_scip %<>%
mutate(u_complab_country_year_country_code = case_when(
        country == 1 ~ "AUS",
        country == 2 ~ "AUT",
        country == 3 ~ "BEL",
        country == 4 ~ "CAN",
        country == 5 ~ "DNK",
        country == 6 ~ "FIN",
        country == 7 ~ "FRA",
        country == 8 ~ "DEU",
        country == 9 ~ "IRL",
        country == 10 ~ "ITA",
        country == 11 ~ "JPN",
        country == 12 ~ "NLD",
        country == 13 ~ "NZL",
        country == 14 ~ "NOR",
        country == 15 ~ "SWE",
        country == 16 ~ "CHE",
        country == 17 ~ "GBR",
        country == 18 ~ "USA",
        TRUE ~ as.character(country)
)) %>%
  mutate(u_complab_country_year_country_nr = case_when(
    country == 1 ~ 36,
    country == 2 ~ 40,
    country == 3 ~ 56,
    country == 4 ~ 124,
    country == 5 ~ 208,
    country == 6 ~ 246,
    country == 7 ~ 250,
    country == 8 ~ 276,
    country == 9 ~ 372,
    country == 10 ~ 380,
    country == 11 ~ 392,
    country == 12 ~ 528,
    country == 13 ~ 554,
    country == 14 ~ 578,
    country == 15 ~ 752,
    country == 16 ~ 756,
    country == 17 ~ 826,
    country == 18 ~ 840,
    TRUE ~ as.numeric(country)
  ))

# Add column country_fname (fullname) to not only have the character and numeric
# codes in the unit table, but also the full country names on which the dataset is translated
complab_spin_scip %<>% 
  mutate(u_complab_country_year_country = case_when(
    u_complab_country_year_country_code == "AUS" ~ "Australia",
    u_complab_country_year_country_code == "AUT" ~ "Austria",
    u_complab_country_year_country_code == "BEL" ~ "Belgium",
    u_complab_country_year_country_code == "BGR" ~ "Bulgaria",
    u_complab_country_year_country_code == "CAN" ~ "Canada",
    u_complab_country_year_country_code == "CYP" ~ "Cyprus",
    u_complab_country_year_country_code == "CZE" ~ "Czech Republic",
    u_complab_country_year_country_code == "DNK" ~ "Denmark",
    u_complab_country_year_country_code == "EST" ~ "Estonia",
    u_complab_country_year_country_code == "FIN" ~ "Finland",
    u_complab_country_year_country_code == "FRA" ~ "France",
    u_complab_country_year_country_code == "DEU" ~ "Germany",
    u_complab_country_year_country_code == "GRC" ~ "Greece",
    u_complab_country_year_country_code == "HUN" ~ "Hungary",
    u_complab_country_year_country_code == "ISL" ~ "Iceland",
    u_complab_country_year_country_code == "IRL" ~ "Ireland",
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
    TRUE ~ u_complab_country_year_country_code))


complab_spin_scip$u_complab_country_year_year <- 
  as.integer(complab_spin_scip$year)

# Add country_code and country_nr to dataset to have synchronized country variables across all complab datasets in demscore. This is a change to the original dataset!

complab_spin_scip$country_code <- 
  complab_spin_scip$u_complab_country_year_country_code
  
complab_spin_scip$country_nr <- 
  complab_spin_scip$u_complab_country_year_country_nr

# Duplicates check to identify units
no_duplicates(complab_spin_scip, c("country", "year")) #TRUE
no_duplicates(complab_spin_scip, c("u_complab_country_year_country_code", "year")) #TRUE
no_duplicates(complab_spin_scip, c("u_complab_country_year_country_nr", "year")) #TRUE
no_duplicates(complab_spin_scip, c("u_complab_country_year_country", "year")) #TRUE

complab_spin_scip %<>% select(-country_nr, -country_code)

# Final check for duplicates in column names
no_duplicate_names(complab_spin_scip)


write_dataset(complab_spin_scip, 
           file.path(Sys.getenv("ROOT_DIR"),
            "datasets/complab/cleaned_datasets/complab_spin_scip_cleaned.rds"),
           tag = "complab_spin_scip",
           overwrite = TRUE)
