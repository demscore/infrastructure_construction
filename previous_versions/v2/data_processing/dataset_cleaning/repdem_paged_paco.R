library(dplyr)
library(demutils)

db <- pg_connect()

repdem_paged_paco <- read_datasets("repdem_paged_paco", db, original = TRUE)

# Clean column names
names(repdem_paged_paco) <- clean_column_names(names(repdem_paged_paco))

# Duplicates check to identify units
no_duplicates(repdem_paged_paco, c("cab_name", "date_in")) #TRUE
no_duplicates(repdem_paged_paco, c("country_id", "date_in")) #TRUE

# Create unit columns and add a country_name column
repdem_paged_paco$u_repdem_cabinet_date_cab_name <- 
  repdem_paged_paco$cab_name

repdem_paged_paco$u_repdem_cabinet_date_date_in <- 
  as.Date(repdem_paged_paco$date_in)

repdem_paged_paco$u_repdem_cabinet_date_date_out <- 
  as.Date(repdem_paged_paco$date_out)

repdem_paged_paco %<>%
  mutate(u_repdem_cabinet_date_country = case_when(
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

# Replace NAs in date_out column with the latest date in the column
repdem_paged_paco$u_repdem_cabinet_date_date_out %<>%
  tidyr::replace_na(as.Date("2020-01-21", format = '%Y-%m-%d'))

# Create year unit columns based on in and out year
repdem_paged_paco$u_repdem_cabinet_date_in_year <- 
  as.integer(format(repdem_paged_paco$u_repdem_cabinet_date_date_in, "%Y"))

repdem_paged_paco$u_repdem_cabinet_date_out_year <- 
  as.integer(format(repdem_paged_paco$u_repdem_cabinet_date_date_out, "%Y"))

# Check for duplicates in column names
no_duplicate_names(repdem_paged_paco)

write_dataset(repdem_paged_paco, 
           file.path(Sys.getenv("ROOT_DIR"),
            "datasets/repdem/cleaned_datasets/repdem_paged_paco_cleaned.rds"),
           tag = "repdem_paged_paco",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(repdem_paged_paco,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_dta/repdem_paged_paco_cleaned.dta"),
           overwrite = TRUE)

write_file(repdem_paged_paco,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_csv/repdem_paged_paco_cleaned.csv"),
           overwrite = TRUE)
