library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_term_conflict <- read_datasets("ucdp_term_conflict", db)
ucdp_nonstate <- read_datasets("ucdp_nonstate", db)
ucdp_prio_acd <- read_datasets("ucdp_prio_acd", db)
ucdp_brd_conflict <- read_datasets("ucdp_brd_conflict", db)

# Create unit table
u_ucdp_conflict_year <- 
  bind_rows(select(ucdp_term_conflict, 
                   u_ucdp_conflict_year_conflict_id, 
                   u_ucdp_conflict_year_year), 
            select(ucdp_nonstate, 
                   u_ucdp_conflict_year_conflict_id, 
                   u_ucdp_conflict_year_year),
            select(ucdp_brd_conflict, 
                   u_ucdp_conflict_year_conflict_id, 
                   u_ucdp_conflict_year_year),
            select(ucdp_prio_acd, 
                   u_ucdp_conflict_year_conflict_id, 
                   u_ucdp_conflict_year_year)) %>% 
  distinct(.) %>% 
  arrange(u_ucdp_conflict_year_conflict_id, 
          u_ucdp_conflict_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_conflict_year)))

write_unit_table(u_ucdp_conflict_year, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_conflict_year.rds"),
           tag = "u_ucdp_conflict_year")

