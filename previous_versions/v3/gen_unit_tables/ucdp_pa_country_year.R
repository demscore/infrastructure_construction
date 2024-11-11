library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_peace <- read_datasets("ucdp_peace", db) 

ucdp_peace_country_sep <- tidyr::separate_rows(ucdp_peace, u_ucdp_pa_country_year_country, sep = ", ")
no_duplicates(ucdp_peace_country_sep, c("u_ucdp_pa_country_year_paid", 
                                     "u_ucdp_pa_country_year_year",
                                     "u_ucdp_pa_country_year_country"))

u_ucdp_pa_country_year <- ucdp_peace_country_sep %>% 
  select(u_ucdp_pa_country_year_paid, 
         u_ucdp_pa_country_year_country, 
         u_ucdp_pa_country_year_year) %>% 
  arrange(u_ucdp_pa_country_year_paid, 
          u_ucdp_pa_country_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_pa_country_year)))

write_unit_table(u_ucdp_pa_country_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_pa_country_year.rds"),
                 tag = "u_ucdp_pa_country_year")