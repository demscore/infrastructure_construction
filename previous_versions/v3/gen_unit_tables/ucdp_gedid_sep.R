library(dplyr)
library(demutils)

db <- pg_connect()            

ucdp_cace <- read_datasets("ucdp_cace", db)

u_ucdp_gedid_sep <- 
  bind_rows(select(ucdp_cace, 
                   u_ucdp_gedid_sep_id, 
                   u_ucdp_gedid_sep_country, 
                   u_ucdp_gedid_sep_year, 
                   u_ucdp_gedid_sep_dyad_new_id, 
                   u_ucdp_gedid_sep_conflict_new_id, 
                   u_ucdp_gedid_sep_side_a_new_id, 
                   u_ucdp_gedid_sep_side_b_new_id))%>% 
  distinct(.) %>% arrange(u_ucdp_gedid_sep_country, u_ucdp_gedid_sep_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_gedid_sep)))
            
write_unit_table(u_ucdp_gedid_sep, 
                  file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_gedid_sep.rds"),
                  tag = "u_ucdp_gedid_sep")