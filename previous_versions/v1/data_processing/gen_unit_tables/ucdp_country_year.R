library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_onset_inter_v2 <- read_datasets("ucdp_onset_inter_v2", db)
ucdp_onset_intra_v2 <- read_datasets("ucdp_onset_intra_v2", db)

# Create unit table
u_ucdp_country_year <- 
  bind_rows(select(ucdp_onset_inter_v2, 
                   u_ucdp_country_year_gwno_a,
                   u_ucdp_country_year_name, 
                   u_ucdp_country_year_year),
            select(ucdp_onset_intra_v2, 
                   u_ucdp_country_year_gwno_a,
                   u_ucdp_country_year_name, 
                   u_ucdp_country_year_year))%>%
  distinct(.) %>% 
  arrange(u_ucdp_country_year_name, u_ucdp_country_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_country_year)))

write_unit_table(u_ucdp_country_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_country_year.rds"),
                 tag = "u_ucdp_country_year")
