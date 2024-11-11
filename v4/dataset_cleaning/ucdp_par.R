library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_par <- read_datasets("ucdp_par", db, original = TRUE)


# Clean column names
names(ucdp_par) <- clean_column_names(names(ucdp_par))

# Check if some columns have multiple classes
v <- check_multiple_classes(ucdp_par)

# Remove multiple classes
print(v)
sapply(ucdp_par[, c("date_start", "date_end")], class)
ucdp_par$date_start <- as.Date(ucdp_par$date_start)
ucdp_par$date_end <- as.Date(ucdp_par$date_end)

v <- check_multiple_classes(ucdp_par)
stopifnot("Some variables have multiple classes." = length(v) <= 0)


# Check for duplicates
no_duplicates(ucdp_par, c("id")) # TRUE 

# Create unit columns
ucdp_par$u_ucdp_par_event_id <- 
  ucdp_par$id

ucdp_par$u_ucdp_par_event_year <- 
  ucdp_par$year

ucdp_par$u_ucdp_par_event_country_id <- 
  ucdp_par$country_id

ucdp_par$u_ucdp_par_event_country <- 
  ucdp_par$country

ucdp_par$u_ucdp_par_event_dyad_id <- 
  ucdp_par$dyad_dset_id  

# Check for duplicates in column names
no_duplicate_names(ucdp_par)


write_dataset(ucdp_par, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_par_cleaned.rds"),
              tag = "ucdp_par",
              overwrite = TRUE)