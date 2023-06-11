library(dplyr)
library(demutils)

db <- pg_connect()

repdem_parties_paco <- read_datasets("repdem_parties_paco", db, original = TRUE)
repdem_parties_pastr <- read_datasets("repdem_parties_pastr", db, original = TRUE)
# Clean column names
names(repdem_parties_paco) <- clean_column_names(names(repdem_parties_paco))

# Duplicates check to identify units
no_duplicates(repdem_parties_paco, c("cab_name", "party_id")) #TRUE

# Create unit columns and add a country_name column
repdem_parties_paco$u_repdem_cabinet_party_cab_name <- 
  repdem_parties_paco$cab_name

repdem_parties_paco$u_repdem_cabinet_party_partycode <- 
  as.character(repdem_parties_paco$party_id)

repdem_parties_paco$u_repdem_cabinet_party_partycode[is.na(repdem_parties_paco$u_repdem_cabinet_party_partycode)] <- -11111

repdem_parties_paco$u_repdem_cabinet_party_partystr <- 
  as.character(repdem_parties_pastr$party_id)

repdem_parties_paco$u_repdem_cabinet_party_partystr[is.na(repdem_parties_paco$u_repdem_cabinet_party_partystr)] <- -11111

repdem_parties_paco$u_repdem_cabinet_party_year <- 
  format(as.Date(repdem_parties_paco$elecdate, format="%Y-%m-%d"),"%Y")

repdem_parties_paco$u_repdem_cabinet_party_year <- 
  as.integer(repdem_parties_paco$u_repdem_cabinet_party_year)

repdem_parties_paco %<>%
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
# no_duplicate_names(repdem_parties_paco)

write_dataset(repdem_parties_paco, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/repdem/cleaned_datasets/repdem_parties_paco_cleaned.rds"),
              tag = "repdem_parties_paco",
              overwrite = TRUE)
