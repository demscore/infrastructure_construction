library(dplyr)
library(demutils)

db <- pg_connect()

repdem_pastr_year <- read_datasets("repdem_pastr_year", db, original = TRUE)

# Clean column names
names(repdem_pastr_year) <- clean_column_names(names(repdem_pastr_year))

# Duplicates check to identify units
no_duplicates(repdem_pastr_year, c("cab_name", "year")) #TRUE

# Exclude duplicate rows
repdem_pastr_year %<>% distinct(cab_name, cab_id, year, .keep_all = TRUE)

# Create unit columns and add a country_name column
repdem_pastr_year$u_repdem_cabinet_year_cab_name <- 
  repdem_pastr_year$cab_name

repdem_pastr_year$u_repdem_cabinet_year_year <- 
  format(as.Date(repdem_pastr_year$year, format="%Y-%m-%d"),"%Y")

repdem_pastr_year %<>%
  mutate(u_repdem_cabinet_year_country = case_when(
    country_id == "1" ~ "Austria",
    country_id == "2" ~ "Belgium",
    country_id == "3" ~ "Denmark",
    country_id == "4" ~ "Finland",
    country_id == "5" ~ "France",
    country_id == "6" ~ "Germany",
    country_id == "7" ~ "Greece",
    country_id == "8" ~ "Iceland",
    country_id == "9" ~ "Ireland",
    country_id == "10" ~ "Italy",
    country_id == "11" ~ "Luxembourg",
    country_id == "12" ~ "the Netherlands",
    country_id == "13" ~ "Norway",
    country_id == "14" ~ "Portugal",
    country_id == "15" ~ "Spain",
    country_id == "16" ~ "Sweden",
    country_id == "17" ~ "United Kingdom",
    country_id == "18" ~ "Bulgaria",
    country_id == "19" ~ "Cyprus",
    country_id == "20" ~ "Czech Republic",
    country_id == "21" ~ "Estonia",
    country_id == "22" ~ "Hungary",
    country_id == "23" ~ "Latvia",
    country_id == "24" ~ "Lithuania",
    country_id == "25" ~ "Malta",
    country_id == "26" ~ "Poland",
    country_id == "27" ~ "Romania",
    country_id == "28" ~ "Slovakia",
    country_id == "29" ~ "Slovenia",
    country_id == "30" ~ "Croatia",
    TRUE ~ as.character(country_id)
  ))

# Check for duplicates in column names
no_duplicate_names(repdem_pastr_year)

write_dataset(repdem_pastr_year, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/repdem/cleaned_datasets/repdem_pastr_year_cleaned.rds"),
              tag = "repdem_pastr_year",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(repdem_pastr_year,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_dta/repdem_pastr_year_cleaned.dta"),
           overwrite = TRUE)

write_file(repdem_pastr_year,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_csv/repdem_pastr_year_cleaned.csv"),
           overwrite = TRUE)