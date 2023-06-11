library(dplyr)
library(demutils)

db <- pg_connect()

repdem_paco_year <- read_datasets("repdem_paco_year", db) 
repdem_pastr_year <- read_datasets("repdem_pastr_year", db)

# Bind rows
u_repdem_cabinet_year <- 
  bind_rows(select(repdem_paco_year, 
                   u_repdem_cabinet_year_cab_name, 
                   u_repdem_cabinet_year_year,
                   u_repdem_cabinet_year_country), 
            select(repdem_pastr_year, 
                   u_repdem_cabinet_year_cab_name, 
                   u_repdem_cabinet_year_year,
                   u_repdem_cabinet_year_country), 
  )%>%
  distinct(.) %>%
  arrange(u_repdem_cabinet_year_country, u_repdem_cabinet_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_repdem_cabinet_year)))

write_unit_table(u_repdem_cabinet_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_repdem_cabinet_year.rds"),
                 tag = "u_repdem_cabinet_year")