library(dplyr)
library(demutils)

db <- pg_connect()

repdem_parties_paco <- read_datasets("repdem_parties_paco", db) 
repdem_parties_pastr <- read_datasets("repdem_parties_pastr", db)

# Bind rows
u_repdem_cabinet_party <- 
  bind_rows(select(repdem_parties_paco, 
                   u_repdem_cabinet_party_cab_name, 
                   u_repdem_cabinet_party_partycode,
                   u_repdem_cabinet_party_partystr,
                   u_repdem_cabinet_party_year,
                   u_repdem_cabinet_party_country), 
            select(repdem_parties_pastr, 
                   u_repdem_cabinet_party_cab_name, 
                   u_repdem_cabinet_party_partycode,
                   u_repdem_cabinet_party_partystr,
                   u_repdem_cabinet_party_year,
                   u_repdem_cabinet_party_country), 
  )%>%
  distinct(.) %>%
  arrange(u_repdem_cabinet_party_country, u_repdem_cabinet_party_partycode)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_repdem_cabinet_party)))

write_unit_table(u_repdem_cabinet_party, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_repdem_cabinet_party.rds"),
                 tag = "u_repdem_cabinet_party")
