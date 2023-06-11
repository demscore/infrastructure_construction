library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_peace <- read_datasets("ucdp_peace", db) 

ucdp_peace_conflict_sep <- tidyr::separate_rows(ucdp_peace, u_ucdp_pa_conflict_year_conflict_id, sep = ", ")
no_duplicates(ucdp_peace_conflict_sep, c("u_ucdp_pa_conflict_year_paid", 
                                         "u_ucdp_pa_conflict_year_year",
                                         "u_ucdp_pa_conflict_year_conflict_id"))

u_ucdp_pa_conflict_year <- ucdp_peace_conflict_sep %>% 
  select(u_ucdp_pa_conflict_year_paid, 
         u_ucdp_pa_conflict_year_conflict_id, 
         u_ucdp_pa_conflict_year_year) %>% 
  arrange(u_ucdp_pa_conflict_year_paid, 
          u_ucdp_pa_conflict_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_pa_conflict_year)))

write_unit_table(u_ucdp_pa_conflict_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_pa_conflict_year.rds"),
                 tag = "u_ucdp_pa_conflict_year")