library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_cid_diy <- read_datasets("ucdp_cid_diy", db) 

u_ucdp_dyad_issue_year <- ucdp_cid_diy %>% select(u_ucdp_dyad_issue_year_id, 
                                                  u_ucdp_dyad_issue_year_dyad_id, 
                                                  u_ucdp_dyad_issue_year_year,
                                                  u_ucdp_dyad_issue_year_issue) %>% 
  arrange(u_ucdp_dyad_issue_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_dyad_issue_year)))

write_unit_table(u_ucdp_dyad_issue_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_dyad_issue_year.rds"),
                 tag = "u_ucdp_dyad_issue_year")
