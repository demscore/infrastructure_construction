library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_par <- read_datasets("ucdp_par", db)

# Create unit table
# Create unit table
u_ucdp_par_event <- 
  bind_rows(select(ucdp_par, 
                   u_ucdp_par_event_id, 
                   u_ucdp_par_event_year,
                   u_ucdp_par_event_country_id,
                   u_ucdp_par_event_country,
                   u_ucdp_par_event_dyad_id)
  )%>% 
  distinct(.) %>% 
  arrange(u_ucdp_par_event_country_id, 
          u_ucdp_par_event_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_par_event)))

write_unit_table(u_ucdp_par_event, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_par_event.rds"),
                 tag = "u_ucdp_par_event")