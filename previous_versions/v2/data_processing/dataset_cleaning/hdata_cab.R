library(dplyr)
library(demutils)

db <- pg_connect()

hdata_cab <- read_datasets("hdata_cab", db, original = TRUE)

# Clean column names
names(hdata_cab) <- clean_column_names(names(hdata_cab))

# Duplicate columns for unit tables
hdata_cab$u_hdata_cabinet_date_cab_name <- 
  hdata_cab$cabname

hdata_cab$u_hdata_cabinet_date_cab_id <- 
  hdata_cab$cab_id

hdata_cab$u_hdata_cabinet_date_country <- 
  hdata_cab$country

hdata_cab$u_hdata_cabinet_date_vdem_country_id <- 
  hdata_cab$vdem_country_id

hdata_cab$u_hdata_cabinet_date_cow_country_id <- 
  hdata_cab$cow_country_id

hdata_cab$u_hdata_cabinet_date_date_in <- 
  as.Date(hdata_cab$date_in)

hdata_cab$u_hdata_cabinet_date_date_out <- 
  as.Date(hdata_cab$date_out)

# Create year unit columns based on in and out year
hdata_cab$u_hdata_cabinet_date_in_year <- 
  as.integer(format(hdata_cab$u_hdata_cabinet_date_date_in, "%Y"))

hdata_cab$u_hdata_cabinet_date_out_year <- 
  as.integer(format(hdata_cab$u_hdata_cabinet_date_date_out, "%Y"))

# Final duplicates check column names
no_duplicate_names(hdata_cab)


write_dataset(hdata_cab, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/hdata/cleaned_datasets/hdata_cab_cleaned.rds"),
              tag= "hdata_cab",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(hdata_cab,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/hdata/cleaned_datasets_dta/hdata_cab_cleaned.dta"),
           overwrite = TRUE)

write_file(hdata_cab,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/hdata/cleaned_datasets_csv/hdata_cab_cleaned.csv"),
           overwrite = TRUE)