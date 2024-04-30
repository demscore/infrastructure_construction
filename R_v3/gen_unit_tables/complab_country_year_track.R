library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_impic_rd <- read_datasets("complab_migpol_impic_rd", db)

u_complab_country_year_track <- 
  bind_rows(select(complab_migpol_impic_rd, 
                   u_complab_country_year_track_country,
                   u_complab_country_year_track_year, 
                   u_complab_country_year_track_country_code,
                   u_complab_country_year_track_track)) %>%
  distinct(.) %>%
  arrange(u_complab_country_year_track_country, 
          u_complab_country_year_track_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_complab_country_year_track)))

write_unit_table(u_complab_country_year_track, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_complab_country_year_track.rds"),
                 tag = "u_complab_country_year_track")
