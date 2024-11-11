library(dplyr)
library(demutils)

db <- pg_connect()

views_pgm_08_23 <- read_datasets("views_pgm_08_23", db, original = TRUE)

# Clean column names
names(views_pgm_08_23) <- clean_column_names(names(views_pgm_08_23))

# duplicate check to create unit identifiers
no_duplicates(views_pgm_08_23, c("pg_id", "month_id"))

# create unit identifiers
views_pgm_08_23$u_views_pg_month_pg_id <- views_pgm_08_23$pg_id

views_pgm_08_23$u_views_pg_month_month_id <- views_pgm_08_23$month_id

# Final duplicates check column names
no_duplicate_names(views_pgm_08_23)

# Save file
write_dataset(views_pgm_08_23, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/views_pgm_08_23_cleaned.rds"),
              tag= "views_pgm_08_23",
              overwrite = TRUE)

