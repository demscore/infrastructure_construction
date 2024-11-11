library(dplyr)
library(demutils)

db <- pg_connect()

repdem_pot_coal_pastr <- read_datasets("repdem_pot_coal_pastr", db, original = TRUE)

# Clean column names
names(repdem_pot_coal_pastr) <- clean_column_names(names(repdem_pot_coal_pastr))

# Duplicates check to identify units
no_duplicates(repdem_pot_coal_pastr, c("cab_id", "potential_coalition")) #TRUE

# Create unit columns and add a country_name column
repdem_pot_coal_pastr$u_repdem_cabinet_pot_coal_cab_id <- 
  repdem_pot_coal_pastr$cab_id

repdem_pot_coal_pastr$u_repdem_cabinet_pot_coal_coalition <- 
  repdem_pot_coal_pastr$potential_coalition

repdem_pot_coal_pastr %<>%
  mutate(u_repdem_cabinet_pot_coal_country = case_when(
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
no_duplicate_names(repdem_pot_coal_pastr)

write_dataset(repdem_pot_coal_pastr, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/repdem/cleaned_datasets/repdem_pot_coal_pastr_cleaned.rds"),
              tag = "repdem_pot_coal_pastr",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(repdem_pot_coal_pastr,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_dta/repdem_pot_coal_pastr_cleaned.dta"),
           overwrite = TRUE)

write_file(repdem_pot_coal_pastr,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_csv/repdem_pot_coal_pastr_cleaned.csv"),
           overwrite = TRUE)