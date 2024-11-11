library(dplyr)
library(demutils)

db <- pg_connect()

repdem_basic <- read_datasets("repdem_basic", db, original = TRUE)

# Clean column names
names(repdem_basic) <- clean_column_names(names(repdem_basic))

# Duplicates check to identify units
no_duplicates(repdem_basic, c("cab_name", "date_in")) #TRUE
no_duplicates(repdem_basic, c("country_id", "date_in")) #TRUE

# Check for and remove multiple classes
repdem_basic <- remove_idate_class(repdem_basic)
v <- check_multiple_classes(repdem_basic)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Create unit columns and add a country_name column
repdem_basic$u_repdem_cabinet_date_cab_name <- 
  repdem_basic$cab_name

repdem_basic$u_repdem_cabinet_date_date_in <- 
  as.Date(repdem_basic$date_in)

repdem_basic$u_repdem_cabinet_date_date_out <- 
  as.Date(repdem_basic$date_out)

repdem_basic$u_repdem_cabinet_date_country <- 
  repdem_basic$country_name

repdem_basic$u_repdem_cabinet_date_unique_id <- 
  repdem_basic$unique_id

# Replace NAs in date_out column with the latest date in the column
repdem_basic$u_repdem_cabinet_date_date_out %<>%
  tidyr::replace_na(as.Date("2023-06-26", format = '%Y-%m-%d'))

# Create year unit columns based on in and out year
repdem_basic$u_repdem_cabinet_date_in_year <- 
  as.integer(format(repdem_basic$u_repdem_cabinet_date_date_in, "%Y"))

repdem_basic$u_repdem_cabinet_date_out_year <- 
  as.integer(format(repdem_basic$u_repdem_cabinet_date_date_out, "%Y"))

# Check for duplicates in column names
no_duplicate_names(repdem_basic)

write_dataset(repdem_basic, 
           file.path(Sys.getenv("ROOT_DIR"),
            "datasets/repdem/cleaned_datasets/repdem_basic_cleaned.rds"),
           tag = "repdem_basic",
           overwrite = TRUE)