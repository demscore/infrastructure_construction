library(dplyr)
library(demutils)

db <- pg_connect()

repdem_basic_quarter <- read_datasets("repdem_basic_quarter", db, original = TRUE)

# Clean column names
names(repdem_basic_quarter) <- clean_column_names(names(repdem_basic_quarter))

# Duplicates check to identify units
no_duplicates(repdem_basic_quarter, c("cab_id", "quarter")) #TRUE

# Check for and remove multiple classes
repdem_basic_quarter <- remove_idate_class(repdem_basic_quarter)
v <- check_multiple_classes(repdem_basic_quarter)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Create unit columns and add a country_name column
repdem_basic_quarter$u_repdem_cabinet_quarter_cab_name <- 
  repdem_basic_quarter$cab_name

repdem_basic_quarter$u_repdem_cabinet_quarter_quarter <- 
  repdem_basic_quarter$quarter

repdem_basic_quarter$u_repdem_cabinet_quarter_year <- 
  repdem_basic_quarter$year_in

repdem_basic_quarter$u_repdem_cabinet_quarter_unique_id <- 
  repdem_basic_quarter$unique_id

repdem_basic_quarter %<>%
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

repdem_basic_quarter %<>%
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

# Check for duplicates in column names
#no_duplicate_names(repdem_basic_quarter)

write_dataset(repdem_basic_quarter, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/repdem/cleaned_datasets/repdem_basic_quarter_cleaned.rds"),
              tag = "repdem_basic_quarter",
              overwrite = TRUE)