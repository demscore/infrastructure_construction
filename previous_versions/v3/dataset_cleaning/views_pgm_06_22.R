library(dplyr)
library(demutils)

db <- pg_connect()

views_pgm_06_22 <- read_datasets("views_pgm_06_22", db, original = TRUE)

# Clean column names
names(views_pgm_06_22) <- clean_column_names(names(views_pgm_06_22))

# For now only keep two prediction variables per dataset
views_pgm_06_22 %<>% select(pg_id, month_id, sc_pgm_sb_main, sc_pgm_sb_dich_main)

# duplicate check to create unit identifiers
no_duplicates(views_pgm_06_22, c("pg_id", "month_id"))

# create unit identifiers
views_pgm_06_22$u_views_pg_month_pg_id <- views_pgm_06_22$pg_id

views_pgm_06_22$u_views_pg_month_month_id <- views_pgm_06_22$month_id

# Final duplicates check column names
no_duplicate_names(views_pgm_06_22)

# Save file
write_dataset(views_pgm_06_22, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/views_pgm_06_22_cleaned.rds"),
              tag= "views_pgm_06_22",
              overwrite = TRUE)

# Create static files in dta and csv format
write_file(views_pgm_06_22,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/views_pgm_06_22_cleaned.dta"),
           overwrite = TRUE)

write_file(views_pgm_06_22,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/views_pgm_06_22_cleaned.csv"),
           overwrite = TRUE)