library(dplyr)
library(demutils)

db <- pg_connect()

repdem_wecee_month <- read_datasets("repdem_wecee_month", db, original = TRUE)

# Clean column names
names(repdem_wecee_month) <- clean_column_names(names(repdem_wecee_month))

# Duplicates check to identify units
no_duplicates(repdem_wecee_month, c("cab_id", "month")) #TRUE

# Check for and remove multiple classes
repdem_wecee_month <- remove_idate_class(repdem_wecee_month)
v <- check_multiple_classes(repdem_wecee_month)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Create unit columns and add a country_name column
repdem_wecee_month$u_repdem_cabinet_month_cab_id <- 
  repdem_wecee_month$cab_id

repdem_wecee_month$u_repdem_cabinet_month_cab_name <- 
  repdem_wecee_month$cab_name

repdem_wecee_month$u_repdem_cabinet_month_month <- 
  repdem_wecee_month$month

repdem_wecee_month$u_repdem_cabinet_month_year <- 
  repdem_wecee_month$year_in

repdem_wecee_month$u_repdem_cabinet_month_country <- 
  repdem_wecee_month$country_name

repdem_wecee_month$u_repdem_cabinet_month_unique_id <- 
  repdem_wecee_month$unique_id
  
# Country_name and country_id have the same values in the original dataset
repdem_wecee_month %<>%
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
    country_name == "the Netherlands" ~ "12",
    country_name == "Norway" ~ "13",
    country_name == "Portugal" ~ "14",
    country_name == "Spain" ~ "15",
    country_name == "Sweden" ~ "16",
    country_name == "United Kingdom" ~ "17",
    country_name == "Bulgaria" ~ "18",
    country_name == "Cyprus" ~ "19",
    country_name == "Czech Republic" ~ "20",
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

# Check for duplicates in column names
no_duplicate_names(repdem_wecee_month)

write_dataset(repdem_wecee_month, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/repdem/cleaned_datasets/repdem_wecee_month_cleaned.rds"),
              tag = "repdem_wecee_month",
              overwrite = TRUE)