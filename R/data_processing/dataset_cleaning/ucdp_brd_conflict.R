library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_brd_conflict <- read_datasets("ucdp_brd_conflict", db, original = TRUE)


# Clean column names
names(ucdp_brd_conflict) <- clean_column_names(names(ucdp_brd_conflict))

# Check for duplicates
no_duplicates(ucdp_brd_conflict, c("dyad_id", "year")) # TRUE but no unit 
no_duplicates(ucdp_brd_conflict, c("conflict_id", "year")) # TRUE

# Create unit columns
ucdp_brd_conflict$u_ucdp_conflict_year_conflict_id <- 
  ucdp_brd_conflict$conflict_id

ucdp_brd_conflict$u_ucdp_conflict_year_year <- 
  ucdp_brd_conflict$year

# Check for duplicates in column names
no_duplicate_names(ucdp_brd_conflict)


write_dataset(ucdp_brd_conflict, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_brd_conflict_cleaned.rds"),
                     tag = "ucdp_brd_conflict",
           overwrite = TRUE)