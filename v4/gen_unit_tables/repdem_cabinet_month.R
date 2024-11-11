library(dplyr)
library(demutils)

db <- pg_connect()

repdem_basic_month <- read_datasets("repdem_basic_month", db) 
repdem_wecee_month <- read_datasets("repdem_wecee_month", db)

# Bind rows
u_repdem_cabinet_month <- 
  bind_rows(select(repdem_basic_month, 
                   u_repdem_cabinet_month_cab_id,
                   u_repdem_cabinet_month_cab_name, 
                   u_repdem_cabinet_month_month,
                   u_repdem_cabinet_month_country,
                   u_repdem_cabinet_month_year,
                   u_repdem_cabinet_month_unique_id), 
            select(repdem_wecee_month, 
                   u_repdem_cabinet_month_cab_id,
                   u_repdem_cabinet_month_cab_name, 
                   u_repdem_cabinet_month_month,
                   u_repdem_cabinet_month_country,
                   u_repdem_cabinet_month_year,
                   u_repdem_cabinet_month_unique_id), 
  )%>%
  distinct(.) %>%
  arrange(u_repdem_cabinet_month_country, u_repdem_cabinet_month_month)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_repdem_cabinet_month)))

dups <- duplicates(u_repdem_cabinet_month, c("u_repdem_cabinet_month_cab_id", "u_repdem_cabinet_month_month"))
stopifnot("There are duplicates among the identifiers." = nrow(dups) == 0)

write_unit_table(u_repdem_cabinet_month, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_repdem_cabinet_month.rds"),
                 tag = "u_repdem_cabinet_month")
