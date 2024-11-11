library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_esd_ay <- read_datasets("ucdp_esd_ay", db)

# Bind rows
u_ucdp_actor_dyad_year <- 
  bind_rows(select(ucdp_esd_ay, 
                   u_ucdp_actor_dyad_year_dyad_id,
                   u_ucdp_actor_dyad_year_dyad_name,
                   u_ucdp_actor_dyad_year_actor_id,
                   u_ucdp_actor_dyad_year_actor_name,
                   u_ucdp_actor_dyad_year_year)
  )%>%
  distinct(.) %>% arrange(u_ucdp_actor_dyad_year_dyad_id, u_ucdp_actor_dyad_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_actor_dyad_year)))

# Save df
write_unit_table(u_ucdp_actor_dyad_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_actor_dyad_year.rds"),
                 tag = "u_ucdp_actor_dyad_year")