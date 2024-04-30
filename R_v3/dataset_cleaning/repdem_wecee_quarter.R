library(dplyr)
library(demutils)

db <- pg_connect()

repdem_wecee_quarter <- read_datasets("repdem_wecee_quarter", db, original = TRUE)

# Clean column names
names(repdem_wecee_quarter) <- clean_column_names(names(repdem_wecee_quarter))

# Duplicates check to identify units
no_duplicates(repdem_wecee_quarter, c("cab_id", "quarter")) #TRUE

# Check for and remove multiple classes
repdem_wecee_quarter <- remove_idate_class(repdem_wecee_quarter)
v <- check_multiple_classes(repdem_wecee_quarter)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Create unit columns and add a country_name column
repdem_wecee_quarter$u_repdem_cabinet_quarter_cab_name <- 
  repdem_wecee_quarter$cab_name

repdem_wecee_quarter$u_repdem_cabinet_quarter_quarter <- 
  repdem_wecee_quarter$quarter

repdem_wecee_quarter$u_repdem_cabinet_quarter_year <- 
  repdem_wecee_quarter$year_in

repdem_wecee_quarter %<>%
  mutate(u_repdem_cabinet_quarter_country = case_when(
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
    country_id == "12" ~ "Netherlands",
    country_id == "13" ~ "Norway",
    country_id == "14" ~ "Portugal",
    country_id == "15" ~ "Spain",
    country_id == "16" ~ "Sweden",
    country_id == "17" ~ "United Kingdom",
    country_id == "18" ~ "Bulgaria",
    country_id == "19" ~ "Cyprus",
    country_id == "20" ~ "Czechia",
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
#no_duplicate_names(repdem_wecee_quarter)

write_dataset(repdem_wecee_quarter, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/repdem/cleaned_datasets/repdem_wecee_quarter_cleaned.rds"),
              tag = "repdem_wecee_quarter",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(repdem_wecee_quarter,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_dta/repdem_wecee_quarter_cleaned.dta"),
           overwrite = TRUE)

write_file(repdem_wecee_quarter,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_csv/repdem_wecee_quarter_cleaned.csv"),
           overwrite = TRUE)