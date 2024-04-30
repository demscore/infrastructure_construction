library(dplyr)
library(demutils)


db <- pg_connect()

ucdp_actor <- read_datasets("ucdp_actor", db, original = TRUE)

# Clean column names
names(ucdp_actor) <- clean_column_names(names(ucdp_actor))

no_duplicates(ucdp_actor, c("namedata"))
no_duplicates(ucdp_actor, c("actorid"))
# dups <- duplicates(ucdp_actor, c("namedata"))

# Create unit columns
ucdp_actor$u_ucdp_actor_actorid_new <- 
  ucdp_actor$actorid

ucdp_actor$u_ucdp_actor_actor_name<- 
  ucdp_actor$namedata


# Check for duplicates in column names
no_duplicate_names(ucdp_actor)


write_dataset(ucdp_actor, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_actor_cleaned.rds"),
           tag = "ucdp_actor",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(ucdp_actor,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_dta/ucdp_actor_cleaned.dta"),
           overwrite = TRUE)

write_file(ucdp_actor,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets_csv/ucdp_actor_cleaned.csv"),
           overwrite = TRUE)