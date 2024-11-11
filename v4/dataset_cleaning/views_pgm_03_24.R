library(dplyr)
library(demutils)

db <- pg_connect()

#retrieve the dataset into your environment
views_pgm_03_24 <- read_datasets("views_pgm_03_24", db, original = TRUE)

#clean column names
names(views_pgm_03_24) <- clean_column_names(names(views_pgm_03_24))

#before creating the unit identifiers we must check for duplicates in our data.
no_duplicates(views_pgm_03_24, c("pg_id", "month_id")) #TRUE

#create unit identifiers
views_pgm_03_24$u_views_pg_month_pg_id <- views_pgm_03_24$pg_id

views_pgm_03_24$u_views_pg_month_month_id <- views_pgm_03_24$month_id

#Do a final check for duplicates in column names
no_duplicate_names(views_pgm_03_24) #TRUE

# Save file
write_dataset(views_pgm_03_24, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/views_pgm_03_24_cleaned.rds"),
              tag= "views_pgm_03_24",
              overwrite = TRUE)

