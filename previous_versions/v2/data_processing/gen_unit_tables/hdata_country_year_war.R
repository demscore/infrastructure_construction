library(dplyr)
library(demutils)

db <- pg_connect()

hdata_conflict_war <- read_datasets("hdata_conflict_war", db)

# Create unit table
u_hdata_country_year_war <- 
  bind_rows(select(hdata_conflict_war, 
                   u_hdata_country_year_war_country, 
                   u_hdata_country_year_war_min_year, 
                   u_hdata_country_year_war_war_name,
                   u_hdata_country_year_war_vdem_country,
                   u_hdata_country_year_war_cowcode)) %>%
  distinct(.) %>% 
  arrange(u_hdata_country_year_war_country, 
          u_hdata_country_year_war_min_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_hdata_country_year_war)))

write_unit_table(u_hdata_country_year_war, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_hdata_country_year_war.rds"), 
                 tag = "u_hdata_country_year_war")