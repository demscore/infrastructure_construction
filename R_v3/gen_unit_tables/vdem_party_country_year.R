library(dplyr)
library(demutils)
db <- pg_connect()

vdem_vparty <- read_datasets("vdem_vparty", db)

# Create unit table
u_vdem_party_country_year <- vdem_vparty %>% 
  select(u_vdem_party_country_year_v2paenname,
         u_vdem_party_country_year_v2paid,
         u_vdem_party_country_year_year,
         u_vdem_party_country_year_country_name,
         u_vdem_party_country_year_country_text_id) %>% 
  arrange(u_vdem_party_country_year_year,
          u_vdem_party_country_year_country_name,
          u_vdem_party_country_year_v2paid)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_vdem_party_country_year)))

write_unit_table(u_vdem_party_country_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_vdem_party_country_year.rds"),
                 tag = "u_vdem_party_country_year")