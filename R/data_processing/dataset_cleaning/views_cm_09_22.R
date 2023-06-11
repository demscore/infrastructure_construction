library(dplyr)
library(demutils)

db <- pg_connect()

views_cm_09_22 <- read_datasets("views_cm_09_22", db, original = TRUE)

# Clean column names
names(views_cm_09_22) <- clean_column_names(names(views_cm_09_22))

# For now only keep two prediction variables per dataset
views_cm_09_22 %<>% select(country_id, month_id, name, gwcode, isoab, year, month,
                           sc_cm_sb_main, sc_cm_sb_dich_main)

# duplicate check to create unit identifiers
no_duplicates(views_cm_09_22, c("country_id", "month_id")) # TRUE
no_duplicates(views_cm_09_22, c("gwcode", "month_id")) # TRUE
no_duplicates(views_cm_09_22, c("isoab", "month_id")) # TRUE
no_duplicates(views_cm_09_22, c("name", "month_id")) # TRUE

# create unit identifiers
views_cm_09_22$u_views_country_month_country_id <- views_cm_09_22$country_id

views_cm_09_22$u_views_country_month_month_id <- views_cm_09_22$month_id

views_cm_09_22$u_views_country_month_month <- views_cm_09_22$month

views_cm_09_22$u_views_country_month_year <- views_cm_09_22$year

views_cm_09_22$u_views_country_month_isoab <- views_cm_09_22$isoab

views_cm_09_22$u_views_country_month_gwcode <- views_cm_09_22$gwcode

views_cm_09_22$u_views_country_month_name <- views_cm_09_22$name

# Final duplicates check column names
no_duplicate_names(views_cm_09_22)

# Save file
write_dataset(views_cm_09_22, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/views_cm_09_22_cleaned.rds"),
              tag= "views_cm_09_22",
              overwrite = TRUE)