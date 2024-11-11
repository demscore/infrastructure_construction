library(dplyr)
library(demutils)

db <- pg_connect()

views_cm_06_24 <- read_datasets("views_cm_06_24", db, original = TRUE)

# Clean column names
names(views_cm_06_24) <- clean_column_names(names(views_cm_06_24))

# For now only keep two prediction variables per dataset
views_cm_06_24 %<>% select(country_id, month_id, name, gwcode, isoab, year, month,
                           main_mean_ln, main_mean, main_dich)

# duplicate check to create unit identifiers
no_duplicates(views_cm_06_24, c("country_id", "month_id")) # TRUE
no_duplicates(views_cm_06_24, c("gwcode", "month_id")) # TRUE
no_duplicates(views_cm_06_24, c("isoab", "month_id")) # TRUE
no_duplicates(views_cm_06_24, c("name", "month_id")) # TRUE

# create unit identifiers
views_cm_06_24$u_views_country_month_country_id <- views_cm_06_24$country_id

views_cm_06_24$u_views_country_month_month_id <- views_cm_06_24$month_id

views_cm_06_24$u_views_country_month_month <- views_cm_06_24$month

views_cm_06_24$u_views_country_month_year <- views_cm_06_24$year

views_cm_06_24$u_views_country_month_isoab <- views_cm_06_24$isoab

views_cm_06_24$u_views_country_month_gwcode <- views_cm_06_24$gwcode

views_cm_06_24$u_views_country_month_name <- views_cm_06_24$name

# Final duplicates check column names
no_duplicate_names(views_cm_06_24) #TRUE

# Save file
write_dataset(views_cm_06_24, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/views_cm_06_24_cleaned.rds"),
              tag= "views_cm_06_24",
              overwrite = TRUE)
