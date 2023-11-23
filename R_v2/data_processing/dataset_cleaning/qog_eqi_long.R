library(dplyr)
library(demutils)

db <- pg_connect()

qog_eqi_long <- read_datasets("qog_eqi_long", db, original = TRUE)

# Clean column names
names(qog_eqi_long) <- clean_column_names(names(qog_eqi_long))

# Duplicates check to identify dataset units
no_duplicates(qog_eqi_long, c("nuts0", "nuts1", "nuts2", "year")) #TRUE
no_duplicates(qog_eqi_long, c("region_code", "year")) #TRUE
no_duplicates(qog_eqi_long, c("name", "year")) #TRUE

# Create Unit Columns for QoG Region-Year
qog_eqi_long$u_qog_region_year_region <- 
  qog_eqi_long$region_code

qog_eqi_long$u_qog_region_year_year <- 
  qog_eqi_long$year

qog_eqi_long$u_qog_region_year_region_name <- 
  stringr::str_to_title(qog_eqi_long$name)

# Check for duplicates in column names
no_duplicate_names(qog_eqi_long)


write_dataset(qog_eqi_long,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/eqi_data_long21_cleaned.rds"),
           tag = "qog_eqi_long",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(qog_eqi_long,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_dta/qog_eqi_long_cleaned.dta"),
           overwrite = TRUE)

write_file(qog_eqi_long,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_csv/qog_eqi_long_cleaned.csv"),
           overwrite = TRUE)