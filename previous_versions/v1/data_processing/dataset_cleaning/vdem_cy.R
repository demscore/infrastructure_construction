library(dplyr)
library(demutils)
db <- pg_connect()

vdem_cy <- read_datasets("vdem_cy", db, original = TRUE)

# Clean column names
names(vdem_cy) <- clean_column_names(names(vdem_cy))

# Duplicates check to identify units
no_duplicates(vdem_cy, c("country_name", "year")) #TRUE
no_duplicates(vdem_cy, c("cowcode", "year")) #FALSE (bco Palestine, Hong-Kong and mainly historical country units)
no_duplicates(vdem_cy, c("country_text_id", "year")) #TRUE
no_duplicates(vdem_cy, c("country_id", "year")) # TRUE

# Create unit columns
vdem_cy$u_vdem_country_year_country <- 
  vdem_cy$country_name

vdem_cy$u_vdem_country_year_country_text_id <- 
  vdem_cy$country_text_id

vdem_cy$u_vdem_country_year_country_id <- 
  as.integer(vdem_cy$country_id)

vdem_cy$u_vdem_country_year_cowcode <- 
  as.integer(vdem_cy$cowcode)

vdem_cy$u_vdem_country_year_cowcode[is.na(vdem_cy$u_vdem_country_year_cowcode)] <- 
  as.integer(-11111)

vdem_cy$u_vdem_country_year_year <- 
  vdem_cy$year

# Replace NAs
vdem_cy[is.na(vdem_cy)] <- -11111

#save
write_dataset(vdem_cy,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/vdem/cleaned_datasets/vdem_cy_cleaned.rds"),
           tag = "vdem_cy",
           overwrite = TRUE)