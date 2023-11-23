library(dplyr)
library(demutils)

db <- pg_connect()

qog_eureg_wide1 <- read_datasets("qog_eureg_wide1", db, original = TRUE)

# Clean column names
names(qog_eureg_wide1) <- clean_column_names(names(qog_eureg_wide1))

# Duplicates check to identify units
no_duplicates(qog_eureg_wide1, c("nuts0", "nuts1", "year")) #TRUE
no_duplicates(qog_eureg_wide1, c("region_code", "year")) #TRUE

# Create Unit Columns for QoG Region-Year
qog_eureg_wide1$u_qog_region_year_region <- 
  qog_eureg_wide1$region_code

qog_eureg_wide1$u_qog_region_year_year <- 
  qog_eureg_wide1$year

qog_eureg_wide1$u_qog_region_year_region_name <- 
  stringr::str_to_title(qog_eureg_wide1$region_name)

# Check for duplicates in column names
no_duplicate_names(qog_eureg_wide1)

write_dataset(qog_eureg_wide1,
           file.path(Sys.getenv("ROOT_DIR"),
            "datasets/qog/cleaned_datasets/qog_eureg_wide1_cleaned.rds"),
           tag = "qog_eureg_wide1",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(qog_eureg_wide1,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_dta/qog_eureg_wide1_cleaned.dta"),
           overwrite = TRUE)

write_file(qog_eureg_wide1,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_csv/qog_eureg_wide1_cleaned.csv"),
           overwrite = TRUE)