library(dplyr)
library(demutils)

db <- pg_connect()

repdem_paged_pastr <- read_datasets("repdem_paged_pastr", db, original = TRUE)

# Clean column names
names(repdem_paged_pastr) <- clean_column_names(names(repdem_paged_pastr))

# Duplicates check to identify units
no_duplicates(repdem_paged_pastr, c("cab_name", "date_in")) #TRUE
no_duplicates(repdem_paged_pastr, c("country_id", "date_in")) #TRUE

# Create unit columns
repdem_paged_pastr$country_name <- repdem_paged_pastr$country_id

repdem_paged_pastr$u_repdem_cabinet_date_cab_name <- 
  repdem_paged_pastr$cab_name

repdem_paged_pastr$u_repdem_cabinet_date_date_in <- 
  as.Date(repdem_paged_pastr$date_in)

repdem_paged_pastr$u_repdem_cabinet_date_date_out <- 
  as.Date(repdem_paged_pastr$date_out)

repdem_paged_pastr$u_repdem_cabinet_date_country <- 
  repdem_paged_pastr$country_name

# Replace NAs in date_out column with the latest date in the column
repdem_paged_pastr$u_repdem_cabinet_date_date_out %<>%
  tidyr::replace_na(as.Date("2020-01-21", format = '%Y-%m-%d'))

# Create year unit columns based on in and out year
repdem_paged_pastr$u_repdem_cabinet_date_in_year <- 
  as.integer(format(repdem_paged_pastr$u_repdem_cabinet_date_date_in, "%Y"))

repdem_paged_pastr$u_repdem_cabinet_date_out_year <- 
  as.integer(format(repdem_paged_pastr$u_repdem_cabinet_date_date_out, "%Y"))

# Check for duplicates in column names
no_duplicate_names(repdem_paged_pastr)

write_dataset(repdem_paged_pastr, 
           file.path(Sys.getenv("ROOT_DIR"),
            "datasets/repdem/cleaned_datasets/repdem_paged_pastr_cleaned.rds"),
           tag = "repdem_paged_pastr",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(repdem_paged_pastr,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_dta/repdem_paged_pastr_cleaned.dta"),
           overwrite = TRUE)

write_file(repdem_paged_pastr,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/repdem/cleaned_datasets_csv/repdem_paged_pastr_cleaned.csv"),
           overwrite = TRUE)
