library(dplyr)
library(demutils)

db <- pg_connect()

repdem_basic_party <- read_datasets("repdem_basic_party", db, original = TRUE)

# Exclude rows where cab_id has missing values 
exclude_cab_ids <- c(1805, 1807, 1813, 1815, 1817)

repdem_basic_party <- repdem_basic_party %>%
  filter(!(cab_id %in% exclude_cab_ids &
             if_any(c(party_id, 
                      party_abbr, 
                      elecdate, 
                      country_id), is.na)))

# Clean column names
names(repdem_basic_party) <- clean_column_names(names(repdem_basic_party))

# Duplicates check to identify units
 no_duplicates(repdem_basic_party, c("cab_name", "party_id")) #TRUE

# Check for and remove multiple classes
repdem_basic_party <- remove_idate_class(repdem_basic_party)
v <- check_multiple_classes(repdem_basic_party)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Create unit columns and add a country column
repdem_basic_party$u_repdem_cabinet_party_cab_id <- 
  repdem_basic_party$cab_id

repdem_basic_party$u_repdem_cabinet_party_cab_name <- 
  repdem_basic_party$cab_name

repdem_basic_party$u_repdem_cabinet_party_partycode <- 
  as.character(repdem_basic_party$party_id)

repdem_basic_party$u_repdem_cabinet_party_partystr <- 
  as.character(repdem_basic_party$party_abbr)

repdem_basic_party$u_repdem_cabinet_party_year <- 
  format(as.Date(repdem_basic_party$elecdate, format="%Y-%m-%d"),"%Y")

repdem_basic_party$u_repdem_cabinet_party_year <- 
  as.integer(repdem_basic_party$u_repdem_cabinet_party_year)

repdem_basic_party %<>%
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

# Check for duplicates in column names
 #no_duplicate_names(repdem_basic_party)

write_dataset(repdem_basic_party, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/repdem/cleaned_datasets/repdem_basic_party_cleaned.rds"),
              tag = "repdem_basic_party",
              overwrite = TRUE)