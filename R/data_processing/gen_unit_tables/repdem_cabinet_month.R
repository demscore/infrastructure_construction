library(dplyr)
library(demutils)

db <- pg_connect()

repdem_paco_month <- read_datasets("repdem_paco_month", db) 
repdem_pastr_month <- read_datasets("repdem_pastr_month", db)

# Bind rows
u_repdem_cabinet_month <- 
  bind_rows(select(repdem_paco_month, 
                   u_repdem_cabinet_month_cab_name, 
                   u_repdem_cabinet_month_month,
                   u_repdem_cabinet_month_country), 
            select(repdem_pastr_month, 
                   u_repdem_cabinet_month_cab_name, 
                   u_repdem_cabinet_month_month,
                   u_repdem_cabinet_month_country), 
  )%>%
  distinct(.) %>%
  arrange(u_repdem_cabinet_month_country, u_repdem_cabinet_month_month)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_repdem_cabinet_month)))

write_unit_table(u_repdem_cabinet_month, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_repdem_cabinet_month.rds"),
                 tag = "u_repdem_cabinet_month")
