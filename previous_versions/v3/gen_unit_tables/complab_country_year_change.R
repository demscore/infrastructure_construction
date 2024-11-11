library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_demig_policy <- read_datasets("complab_migpol_demig_quantmig", db)

u_complab_country_year_change <- 
  bind_rows(select(complab_migpol_demig_policy, 
                   u_complab_country_year_change_country,
                   u_complab_country_year_change_year, 
                   u_complab_country_year_change_country_code,
                   u_complab_country_year_change_change)) %>%
              distinct(.) %>%
              arrange(u_complab_country_year_change_country, 
                      u_complab_country_year_change_year) 

stopifnot("There are duplicates for this combination of identifiers." = 
            no_duplicates(u_complab_country_year_change, c("u_complab_country_year_change_country",
                                                           "u_complab_country_year_change_year",
                                                           "u_complab_country_year_change_change")))

stopifnot("There are duplicates for this combination of identifiers." = 
            no_duplicates(u_complab_country_year_change, c("u_complab_country_year_change_country_code",
                                                           "u_complab_country_year_change_year",
                                                           "u_complab_country_year_change_change")))

stopifnot("There are missing values in the unit columns." = !any(is.na(u_complab_country_year_change)))

write_unit_table(u_complab_country_year_change, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_complab_country_year_change.rds"),
                 tag = "u_complab_country_year_change")