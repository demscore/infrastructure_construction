library(dplyr)
library(demutils)

db <- pg_connect()

hdata_infocap <- read_datasets("hdata_infocap", db)
hdata_fomin <- read_datasets("hdata_fomin", db)
hdata_conflict_cy <- read_datasets("hdata_conflict_cy", db)

# Aggregate hdata_fomin to country_year unit
hdata_fomin <- hdata_minister_date_to_country_year(hdata_fomin)


# Bind to unit table
u_hdata_country_year <-
  bind_rows(select(hdata_infocap, 
                   u_hdata_country_year_country,
                   u_hdata_country_year_cowcode,
                   u_hdata_country_year_year), 
            select(hdata_fomin, 
                   u_hdata_country_year_country,
                   u_hdata_country_year_cowcode,
                   u_hdata_country_year_year),
            select(hdata_conflict_cy, 
                   u_hdata_country_year_country,
                   u_hdata_country_year_cowcode,
                   u_hdata_country_year_year)) %>%
  mutate(u_hdata_country_year_cowcode = case_when(
    u_hdata_country_year_country == "Germany" & 
      u_hdata_country_year_year <= 1991 &
      u_hdata_country_year_year >= 1951 ~ 255, 
    u_hdata_country_year_country == "Austria" ~ 305,
    u_hdata_country_year_country == "Brunswick" ~ 99901,
    u_hdata_country_year_country == "Hamburg" ~ 99902,
    u_hdata_country_year_country == "Oldenburg" ~ 99903,
    u_hdata_country_year_country == "Nassau" ~ 99905,
    TRUE ~ as.numeric(u_hdata_country_year_cowcode)
    )) %>%
  distinct(.) %>%
  arrange(u_hdata_country_year_country, u_hdata_country_year_year)

stopifnot("There are duplicates for this combination of identifiers." = 
            no_duplicates(u_hdata_country_year, c("u_hdata_country_year_country",
                                                           "u_hdata_country_year_cowcode",
                                                           "u_hdata_country_year_year")))

stopifnot("There are missing values in the unit columns." = !any(is.na(u_hdata_country_year)))

write_unit_table(u_hdata_country_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_hdata_country_year.rds"), 
                 tag = "u_hdata_country_year")
