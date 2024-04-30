library(dplyr)
library(demutils)

db <- pg_connect()

repdem_basic_quarter <- read_datasets("repdem_basic_quarter", db) 
repdem_wecee_quarter <- read_datasets("repdem_wecee_quarter", db)

# Bind rows
u_repdem_cabinet_quarter <- 
  bind_rows(select(repdem_basic_quarter, 
                   u_repdem_cabinet_quarter_cab_name, 
                   u_repdem_cabinet_quarter_quarter,
                   u_repdem_cabinet_quarter_year,
                   u_repdem_cabinet_quarter_country), 
            select(repdem_wecee_quarter, 
                   u_repdem_cabinet_quarter_cab_name, 
                   u_repdem_cabinet_quarter_quarter,
                   u_repdem_cabinet_quarter_year,
                   u_repdem_cabinet_quarter_country), 
  )%>%
  distinct(.) %>%
  arrange(u_repdem_cabinet_quarter_country, u_repdem_cabinet_quarter_quarter)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_repdem_cabinet_quarter)))

write_unit_table(u_repdem_cabinet_quarter, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_repdem_cabinet_quarter.rds"),
                 tag = "u_repdem_cabinet_quarter")