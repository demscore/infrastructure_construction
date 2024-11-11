
library(dplyr)
library(demutils)
db <- pg_connect()

ucdp_translate_actor <- read_datasets("ucdp_translate_actor", db, original = TRUE)


#Use function to clean column names
names(ucdp_translate_actor) <- clean_column_names(names(ucdp_translate_actor))


# Duplicate columns for unit tables
ucdp_translate_actor$u_ucdp_actor_trans_new_id <- ucdp_translate_actor$new_id

ucdp_translate_actor$u_ucdp_actor_trans_old_id <- ucdp_translate_actor$old_id

ucdp_translate_actor$u_ucdp_actor_trans_name <- ucdp_translate_actor$name


# Save 
write_dataset(ucdp_translate_actor, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_translate_actor_cleaned.rds"),
           tag = "ucdp_translate_actor",
           overwrite = TRUE)