library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_peace <- read_datasets("ucdp_peace", db) 

u_ucdp_pa <- ucdp_peace %>% select(u_ucdp_pa_paid, u_ucdp_pa_pa_name, u_ucdp_pa_year) %>% 
  arrange(u_ucdp_pa_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_pa)))

write_unit_table(u_ucdp_pa, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_pa.rds"),
                 tag = "u_ucdp_pa")