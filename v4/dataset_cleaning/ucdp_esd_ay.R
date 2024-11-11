library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_esd_ay <- read_datasets("ucdp_esd_ay", db, original = TRUE)

# Clean column names
names(ucdp_esd_ay) <- clean_column_names(names(ucdp_esd_ay))

#Identify unit columns
no_duplicates(ucdp_esd_ay, c("actor_id", "dyad_id", "year")) #TRUE
no_duplicates(ucdp_esd_ay, c("actor_name", "dyad_name", "year")) #TRUE

# Create unit identifiers
# Actor-Dyad-Year
ucdp_esd_ay$u_ucdp_actor_dyad_year_actor_id <-
  ucdp_esd_ay$actor_id

ucdp_esd_ay$u_ucdp_actor_dyad_year_actor_name <-
  ucdp_esd_ay$actor_name

ucdp_esd_ay$u_ucdp_actor_dyad_year_dyad_id <-
  ucdp_esd_ay$dyad_id

ucdp_esd_ay$u_ucdp_actor_dyad_year_dyad_name <-
  ucdp_esd_ay$dyad_name

ucdp_esd_ay$u_ucdp_actor_dyad_year_year <-
  ucdp_esd_ay$year

#Final check for duplicates in column names
no_duplicate_names(ucdp_esd_ay)

write_dataset(ucdp_esd_ay,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_esd_ay_cleaned.rds"),
              tag = "ucdp_esd_ay",
              overwrite = TRUE)
