library(dplyr)
library(demutils)

db <- pg_connect()

#retrieve the dataset into your environment
views_pgm_11_23 <- read_datasets("views_pgm_11_23", db, original = TRUE)

#clean column names
names(views_pgm_11_23) <- clean_column_names(names(views_pgm_11_23))

#before creating the unit identifiers we must check for duplicates in our data.
no_duplicates(views_pgm_11_23, c("pg_id", "month_id")) #TRUE

#create unit identifiers
views_pgm_11_23$u_views_pg_month_pg_id <- views_pgm_11_23$pg_id

views_pgm_11_23$u_views_pg_month_month_id <- views_pgm_11_23$month_id

#Do a final check for duplicates in column names
no_duplicate_names(views_pgm_11_23) #TRUE

# Save file
write_dataset(views_pgm_11_23, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/views_pgm_11_23_cleaned.rds"),
              tag= "views_pgm_11_23",
              overwrite = TRUE)


