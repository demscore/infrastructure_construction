library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_term_conflict <- read_datasets("ucdp_term_conflict", db)

# Create unit table
u_ucdp_conflictep_year <- ucdp_term_conflict %>% 
  select(u_ucdp_conflictep_year_conflictep_id, 
         u_ucdp_conflictep_year_year) %>% 
  arrange(u_ucdp_conflictep_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_conflictep_year)))

write_unit_table(u_ucdp_conflictep_year, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_conflictep_year.rds"),
           tag = "u_ucdp_conflictep_year")