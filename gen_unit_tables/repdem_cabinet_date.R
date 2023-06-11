library(dplyr)
library(demutils)

db <- pg_connect()

repdem_paged_paco <- read_datasets("repdem_paged_paco", db) 
repdem_paged_pastr <- read_datasets("repdem_paged_pastr", db)

# Bind rows
u_repdem_cabinet_date <- 
  bind_rows(select(repdem_paged_paco, 
                   u_repdem_cabinet_date_cab_name, 
                   u_repdem_cabinet_date_date_in,
                   u_repdem_cabinet_date_date_out,
                   u_repdem_cabinet_date_country,
                   u_repdem_cabinet_date_in_year,
                   u_repdem_cabinet_date_out_year), 
            select(repdem_paged_pastr, 
                   u_repdem_cabinet_date_cab_name, 
                   u_repdem_cabinet_date_date_in,
                   u_repdem_cabinet_date_date_out,
                   u_repdem_cabinet_date_country,
                   u_repdem_cabinet_date_in_year,
                   u_repdem_cabinet_date_out_year), 
            )%>%
  distinct(.) %>%
  arrange(u_repdem_cabinet_date_country, u_repdem_cabinet_date_in_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_repdem_cabinet_date)))

write_unit_table(u_repdem_cabinet_date, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_repdem_cabinet_date.rds"),
           tag = "u_repdem_cabinet_date")