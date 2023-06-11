library(dplyr)
library(demutils)


db <- pg_connect()

vdem_cd <- read_datasets("vdem_cd", db)

# Create unit table
u_vdem_country_date <- 
  bind_rows(select(vdem_cd, 
                   u_vdem_country_date_country_name, 
                   u_vdem_country_date_country_text_id,
                   u_vdem_country_date_cowcode,
                   u_vdem_country_date_date)) %>%
  distinct(.) %>% 
  arrange(u_vdem_country_date_country_name, 
          u_vdem_country_date_date)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_vdem_country_date)))

write_unit_table(u_vdem_country_date, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_vdem_country_date.rds"), 
           tag = "u_vdem_country_date")
