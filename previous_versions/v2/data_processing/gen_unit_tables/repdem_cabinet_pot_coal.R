library(dplyr)
library(demutils)

db <- pg_connect()

repdem_pot_coal_paco <- read_datasets("repdem_pot_coal_paco", db) 
repdem_pot_coal_pastr <- read_datasets("repdem_pot_coal_pastr", db)

# Bind rows
u_repdem_cabinet_pot_coal <- 
  bind_rows(select(repdem_pot_coal_paco, 
                   u_repdem_cabinet_pot_coal_cab_id, 
                   u_repdem_cabinet_pot_coal_coalition,
                   u_repdem_cabinet_pot_coal_country), 
            select(repdem_pot_coal_pastr, 
                   u_repdem_cabinet_pot_coal_cab_id, 
                   u_repdem_cabinet_pot_coal_coalition,
                   u_repdem_cabinet_pot_coal_country), 
  )%>%
  distinct(.) %>%
  arrange(u_repdem_cabinet_pot_coal_country, u_repdem_cabinet_pot_coal_cab_id)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_repdem_cabinet_pot_coal)))

write_unit_table(u_repdem_cabinet_pot_coal, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_repdem_cabinet_pot_coal.rds"),
                 tag = "u_repdem_cabinet_pot_coal")
