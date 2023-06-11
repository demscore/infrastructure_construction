library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_orgv_cy <- read_datasets("ucdp_orgv_cy", db)

# Create unit table
u_ucdp_orgv_country_year <- 
  bind_rows(select(ucdp_orgv_cy, 
                   u_ucdp_orgv_country_year_country_cy,
                   u_ucdp_orgv_country_year_year_cy, 
                   u_ucdp_orgv_country_year_country_id_cy))%>%
  distinct(.) %>% 
  arrange(u_ucdp_orgv_country_year_country_cy, u_ucdp_orgv_country_year_year_cy)

class(u_ucdp_orgv_country_year$u_ucdp_orgv_country_year_country_id_cy)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_orgv_country_year)))

write_unit_table(u_ucdp_orgv_country_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_orgv_country_year.rds"),
                 tag = "u_ucdp_orgv_country_year")