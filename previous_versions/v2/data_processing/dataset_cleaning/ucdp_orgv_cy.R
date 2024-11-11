library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_orgv_cy <- read_datasets("ucdp_orgv_cy", db, original = TRUE)

# Clean column names
names(ucdp_orgv_cy) <- clean_column_names(names(ucdp_orgv_cy))

# Duplicate columns for unit tabels
ucdp_orgv_cy$u_ucdp_orgv_country_year_country_cy <- 
  ucdp_orgv_cy$country_cy

ucdp_orgv_cy$u_ucdp_orgv_country_year_year_cy <- 
  as.integer(ucdp_orgv_cy$year_cy)

ucdp_orgv_cy$u_ucdp_orgv_country_year_country_id_cy <- 
  as.integer(ucdp_orgv_cy$country_id_cy)


# Check for duplicates in column names
no_duplicate_names(ucdp_orgv_cy)

write_dataset(ucdp_orgv_cy, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_orgv_cy_cleaned.rds"),
              tag = "ucdp_orgv_cy",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(ucdp_orgv_cy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/ucdp_orgv_cy_cleaned.dta"),
           overwrite = TRUE)

write_file(ucdp_orgv_cy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/ucdp_orgv_cy_cleaned.csv"),
           overwrite = TRUE)
