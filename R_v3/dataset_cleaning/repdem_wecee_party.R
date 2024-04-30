library(dplyr)
library(demutils)

db <- pg_connect()

repdem_wecee_party <- read_datasets("repdem_wecee_party", db, original = TRUE)

# Clean column names
names(repdem_wecee_party) <- clean_column_names(names(repdem_wecee_party))

# Duplicates check to identify units
no_duplicates(repdem_wecee_party, c("cab_name", "party_id")) #TRUE

# Check for and remove multiple classes
repdem_wecee_party <- remove_idate_class(repdem_wecee_party)
v <- check_multiple_classes(repdem_wecee_party)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Create unit columns and add a country_name column
repdem_wecee_party$u_repdem_cabinet_party_cab_id <- 
  repdem_wecee_party$cab_id

repdem_wecee_party$u_repdem_cabinet_party_cab_name <- 
  repdem_wecee_party$cab_name

repdem_wecee_party$u_repdem_cabinet_party_partycode <- 
  as.character(repdem_wecee_party$party_id)

repdem_wecee_party$u_repdem_cabinet_party_partystr <- 
  as.character(repdem_wecee_party$party_abbr)

repdem_wecee_party$u_repdem_cabinet_party_year <- 
  format(as.Date(repdem_wecee_party$elecdate, format="%Y-%m-%d"),"%Y")

repdem_wecee_party$u_repdem_cabinet_party_year <- 
  as.integer(repdem_wecee_party$u_repdem_cabinet_party_year)


repdem_wecee_party %<>%
  mutate(u_repdem_cabinet_party_country = case_when(
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

repdem_wecee_party %<>% select(-country_name)

# Check for duplicates in column names
# no_duplicate_names(repdem_wecee_party)

write_dataset(repdem_wecee_party, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/repdem/cleaned_datasets/repdem_wecee_party_cleaned.rds"),
              tag = "repdem_wecee_party",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(repdem_wecee_party,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_dta/repdem_wecee_party_cleaned.dta"),
           overwrite = TRUE)

write_file(repdem_wecee_party,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_csv/repdem_wecee_party_cleaned.csv"),
           overwrite = TRUE)