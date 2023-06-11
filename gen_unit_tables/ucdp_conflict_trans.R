library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_translate_conflict <- read_datasets("ucdp_translate_conflict", db)

# Bind rows
u_ucdp_conflict_trans <- 
  bind_rows(select(ucdp_translate_conflict, 
                   u_ucdp_conflict_trans_new_id,
                   u_ucdp_conflict_trans_old_id)
  )%>%
  distinct(.) %>% arrange(u_ucdp_conflict_trans_new_id)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_conflict_trans)))

# Save df
write_unit_table(u_ucdp_conflict_trans, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_conflict_trans.rds"),
                 tag = "u_ucdp_conflict_trans")