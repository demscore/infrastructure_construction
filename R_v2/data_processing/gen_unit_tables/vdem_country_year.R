library(dplyr)
library(demutils)

db <- pg_connect()

vdem_cy <- read_datasets("vdem_cy", db)
vdem_ert <- read_datasets("vdem_ert", db)

# Create unit table
u_vdem_country_year <- 
  bind_rows(select(vdem_cy, 
                   u_vdem_country_year_country,
                   u_vdem_country_year_country_text_id,
                   u_vdem_country_year_country_id,
                   u_vdem_country_year_cowcode,
                   u_vdem_country_year_year), 
            select(vdem_ert, 
                   u_vdem_country_year_country,
                   u_vdem_country_year_country_text_id,
                   u_vdem_country_year_country_id,
                   u_vdem_country_year_cowcode,
                   u_vdem_country_year_year)) %>%
  mutate(u_vdem_country_year_country = case_when(
    u_vdem_country_year_country == "Czech Republic" ~ "Czechia", 
    TRUE ~ u_vdem_country_year_country
  )) %>%
  distinct(.) %>% 
  arrange(u_vdem_country_year_country, 
          u_vdem_country_year_year)

dups <- duplicates(u_vdem_country_year, c('u_vdem_country_year_country', 'u_vdem_country_year_year'))

stopifnot("There are missing values in the unit columns." = !any(is.na(u_vdem_country_year)))

write_unit_table(u_vdem_country_year, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_vdem_country_year.rds"), 
           tag = "u_vdem_country_year")