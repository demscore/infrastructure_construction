library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_dyadic <- read_datasets("ucdp_dyadic", db) 

ucdp_dyad_location_sep <- tidyr::separate_rows(ucdp_dyadic, u_ucdp_dyad_location_year_location, 
                                               u_ucdp_dyad_location_year_gwno_loc, sep = ", ")

no_duplicates(ucdp_dyad_location_sep, c("u_ucdp_dyad_location_year_dyad_id", 
                                        "u_ucdp_dyad_location_year_year",
                                        "u_ucdp_dyad_location_year_location"))

u_ucdp_dyad_location_year <- ucdp_dyad_location_sep %>% 
  select(u_ucdp_dyad_location_year_dyad_id, 
         u_ucdp_dyad_location_year_location, 
         u_ucdp_dyad_location_year_year,
         u_ucdp_dyad_location_year_gwno_loc) %>% 
  arrange(u_ucdp_dyad_location_year_dyad_id, 
          u_ucdp_dyad_location_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_dyad_location_year)))

write_unit_table(u_ucdp_dyad_location_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_dyad_location_year.rds"),
                 tag = "u_ucdp_dyad_location_year")
