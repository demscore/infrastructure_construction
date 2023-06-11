library(dplyr)
library(demutils)

db <- pg_connect()

#Read datasets
ucdp_actor <- read_datasets("ucdp_actor", db)

#Bind rows
u_ucdp_actor <- 
  bind_rows(select(ucdp_actor, u_ucdp_actor_actorid_new, u_ucdp_actor_actor_name)) %>%
    distinct(.)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_actor)))

write_unit_table(u_ucdp_actor, file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_actor.rds"),
                 tag = "u_ucdp_actor")

