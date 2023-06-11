library(dplyr)
library(demutils)

db <- pg_connect()

views_cm_02_23 <- read_datasets("views_cm_02_23", db, original = TRUE)

# Clean column names
names(views_cm_02_23) <- clean_column_names(names(views_cm_02_23))

# For now only keep two prediction variables per dataset
views_cm_02_23 %<>% select(country_id, month_id, name, gwcode, isoab, year, month,
                           sc_cm_sb_main, sc_cm_sb_dich_main)

# duplicate check to create unit identifiers
no_duplicates(views_cm_02_23, c("country_id", "month_id")) # TRUE
no_duplicates(views_cm_02_23, c("gwcode", "month_id")) # TRUE
no_duplicates(views_cm_02_23, c("isoab", "month_id")) # TRUE
no_duplicates(views_cm_02_23, c("name", "month_id")) # TRUE

# create unit identifiers
views_cm_02_23$u_views_country_month_country_id <- views_cm_02_23$country_id

views_cm_02_23$u_views_country_month_month_id <- views_cm_02_23$month_id

views_cm_02_23$u_views_country_month_month <- views_cm_02_23$month

views_cm_02_23$u_views_country_month_year <- views_cm_02_23$year

views_cm_02_23$u_views_country_month_isoab <- views_cm_02_23$isoab

views_cm_02_23$u_views_country_month_gwcode <- views_cm_02_23$gwcode

views_cm_02_23$u_views_country_month_name <- views_cm_02_23$name

# Final duplicates check column names
no_duplicate_names(views_cm_02_23)

# Save file
write_dataset(views_cm_02_23, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/views_cm_02_23_cleaned.rds"),
              tag= "views_cm_02_23",
              overwrite = TRUE)