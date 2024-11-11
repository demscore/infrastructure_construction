library(dplyr)
library(demutils)

db <- pg_connect()

qog_eqi_agg21 <- read_datasets("qog_eqi_agg21", db, original = TRUE)


# Clean coulmn names
names(qog_eqi_agg21) <- clean_column_names(names(qog_eqi_agg21))

no_duplicates(qog_eqi_agg21, c("region_code")) #TRUE
no_duplicates(qog_eqi_agg21, c("name")) #TRUE

# Create Unit Columns for QoG Region
qog_eqi_agg21$u_qog_region_region <- 
  qog_eqi_agg21$region_code

qog_eqi_agg21$u_qog_region_name <- 
  stringr::str_to_title(qog_eqi_agg21$name)

qog_eqi_agg21$u_qog_region_country <- 
  qog_eqi_agg21$cname


# Check for duplicates in column names
no_duplicate_names(qog_eqi_agg21)


write_dataset(qog_eqi_agg21,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_eqi_agg21_cleaned.rds"),
           tag = "qog_eqi_agg21",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(qog_eqi_agg21,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_dta/qog_eqi_agg21_cleaned.dta"),
           overwrite = TRUE)

write_file(qog_eqi_agg21,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_csv/qog_eqi_agg21_cleaned.csv"),
           overwrite = TRUE)