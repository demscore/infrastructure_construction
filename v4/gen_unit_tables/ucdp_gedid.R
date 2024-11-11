library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_ged <- read_datasets("ucdp_ged", db)

# Create unit table
u_ucdp_gedid <- 
  bind_rows(select(ucdp_ged, 
                   u_ucdp_gedid_id, 
                   u_ucdp_gedid_country,
                   u_ucdp_gedid_gwno_a,
                   u_ucdp_gedid_year, 
                   u_ucdp_gedid_dyad_new_id, 
                   u_ucdp_gedid_conflict_new_id,
                   u_ucdp_gedid_side_a_new_id,
                   u_ucdp_gedid_side_b_new_id)
  )%>% 
  distinct(.) %>% 
  arrange(u_ucdp_gedid_country, 
          u_ucdp_gedid_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_gedid)))

write_unit_table(u_ucdp_gedid, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_gedid.rds"),
           tag = "u_ucdp_gedid")
