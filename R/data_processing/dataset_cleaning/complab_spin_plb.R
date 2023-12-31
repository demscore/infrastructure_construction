library(dplyr)
library(demutils)

db <- pg_connect()

complab_spin_plb <- read_datasets("complab_spin_plb", db, original = TRUE)

# Adjust variables in first row
names(complab_spin_plb) <- complab_spin_plb %>% slice(1) %>% unlist()
complab_spin_plb <- complab_spin_plb %>% slice(-1)

# Re-saving original dataset with unchanged column names, but without the additional first row.
saveRDS(complab_spin_plb, file.path(Sys.getenv("ROOT_DIR"), "datasets/complab/SPIN/complab_spin_plb_original.rds"))

# Clean column names
names(complab_spin_plb) <- clean_column_names(names(complab_spin_plb))

# Rename country variable to 'synchronize' complab country variable names in demscore
# The column storing numeric ids is renamed to country_nr (unless that is not the name already),
# and the column storing the country abbreviation character code is renamed to country_code

complab_spin_plb %<>% rename(country_code = country) %>%
  rename(country_nr = country_number_iso)

# Duplicates check to identify units
no_duplicates(complab_spin_plb, c("country_nr", "year")) #TRUE
no_duplicates(complab_spin_plb, c("country_code", "year")) #TRUE


# Create duplicate unit columns
complab_spin_plb$u_complab_country_year_country_nr <- 
  as.numeric(complab_spin_plb$country_nr)

complab_spin_plb$u_complab_country_year_country_code <- 
  complab_spin_plb$country_code

complab_spin_plb$u_complab_country_year_year <- 
  as.integer(complab_spin_plb$year)

# Add column country_fname (fullname) to not only have the character and numeric
# codes in the unit table, but also the full country names on which the dataset is translated
complab_spin_plb %<>% 
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

# Final check for duplicates in column names
no_duplicate_names(complab_spin_plb)

# Save dataset
write_dataset(complab_spin_plb, 
           file.path(Sys.getenv("ROOT_DIR"),
            "datasets/complab/cleaned_datasets/complab_spin_plb_cleaned.rds"),
           tag = "complab_spin_plb",
           overwrite = TRUE)