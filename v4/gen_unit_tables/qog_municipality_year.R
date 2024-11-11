library(dplyr)
library(demutils)

db <- pg_connect()

qog_pol_mun <- read_datasets("qog_pol_mun", db)

# Create unit table
u_qog_municipality_year <- qog_pol_mun %>% 
  select(u_qog_municipality_year_municipality,
         u_qog_municipality_year_year) %>%
  distinct(.) %>%
  arrange(u_qog_municipality_year_municipality, 
          u_qog_municipality_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_qog_municipality_year)))

write_unit_table(u_qog_municipality_year, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_qog_municipality_year.rds"),
           tag = "u_qog_municipality_year")