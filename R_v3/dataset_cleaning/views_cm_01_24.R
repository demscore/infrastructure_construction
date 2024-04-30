library(dplyr)
library(demutils)

db <- pg_connect()

views_cm_01_24 <- read_datasets("views_cm_01_24", db, original = TRUE)

# Clean column names
names(views_cm_01_24) <- clean_column_names(names(views_cm_01_24))

# For now only keep two prediction variables per dataset
views_cm_01_24 %<>% select(country_id, month_id, name, gwcode, isoab, year, month,
                           main_mean_ln, main_mean, main_dich)

# duplicate check to create unit identifiers
no_duplicates(views_cm_01_24, c("country_id", "month_id")) # TRUE
no_duplicates(views_cm_01_24, c("gwcode", "month_id")) # TRUE
no_duplicates(views_cm_01_24, c("isoab", "month_id")) # TRUE
no_duplicates(views_cm_01_24, c("name", "month_id")) # TRUE

# create unit identifiers
views_cm_01_24$u_views_country_month_country_id <- views_cm_01_24$country_id

views_cm_01_24$u_views_country_month_month_id <- views_cm_01_24$month_id

views_cm_01_24$u_views_country_month_month <- views_cm_01_24$month

views_cm_01_24$u_views_country_month_year <- views_cm_01_24$year

views_cm_01_24$u_views_country_month_isoab <- views_cm_01_24$isoab

views_cm_01_24$u_views_country_month_gwcode <- views_cm_01_24$gwcode

views_cm_01_24$u_views_country_month_name <- views_cm_01_24$name

# Final duplicates check column names
no_duplicate_names(views_cm_01_24) #TRUE

# Save file
write_dataset(views_cm_01_24, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/views_cm_01_24_cleaned.rds"),
              tag= "views_cm_01_24",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(views_cm_01_24,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/views_cm_01_24_cleaned.dta"),
           overwrite = TRUE)

write_file(views_cm_01_24,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/views_cm_01_24_cleaned.csv"),
           overwrite = TRUE)