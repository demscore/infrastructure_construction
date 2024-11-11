library(dplyr)
library(demutils)

db <- pg_connect()

repdem_wecee_year <- read_datasets("repdem_wecee_year", db, original = TRUE)

# Clean column names
names(repdem_wecee_year) <- clean_column_names(names(repdem_wecee_year))

# Duplicates check to identify units
no_duplicates(repdem_wecee_year, c("cab_name", "year")) #TRUE

# Check for and remove multiple classes
repdem_wecee_year <- remove_idate_class(repdem_wecee_year)
v <- check_multiple_classes(repdem_wecee_year)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Exclude duplicate rows
repdem_wecee_year %<>% distinct(cab_name, cab_id, year, .keep_all = TRUE)

# Create unit columns and add a country_name column
repdem_wecee_year$u_repdem_cabinet_year_cab_id <- 
  repdem_wecee_year$cab_id

repdem_wecee_year$u_repdem_cabinet_year_cab_name <- 
  repdem_wecee_year$cab_name

repdem_wecee_year$u_repdem_cabinet_year_year <- 
  as.character(repdem_wecee_year$year)

repdem_wecee_year$u_repdem_cabinet_year_country <-
  repdem_wecee_year$country_name

repdem_wecee_year$u_repdem_cabinet_year_unique_id <- 
  repdem_wecee_year$unique_id

repdem_wecee_year %<>%
  mutate(country_id = case_when(
    country_name == "Austria" ~ "1",
    country_name == "Belgium" ~ "2",
    country_name == "Denmark" ~ "3",
    country_name == "Finland" ~ "4",
    country_name == "France" ~ "5",
    country_name == "Germany" ~ "6",
    country_name == "Greece" ~ "7",
    country_name == "Iceland" ~ "8",
    country_name == "Ireland" ~ "9",
    country_name == "Italy" ~ "10",
    country_name == "Luxembourg" ~ "11",
    country_name == "Netherlands" ~ "12",
    country_name == "Norway" ~ "13",
    country_name == "Portugal" ~ "14",
    country_name == "Spain" ~ "15",
    country_name == "Sweden" ~ "16",
    country_name == "United Kingdom" ~ "17",
    country_name == "Bulgaria" ~ "18",
    country_name == "Cyprus" ~ "19",
    country_name == "Czechia" ~ "20",
    country_name == "Estonia" ~ "21",
    country_name == "Hungary" ~ "22",
    country_name == "Latvia" ~ "23",
    country_name == "Lithuania" ~ "24",
    country_name == "Malta" ~ "25",
    country_name == "Poland" ~ "26",
    country_name == "Romania" ~ "27",
    country_name == "Slovakia" ~ "28",
    country_name == "Slovenia" ~ "29",
    country_name == "Croatia" ~ "30",
    TRUE ~ as.character(country_name)
  ))

repdem_wecee_year %<>% filter(!is.na(u_repdem_cabinet_year_year))

# Check for duplicates in column names
no_duplicate_names(repdem_wecee_year)

write_dataset(repdem_wecee_year, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/repdem/cleaned_datasets/repdem_wecee_year_cleaned.rds"),
              tag = "repdem_wecee_year",
              overwrite = TRUE)
