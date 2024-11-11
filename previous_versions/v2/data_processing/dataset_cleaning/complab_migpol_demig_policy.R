library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_demig_policy <- read_datasets("complab_migpol_demig_policy", db, original = TRUE)

# Clean column names
names(complab_migpol_demig_policy) <- clean_column_names(names(complab_migpol_demig_policy))

# There are 46 duplicates for the combination of country, year and policy. Hence,
# we add (row_a) and (row_b) to the demig_summary variable, to be able to use
# country-year-policy as unique identifiers for rows in the dataset.
# We also need to add the missing country names for iso2 == "DD", "YU" and "CS" as 
# our code doesn ot allow missing values in columns from which unit identifiers are
# created.

complab_migpol_demig_policy %<>% group_by(summary) %>%
  mutate(policy_count = row_number()) %>%
  mutate(summary = case_when(
    policy_count == 1 ~ paste0(summary, " (row_a)"),
    policy_count == 2 ~ paste0(summary, " (row_b)"),
    TRUE ~ summary 
  )) %>% 
  ungroup() %>%
  select(-policy_count) %>%
  mutate(iso3 = case_when(
    iso2 == "YU" ~ "YUG",
    iso2 == "CS" ~ "SCG",
    iso2 == "DD" ~ "DDR",
    TRUE ~ iso2
  )) %>%
  mutate(country_full_name = case_when(
    iso2 == "YU" ~ "Yugoslavia",
    iso2 == "CS" ~ "Czechoslovakia",
    iso2 == "DD" ~ "German Democratic Republic",
    TRUE ~ iso2
  ))

no_duplicates(complab_migpol_demig_policy, c("country_full_name", "year", "summary"))


# Create unit columns
complab_migpol_demig_policy$u_complab_country_year_policy_country <- 
  complab_migpol_demig_policy$country_full_name

complab_migpol_demig_policy$u_complab_country_year_policy_country_code <- 
  complab_migpol_demig_policy$iso3

complab_migpol_demig_policy$u_complab_country_year_policy_year <- 
  as.integer(complab_migpol_demig_policy$year)

complab_migpol_demig_policy$u_complab_country_year_policy_policy <- 
  complab_migpol_demig_policy$summary

complab_migpol_demig_policy %<>%
  mutate(u_complab_country_year_policy_country = case_when(
    u_complab_country_year_policy_country == "Slovak Republic" ~ "Slovakia",
    u_complab_country_year_policy_country == "Korea, Rep." ~ "South Korea",
    u_complab_country_year_policy_country == "Korea" ~ "South Korea",
    u_complab_country_year_policy_country == "HRV" ~ "Croatia",
    u_complab_country_year_policy_country == "Russian Federation" ~ "Russia",
    u_complab_country_year_policy_country == "Czech Republic" ~ "Czechia",
    u_complab_country_year_policy_country_code == "XKX" ~ "Kosovo",
    TRUE ~ u_complab_country_year_policy_country
  )) %>%
  mutate(u_complab_country_year_policy_country_code = case_when(
    u_complab_country_year_policy_country_code == "Slovak Republic" ~ "SVK",
    u_complab_country_year_policy_country_code == "Croatia" ~ "HRV",
    u_complab_country_year_policy_country_code == "BUL" ~ "BGR",
    u_complab_country_year_policy_country_code == "GRE" ~ "GRC",
    u_complab_country_year_policy_country_code == "IRE" ~ "IRL",
    u_complab_country_year_policy_country_code == "POR" ~ "PRT",
    TRUE ~ u_complab_country_year_policy_country_code
  )) 

complab_migpol_demig_policy$u_complab_country_year_policy_country <- 
  gsub("&amp;", "\\&", complab_migpol_demig_policy$u_complab_country_year_policy_country)

# Final check for duplicates in column names
no_duplicate_names(complab_migpol_demig_policy)


write_dataset(complab_migpol_demig_policy,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_migpol_demig_policy_cleaned.rds"),
              tag = "complab_migpol_demig_policy",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(complab_migpol_demig_policy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets_dta/complab_migpol_demig_policy_cleaned.dta"),
           overwrite = TRUE)

write_file(complab_migpol_demig_policy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/complab/cleaned_datasets_csv/complab_migpol_demig_policy_cleaned.csv"),
           overwrite = TRUE)
