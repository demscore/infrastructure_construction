library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_conflictic <- read_datasets("ucdp_prio_acd", db) 

ucdp_conflict_location_sep <- tidyr::separate_rows(ucdp_conflictic, u_ucdp_conflict_location_year_location, 
                                               u_ucdp_conflict_location_year_gwno_loc, sep = ", ")

no_duplicates(ucdp_conflict_location_sep, c("u_ucdp_conflict_location_year_conflict_id", 
                                            "u_ucdp_conflict_location_year_year",
                                            "u_ucdp_conflict_location_year_location"))

u_ucdp_conflict_location_year <- ucdp_conflict_location_sep %>% 
  select(u_ucdp_conflict_location_year_conflict_id, 
         u_ucdp_conflict_location_year_location, 
         u_ucdp_conflict_location_year_year,
         u_ucdp_conflict_location_year_gwno_loc) %>% 
  arrange(u_ucdp_conflict_location_year_conflict_id, 
          u_ucdp_conflict_location_year_year)

#u_ucdp_conflict_location_year$u_ucdp_conflict_location_year_gwno_loc <- 
#  as.integer(u_ucdp_conflict_location_year$u_ucdp_conflict_location_year_gwno_loc)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_conflict_location_year)))

write_unit_table(u_ucdp_conflict_location_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_conflict_location_year.rds"),
                 tag = "u_ucdp_conflict_location_year")