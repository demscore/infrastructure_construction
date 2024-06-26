library(dplyr)
library(demutils)

db <- pg_connect()

vdem_cd <- read_datasets("vdem_cd", db, original = TRUE)

# Clean column names
names(vdem_cd) <- clean_column_names(names(vdem_cd))

# Duplicates check to identify units
#no_duplicates(vdem_cd, c("country_name", "historical_date")) #TRUE
#no_duplicates(vdem_cd, c("cowcode", "historical_date")) #FALSE (bco Palestine, Hong-Kong and mainly historical country units)
#no_duplicates(vdem_cd, c("country_text_id", "historical_date")) #TRUE
#no_duplicates(vdem_cd, c("country_id", "historical_date")) # TRUE

# Check for and remove multiple classes
vdem_cd <- remove_idate_class(vdem_cd)
v <- check_multiple_classes(vdem_cd)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Create unit columns
vdem_cd$u_vdem_country_date_country_name <- 
  vdem_cd$country_name

vdem_cd$u_vdem_country_date_country_text_id <- 
  vdem_cd$country_text_id

vdem_cd$u_vdem_country_date_date <-
  vdem_cd$historical_date

vdem_cd$u_vdem_country_date_cowcode <- 
  as.integer(vdem_cd$cowcode)

vdem_cd$u_vdem_country_date_cowcode[is.na(vdem_cd$u_vdem_country_date_cowcode)] <- 
  as.integer(-11111)

# Replace NAs
vdem_cd[is.na(vdem_cd)] <- -11111

# Save
write_dataset(vdem_cd,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/vdem/cleaned_datasets/vdem_cd_cleaned.rds"),
           tag = "vdem_cd",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(vdem_cd,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/vdem/cleaned_datasets_dta/vdem_cd_cleaned.dta"),
           overwrite = TRUE)

write_file(vdem_cd,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/vdem/cleaned_datasets_csv/vdem_cd_cleaned.csv"),
           overwrite = TRUE)