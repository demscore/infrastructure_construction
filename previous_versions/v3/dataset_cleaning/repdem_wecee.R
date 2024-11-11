library(dplyr)
library(demutils)

db <- pg_connect()

repdem_wecee <- read_datasets("repdem_wecee", db, original = TRUE)

# Clean column names
names(repdem_wecee) <- clean_column_names(names(repdem_wecee))

# Duplicates check to identify units
no_duplicates(repdem_wecee, c("cab_name", "date_in")) #TRUE
no_duplicates(repdem_wecee, c("country_id", "date_in")) #TRUE

# Check for and remove multiple classes
repdem_wecee <- remove_idate_class(repdem_wecee)
v <- check_multiple_classes(repdem_wecee)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Create unit columns
repdem_wecee$u_repdem_cabinet_date_cab_name <- 
  repdem_wecee$cab_name

repdem_wecee$u_repdem_cabinet_date_date_in <- 
  as.Date(repdem_wecee$date_in)

repdem_wecee$u_repdem_cabinet_date_date_out <- 
  as.Date(repdem_wecee$date_out)

repdem_wecee$u_repdem_cabinet_date_country <- 
  repdem_wecee$country_name

# Replace NAs in date_out column with the latest date in the column
repdem_wecee$u_repdem_cabinet_date_date_out %<>%
  tidyr::replace_na(as.Date("2023-06-26", format = '%Y-%m-%d'))

# Create year unit columns based on in and out year
repdem_wecee$u_repdem_cabinet_date_in_year <- 
  as.integer(format(repdem_wecee$u_repdem_cabinet_date_date_in, "%Y"))

repdem_wecee$u_repdem_cabinet_date_out_year <- 
  as.integer(format(repdem_wecee$u_repdem_cabinet_date_date_out, "%Y"))

repdem_wecee %<>% filter(!is.na(country_id))

# Check for duplicates in column names
no_duplicate_names(repdem_wecee)

write_dataset(repdem_wecee, 
           file.path(Sys.getenv("ROOT_DIR"),
            "datasets/repdem/cleaned_datasets/repdem_wecee_cleaned.rds"),
           tag = "repdem_wecee",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(repdem_wecee,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_dta/repdem_wecee_cleaned.dta"),
           overwrite = TRUE)

write_file(repdem_wecee,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_csv/repdem_wecee_cleaned.csv"),
           overwrite = TRUE)
