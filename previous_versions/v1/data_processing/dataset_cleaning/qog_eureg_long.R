library(dplyr)
library(demutils)

db <- pg_connect()

qog_eureg_long <- read_datasets("qog_eureg_long", db, original = TRUE)

# Clean column names
names(qog_eureg_long) <- clean_column_names(names(qog_eureg_long))

# Duplicates check to identify dataset units
no_duplicates(qog_eureg_long, c("nuts0", "nuts1", "nuts2", "year")) #TRUE
no_duplicates(qog_eureg_long, c("region_code", "year")) #TRUE

# Create Unit Columns for QoG Region-Year
qog_eureg_long$u_qog_region_year_region <- 
  qog_eureg_long$region_code

qog_eureg_long$u_qog_region_year_year <- 
  qog_eureg_long$year

qog_eureg_long$u_qog_region_year_region_name <- 
  stringr::str_to_title(qog_eureg_long$region_name)


# Check for duplicates in column names
no_duplicate_names(qog_eureg_long)


write_dataset(qog_eureg_long,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_eureg_long_cleaned.rds"),
           tag = "qog_eureg_long",
           overwrite = TRUE)