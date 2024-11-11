library(dplyr)
library(demutils)

db <- pg_connect()

hdata_diprep <- read_datasets("hdata_diprep", db)

# Bind to unit table
u_hdata_dyad_year <- select(hdata_diprep, 
                   u_hdata_dyad_year_country_one,
                   u_hdata_dyad_year_country_two, 
                   u_hdata_dyad_year_cowcode_one, 
                   u_hdata_dyad_year_cowcode_two, 
                   u_hdata_dyad_year_vdem_one, 
                   u_hdata_dyad_year_vdem_two, 
                   u_hdata_dyad_year_year) %>%
  distinct(.) %>%
  arrange(u_hdata_dyad_year_country_one, u_hdata_dyad_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_hdata_dyad_year)))

write_unit_table(u_hdata_dyad_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_hdata_dyad_year.rds"), 
                 tag = "u_hdata_dyad_year")
