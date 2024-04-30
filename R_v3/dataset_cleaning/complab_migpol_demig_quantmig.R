library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_demig_quantmig <- read_datasets("complab_migpol_demig_quantmig", db, original = TRUE)
names(complab_migpol_demig_quantmig) <- gsub("demig_quantmig_", "", names(complab_migpol_demig_quantmig), perl = TRUE)

# Clean column names
names(complab_migpol_demig_quantmig) <- clean_column_names(names(complab_migpol_demig_quantmig))


# There are 46 duplicates for the combination of country, year and policy. Hence,
# we add (row_a) and (row_b) to the demig_summary variable, to be able to use
# country-year-policy as unique identifiers for rows in the dataset.
# We also need to add the missing country names for iso2 == "DD", "YU" and "CS" as 
# our code doesn ot allow missing values in columns from which unit identifiers are
# created.

complab_migpol_demig_quantmig %<>%
  mutate(iso3 = case_when(
    iso2 == "YU" ~ "YUG",
    iso2 == "CS" ~ "SCG",
    iso2 == "DD" ~ "DDR",
    TRUE ~ iso3
  )) %>%
  mutate(country_full_name = case_when(
    iso2 == "YU" ~ "Yugoslavia",
    iso2 == "CS" ~ "Czechoslovakia",
    iso2 == "DD" ~ "German Democratic Republic",
    TRUE ~ country_full_name
  ))

no_duplicates(complab_migpol_demig_quantmig, c("country_full_name", "year", "change_id"))


# Create unit columns
complab_migpol_demig_quantmig$u_complab_country_year_change_country <- 
  complab_migpol_demig_quantmig$country_full_name

complab_migpol_demig_quantmig$u_complab_country_year_change_country_code <- 
  complab_migpol_demig_quantmig$iso3

complab_migpol_demig_quantmig$u_complab_country_year_change_year <- 
  as.integer(complab_migpol_demig_quantmig$year)

complab_migpol_demig_quantmig$u_complab_country_year_change_change <- 
  complab_migpol_demig_quantmig$change_id


complab_migpol_demig_quantmig$u_complab_country_year_change_year[is.na(complab_migpol_demig_quantmig$u_complab_country_year_change_year)] <- -11111


complab_migpol_demig_quantmig %<>%
  mutate(u_complab_country_year_change_country = case_when(
    u_complab_country_year_change_country == "Slovak Republic" ~ "Slovakia",
    u_complab_country_year_change_country == "Korea, Rep." ~ "South Korea",
    u_complab_country_year_change_country == "Korea" ~ "South Korea",
    u_complab_country_year_change_country == "HRV" ~ "Croatia",
    u_complab_country_year_change_country == "Russian Federation" ~ "Russia",
    u_complab_country_year_change_country == "Czech Republic" ~ "Czechia",
    u_complab_country_year_change_country_code == "XKX" ~ "Kosovo",
    TRUE ~ u_complab_country_year_change_country
  )) %>%
  mutate(u_complab_country_year_change_country_code = case_when(
    u_complab_country_year_change_country_code == "Slovak Republic" ~ "SVK",
    u_complab_country_year_change_country_code == "Croatia" ~ "HRV",
    u_complab_country_year_change_country_code == "BUL" ~ "BGR",
    u_complab_country_year_change_country_code == "GRE" ~ "GRC",
    u_complab_country_year_change_country_code == "IRE" ~ "IRL",
    u_complab_country_year_change_country_code == "POR" ~ "PRT",
    TRUE ~ u_complab_country_year_change_country_code
  )) 


complab_migpol_demig_quantmig$u_complab_country_year_change_country <- 
  gsub("&amp;", "\\&", complab_migpol_demig_quantmig$u_complab_country_year_change_country)

# Final check for duplicates in column names
no_duplicate_names(complab_migpol_demig_quantmig)


write_dataset(complab_migpol_demig_quantmig,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_migpol_demig_quantmig_cleaned.rds"),
              tag = "complab_migpol_demig_quantmig",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(complab_migpol_demig_quantmig,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets_dta/complab_migpol_demig_quantmig_cleaned.dta"),
           overwrite = TRUE)

write_file(complab_migpol_demig_quantmig,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets_csv/complab_migpol_demig_quantmig_cleaned.csv"),
           overwrite = TRUE)
