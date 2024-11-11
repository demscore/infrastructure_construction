library(dplyr)
library(demutils)

db <- pg_connect()

cses_imd <- read_datasets("cses_imd", db)

u_cses_respondent <- 
  bind_rows(select(cses_imd, 
                   u_cses_respondent_id,
                   u_cses_respondent_country,
                   u_cses_respondent_year, 
                   u_cses_respondent_vdem_country_code,
                   u_cses_respondent_country_code,
                   u_cses_respondent_cy_code,
                   u_cses_respondent_module)) %>%
  distinct(.) %>%
  arrange(u_cses_respondent_country, 
          u_cses_respondent_year) 

stopifnot("There are duplicates for this combination of identifiers." = 
            no_duplicates(u_cses_respondent, c("u_cses_respondent_id", 
                                               "u_cses_respondent_country",
                                               "u_cses_respondent_year",
                                               "u_cses_respondent_module")))

stopifnot("There are duplicates for this combination of identifiers." = 
            no_duplicates(u_cses_respondent, c("u_cses_respondent_id", 
                                               "u_cses_respondent_country_code",
                                               "u_cses_respondent_year",
                                               "u_cses_respondent_module")))

stopifnot("There are missing values in the unit columns." = !any(is.na(u_cses_respondent)))

write_unit_table(u_cses_respondent, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_cses_respondent.rds"),
                 tag = "u_cses_respondent")
