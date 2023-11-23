library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_demig_policy <- read_datasets("complab_migpol_demig_policy", db)

u_complab_country_year_policy <- 
  bind_rows(select(complab_migpol_demig_policy, 
                   u_complab_country_year_policy_country,
                   u_complab_country_year_policy_year, 
                   u_complab_country_year_policy_country_code,
                   u_complab_country_year_policy_policy)) %>%
              distinct(.) %>%
              arrange(u_complab_country_year_policy_country, 
                      u_complab_country_year_policy_year)

stopifnot("There are duplicates for this combination of identifiers." = 
            no_duplicates(u_complab_country_year_policy, c("u_complab_country_year_policy_country",
                                                           "u_complab_country_year_policy_year",
                                                           "u_complab_country_year_policy_policy")))

stopifnot("There are duplicates for this combination of identifiers." = 
            no_duplicates(u_complab_country_year_policy, c("u_complab_country_year_policy_country_code",
                                                           "u_complab_country_year_policy_year",
                                                           "u_complab_country_year_policy_policy")))

stopifnot("There are missing values in the unit columns." = !any(is.na(u_complab_country_year_policy)))

write_unit_table(u_complab_country_year_policy, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_complab_country_year_policy.rds"),
                 tag = "u_complab_country_year_policy")