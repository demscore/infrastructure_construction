library(dplyr)
library(demutils)

db <- pg_connect()

vdem_coder_level <- read_datasets("vdem_coder_level", db, original = TRUE)

# Clean column names
names(vdem_coder_level) <- clean_column_names(names(vdem_coder_level))

# Duplicates check to identify units
#no_duplicates(vdem_coder_level, c("country_text_id", "historical_date", "coder_id")) #TRUE
#no_duplicates(vdem_coder_level, c("country_id", "historical_date", "coder_id")) #TRUE

# Create unit columns
vdem_coder_level$historical_date <- as.Date(vdem_coder_level$historical_date)

vdem_coder_level$u_vdem_country_date_coder_country_text_id <- 
  vdem_coder_level$country_text_id

vdem_coder_level$u_vdem_country_date_coder_historical_date <-
  vdem_coder_level$historical_date

vdem_coder_level$u_vdem_country_date_coder_coder_id <-
  vdem_coder_level$coder_id

#save
write_dataset(vdem_coder_level,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/vdem/cleaned_datasets/vdem_coder_level_cleaned.rds"),
           tag = "vdem_coder_level",
           overwrite = TRUE)

# Create static files in dta and csv format
#write_file(vdem_coder_level,
#           file.path(Sys.getenv("ROOT_DIR"),
#                     "datasets/vdem/cleaned_datasets_dta/vdem_coder_level_cleaned.dta"),
#           overwrite = TRUE)

#write_file(vdem_coder_level,
#           file.path(Sys.getenv("ROOT_DIR"),
#                     "datasets/vdem/cleaned_datasets_csv/vdem_coder_level_cleaned.csv"),
#           overwrite = TRUE)