# Load libraries
library(dplyr)
library(demutils)
db <- pg_connect()

ucdp_translate_dyad <- read_datasets("ucdp_translate_dyad", db, original = TRUE)

#Use function to clean column name
names(ucdp_translate_dyad) <- clean_column_names(names(ucdp_translate_dyad))

# Duplicate columns for unit table
ucdp_translate_dyad$u_ucdp_dyad_trans_new_id <- ucdp_translate_dyad$new_id

ucdp_translate_dyad$u_ucdp_dyad_trans_old_id <- ucdp_translate_dyad$old_id

ucdp_translate_dyad$u_ucdp_dyad_trans_name <- ucdp_translate_dyad$name

ucdp_translate_dyad$u_ucdp_dyad_trans_tov <- ucdp_translate_dyad$type_of_violence


# Save 
write_dataset(ucdp_translate_dyad, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_translate_dyad_cleaned.rds"),
           tag = "ucdp_translate_dyad",
           overwrite = TRUE)