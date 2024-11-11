library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_nscia <- read_datasets("ucdp_nscia", db, original = TRUE)

#Clean column names 
names(ucdp_nscia) <- clean_column_names(names(ucdp_nscia))

# Duplicate checks
no_duplicates(ucdp_nscia, c("dyad_id", "year"))

# Duplicate columns for unit tables
ucdp_nscia$u_ucdp_dyad_year_dyad_id <- 
  as.character(ucdp_nscia$dyad_id)

ucdp_nscia$u_ucdp_dyad_year_year <- 
  ucdp_nscia$year

# Save 
write_dataset(ucdp_nscia, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_nscia_cleaned.rds"),
           tag = "ucdp_nscia",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(ucdp_nscia,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/ucdp_nscia_cleaned.dta"),
           overwrite = TRUE)

write_file(ucdp_nscia,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/ucdp_nscia_cleaned.csv"),
           overwrite = TRUE)