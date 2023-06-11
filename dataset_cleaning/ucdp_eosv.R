library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_eosv <- read_datasets("ucdp_eosv", db, original = TRUE)

# Clean column names
names(ucdp_eosv) <- clean_column_names(names(ucdp_eosv))

# Duplicate checks to identify unit columns 
no_duplicates(ucdp_eosv, c("actorid", "year")) #TRUE
no_duplicates(ucdp_eosv, c("actorname", "year")) #TRUE

# Load in actor translation table because UCDP EOSV uses old ids and thus needs 
# the new added to be merged and translated to other datasets. This will result in some
# NAs in this unit column. 
ucdp_actor_id_translation <- read.csv(file.path(Sys.getenv("ROOT_DIR"),"datasets/ucdp/translation_tables/translate_actor.csv"))

ucdp_eosv <- left_join(ucdp_eosv, ucdp_actor_id_translation, by = c("actorid" = "old_id"))

# Create unit columns
ucdp_eosv <- rename(ucdp_eosv, u_ucdp_actor_year_actorid_new = new_id)

# Since the unit table cannot have NAs, actors which do not have a new id are assigned "-11111"
ucdp_eosv$u_ucdp_actor_year_actorid_new[is.na(ucdp_eosv$u_ucdp_actor_year_actorid_new)] <- as.integer(-11111)

ucdp_eosv$u_ucdp_actor_year_actor_name <- 
  ucdp_eosv$actorname

ucdp_eosv$u_ucdp_actor_year_is_gov_actor <- ucdp_eosv$isgovernmentactor

# Adjust the country name for the u_ucdp_actor_year unit table to be the same as 
# in other UCDP datasets having actor-year as a primary unit
ucdp_eosv %<>% mutate(u_ucdp_actor_year_actor_name = case_when(
  actorname == "Government of Rumania" ~ "Government of Romania",
  TRUE ~ u_ucdp_actor_year_actor_name
)) %>%
  select(-name)

ucdp_eosv$u_ucdp_actor_year_year <- 
  ucdp_eosv$year

# Check for duplicates in column names
no_duplicate_names(ucdp_eosv)


write_dataset(ucdp_eosv, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_eosv_cleaned.rds"),
           tag = "ucdp_eosv",
           overwrite = TRUE)