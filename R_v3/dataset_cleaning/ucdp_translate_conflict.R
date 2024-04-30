# Load libraries
library(dplyr)
library(demutils)


# Connect to database 
db <- pg_connect()

ucdp_translate_conflict <- read_datasets("ucdp_translate_conflict", db, original = TRUE)

#Use function to clean column names
names(ucdp_translate_conflict) <- clean_column_names(names(ucdp_translate_conflict))

# Duplicate columns for unit table
ucdp_translate_conflict$u_ucdp_conflict_trans_new_id <- ucdp_translate_conflict$new_id

ucdp_translate_conflict$u_ucdp_conflict_trans_old_id <- ucdp_translate_conflict$old_id


# Use this function to make sure that there are no duplicates in column names
no_duplicate_names(ucdp_translate_conflict)



# Save data.frame with new column names
write_dataset(ucdp_translate_conflict, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_translate_conflict_cleaned.rds"),
           tag = "ucdp_translate_conflict",
           overwrite = TRUE)