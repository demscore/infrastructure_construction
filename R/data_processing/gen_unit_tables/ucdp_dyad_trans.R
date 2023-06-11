library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_translate_dyad <- read_datasets("ucdp_translate_dyad", db)

# Bind rows
u_ucdp_dyad_trans <- 
  bind_rows(select(ucdp_translate_dyad, 
                   u_ucdp_dyad_trans_new_id,
                   u_ucdp_dyad_trans_name,
                   u_ucdp_dyad_trans_tov,
                   u_ucdp_dyad_trans_old_id)
  )%>%
  distinct(.) %>% arrange(u_ucdp_dyad_trans_tov, 
                          u_ucdp_dyad_trans_new_id, 
                          u_ucdp_dyad_trans_name)


stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_dyad_trans)))

# Save df
write_unit_table(u_ucdp_dyad_trans, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_dyad_trans.rds"),
                 tag = "u_ucdp_dyad_trans")