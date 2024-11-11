library(dplyr)
library(demutils)

db <- pg_connect()

repdem_basic_potcoal <- read_datasets("repdem_basic_potcoal", db, original = TRUE)

df <- repdem_basic_potcoal %>% select(pcab_party18)

#Clean column names
names(repdem_basic_potcoal) <- clean_column_names(names(repdem_basic_potcoal))

# Duplicates check to identify units
# no_duplicates(repdem_basic_potcoal, c("cab_id", "potential_government")) #TRUE

# Check for and remove multiple classes
repdem_basic_potcoal <- remove_idate_class(repdem_basic_potcoal)
v <- check_multiple_classes(repdem_basic_potcoal)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Create unit columns and add a country_name column
repdem_basic_potcoal$u_repdem_cabinet_pot_coal_cab_id <- 
  repdem_basic_potcoal$cab_id

repdem_basic_potcoal$u_repdem_cabinet_pot_coal_government <- 
  repdem_basic_potcoal$potential_government

repdem_basic_potcoal$u_repdem_cabinet_pot_coal_unique_id <- 
  repdem_basic_potcoal$unique_id

repdem_basic_potcoal %<>%
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
# no_duplicate_names(repdem_basic_potcoal) #TRUE

write_dataset(repdem_basic_potcoal, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/repdem/cleaned_datasets/repdem_basic_potcoal_cleaned.rds"),
              tag = "repdem_basic_potcoal",
              overwrite = TRUE)