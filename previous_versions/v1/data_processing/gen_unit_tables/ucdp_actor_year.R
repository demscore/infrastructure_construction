library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_onesided <- read_datasets("ucdp_onesided", db) 
ucdp_eosv <- read_datasets("ucdp_eosv", db) 

# Create unit table
u_ucdp_actor_year <- 
  bind_rows(select(ucdp_onesided, 
                   u_ucdp_actor_year_actorid_new, 
                   u_ucdp_actor_year_actor_name, 
                   u_ucdp_actor_year_year, 
                   u_ucdp_actor_year_is_gov_actor), 
            select(ucdp_eosv, 
                   u_ucdp_actor_year_actorid_new, 
                   u_ucdp_actor_year_actor_name, 
                   u_ucdp_actor_year_year, 
                   u_ucdp_actor_year_is_gov_actor)) %>%
  distinct(u_ucdp_actor_year_actorid_new, u_ucdp_actor_year_year, .keep_all = TRUE) %>%
  arrange(u_ucdp_actor_year_actorid_new, 
                          u_ucdp_actor_year_year)

# We do distinct on actorid_new and year as the combination with names returns duplicates in ids and names which complicate the translations. However, we cannot remove the actor names as we use them for translations between actors and countries.
# It seems to be the best solution to remove actor names in the cases where ids and year return duplicates, as the difference between the actor names in these cases is usually one or two blank spaces in the end of the name.

# One duplicate in actor ID (338), we keep "Republic of Artsakh"
u_ucdp_actor_year <- u_ucdp_actor_year %>%
  filter(u_ucdp_actor_year_actor_name != "Republic of Nagorno-Karabakh")

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_actor_year)))

write_unit_table(u_ucdp_actor_year, file.path(Sys.getenv("UNIT_TABLE_PATH"), 
                                    "u_ucdp_actor_year.rds"), tag = "u_ucdp_actor_year")

