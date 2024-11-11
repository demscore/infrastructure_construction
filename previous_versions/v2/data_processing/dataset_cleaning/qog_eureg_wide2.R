library(dplyr)
library(demutils)

db <- pg_connect()

qog_eureg_wide2 <- read_datasets("qog_eureg_wide2", db, original = TRUE)

# Clean column names
names(qog_eureg_wide2) <- clean_column_names(names(qog_eureg_wide2))

# Duplicates check for dataset units
no_duplicates(qog_eureg_wide2, c("nuts0", "nuts2", "year")) #TRUE
no_duplicates(qog_eureg_wide2, c("region_code", "year")) #TRUE


# Create Unit Columns for QoG Region-Year
qog_eureg_wide2$u_qog_region_year_region <- 
  qog_eureg_wide2$region_code

qog_eureg_wide2$u_qog_region_year_year <- 
  qog_eureg_wide2$year

qog_eureg_wide2$u_qog_region_year_region_name <- 
  stringr::str_to_title(qog_eureg_wide2$region_name)


# Check for duplicates in column names
no_duplicate_names(qog_eureg_wide2)

write_dataset(qog_eureg_wide2,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_eureg_wide2_cleaned.rds"),
           tag = "qog_eureg_wide2",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(qog_eureg_wide2,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_dta/qog_eureg_wide2_cleaned.dta"),
           overwrite = TRUE)

write_file(qog_eureg_wide2,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_csv/qog_eureg_wide2_cleaned.csv"),
           overwrite = TRUE)