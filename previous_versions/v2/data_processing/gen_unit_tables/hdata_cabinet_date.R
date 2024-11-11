library(dplyr)
library(demutils)

db <- pg_connect()

hdata_cab <- read_datasets("hdata_cab", db)

# Create unit table
u_hdata_cabinet_date <- 
  bind_rows(select(hdata_cab, 
                   u_hdata_cabinet_date_cab_id, 
                   u_hdata_cabinet_date_cab_name, 
                   u_hdata_cabinet_date_country,
                   u_hdata_cabinet_date_vdem_country_id, 
                   u_hdata_cabinet_date_cow_country_id, 
                   u_hdata_cabinet_date_date_in,
                   u_hdata_cabinet_date_date_out,
                   u_hdata_cabinet_date_in_year,
                   u_hdata_cabinet_date_out_year)) %>%
  distinct(.) %>% 
  arrange(u_hdata_cabinet_date_country, 
          u_hdata_cabinet_date_date_in)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_hdata_cabinet_date)))

write_unit_table(u_hdata_cabinet_date, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_hdata_cabinet_date.rds"), 
                 tag = "u_hdata_cabinet_date")