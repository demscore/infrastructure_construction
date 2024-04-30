library(dplyr)
library(demutils)

db <- pg_connect()

repdem_basic_year <- read_datasets("repdem_basic_year", db, original = TRUE)

# Clean column names
names(repdem_basic_year) <- clean_column_names(names(repdem_basic_year))

# Duplicates check to identify units
no_duplicates(repdem_basic_year, c("cab_id", "year")) #TRUE

# Check for and remove multiple classes
repdem_basic_year <- remove_idate_class(repdem_basic_year)
v <- check_multiple_classes(repdem_basic_year)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Create unit columns and add a country_name column
repdem_basic_year$u_repdem_cabinet_year_cab_id <- 
  repdem_basic_year$cab_id

repdem_basic_year$u_repdem_cabinet_year_cab_name <- 
  repdem_basic_year$cab_name

repdem_basic_year$u_repdem_cabinet_year_year <- 
  as.character(repdem_basic_year$year)

repdem_basic_year %<>%
  mutate(country_name = case_when(
    country_name == "the Netherlands" ~ "Netherlands",
    TRUE ~ as.character(country_name)
  ))

repdem_basic_year$u_repdem_cabinet_year_country <- 
  repdem_basic_year$country_name


# Check for duplicates in column names
no_duplicate_names(repdem_basic_year)

write_dataset(repdem_basic_year, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/repdem/cleaned_datasets/repdem_basic_year_cleaned.rds"),
              tag = "repdem_basic_year",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(repdem_basic_year,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_dta/repdem_basic_year_cleaned.dta"),
           overwrite = TRUE)

write_file(repdem_basic_year,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_csv/repdem_basic_year_cleaned.csv"),
           overwrite = TRUE)