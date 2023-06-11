library(dplyr)
library(demutils)

db <- pg_connect()

qog_std_ts <- read_datasets("qog_std_ts", db)
qog_oecd_ts <- read_datasets("qog_oecd_ts", db)
qog_eqi_cati_long <- read_datasets("qog_eqi_cati_long", db)
qog_ei <- read_datasets("qog_ei", db)


# Country names and country codes vary partly across different QoG datasets. We adjust them to the names and codes used in QoG STD TS.

# Create unit table
u_qog_country_year <- 
  bind_rows(select(qog_std_ts, 
                   u_qog_country_year_year, 
                   u_qog_country_year_country,
                   u_qog_country_year_ccode,
                   u_qog_country_year_ccodecow,
                   u_qog_country_year_ccodealp),
            select(qog_oecd_ts, 
                   u_qog_country_year_year, 
                   u_qog_country_year_country,
                   u_qog_country_year_ccode,
                   u_qog_country_year_ccodecow,
                   u_qog_country_year_ccodealp),
            select(qog_eqi_cati_long,
                   u_qog_country_year_year, 
                   u_qog_country_year_country,
                   u_qog_country_year_ccode,
                   u_qog_country_year_ccodecow,
                   u_qog_country_year_ccodealp),
            select(qog_ei,
                   u_qog_country_year_year, 
                   u_qog_country_year_country,
                   u_qog_country_year_ccode,
                   u_qog_country_year_ccodecow,
                   u_qog_country_year_ccodealp)
            )%>%
  mutate(u_qog_country_year_country = case_when(
    u_qog_country_year_country == "Czech Republic" ~ "Czechia",
    u_qog_country_year_country == "Netherlands" ~ "Netherlands (the)",
    u_qog_country_year_country == "United Kingdom" ~ "United Kingdom of Great Britain and Northern Ireland (the)",
    u_qog_country_year_country == "United Kingdom of Great Britain and Northern Ireland" ~ "United Kingdom of Great Britain and Northern Ireland (the)",
    u_qog_country_year_country == "United Republic of Tanzania" ~ "Tanzania, the United Republic of",
    u_qog_country_year_country == "Gambia (Republic of The)" ~ "Gambia (the)",
    u_qog_country_year_country == "Dominican Republic" ~ "Dominican Republic (the)",
    u_qog_country_year_country == "Bahamas" ~ "Bahamas (the)",
    u_qog_country_year_country == "Central African Republic" ~ "Central African Republic (the)",
    u_qog_country_year_country == "Central African republic" ~ "Central African Republic (the)",
    u_qog_country_year_country == "Comoros" ~ "Comoros (the)",
    u_qog_country_year_country == "Congo" ~ "Congo (the)",
    u_qog_country_year_country == "Democratic Republic of the Congo" ~ "Congo (the Democratic Republic of the)",
    u_qog_country_year_country == "Côte D'Ivoire" ~ "Côte d'Ivoire",
    u_qog_country_year_country == "Venezuela, Bolivarian Republic of" ~ "Venezuela (Bolivarian Republic of)",
    u_qog_country_year_country == "United States of America" ~ "United States of America (the)",
    u_qog_country_year_country == "United Arab Emirates" ~ "United Arab Emirates (the)",
    u_qog_country_year_country == "Syrian Arab Republic" ~ "Syrian Arab Republic (the)",
    u_qog_country_year_country == "Democratic Yemen" ~ "Yemen Democratic",
    u_qog_country_year_country == "Russia" ~ "Russian Federation (the)",
    u_qog_country_year_country == "Guinea Bissau" ~ "Guinea-Bissau",
    u_qog_country_year_country == "Philippines" ~ "Philippines (the)",
    u_qog_country_year_country == "Sudan" ~ "Sudan (the)",
    u_qog_country_year_country == "Federated States of Micronesia" ~ "Micronesia (Federated States of)",
    u_qog_country_year_country == "Niger" ~ "Niger (the)",
    u_qog_country_year_country == "Republic of Moldova" ~ "Moldova (the Republic of)",
    u_qog_country_year_country == "Lao People's Democratic Republic" ~ "Lao People's Democratic Republic (the)", # There is a tiny diff in the '
    u_qog_country_year_country == "Lao People’s Democratic Republic" ~ "Lao People's Democratic Republic (the)",
    u_qog_country_year_country == "Republic of Korea" ~ "Korea (the Republic of)",
    u_qog_country_year_country == "Democratic People's Republic of Korea" ~ "Korea (the Democratic People's Republic of)",
    u_qog_country_year_country == "Taiwan" ~ "Taiwan (Province of China)",
    TRUE ~ u_qog_country_year_country)) %>%
  mutate(u_qog_country_year_ccode = case_when(
    # In QOG EI Sudan 2012-2021 has ccode == 736 (-2011 ccode == 729), in QoG STD TS Sudan -2011 AND Sudan 2012-2021 have ccode = 729.
    u_qog_country_year_ccode == 736 & 
      u_qog_country_year_country == "Sudan (the)" ~ 729,
    # Tibet has a ccode in GoG STD TS but not in QoG EI
    u_qog_country_year_country == "Tibet" ~ 994,
    # In QoG EI, Germany 1946-2020 has ccode 276, in QoG STD TS Germany 1949-1990 has ccode 280
    u_qog_country_year_country == "Germany" &
      u_qog_country_year_year <= 1990 ~ 280,
    TRUE ~ as.numeric(u_qog_country_year_ccode)
  )) %>%
  mutate(u_qog_country_year_country = case_when(
    u_qog_country_year_ccodecow == 812 ~ "Lao People's Democratic Republic (the)",
    u_qog_country_year_ccodecow == 437 ~ "Côte d'Ivoire",
    TRUE ~ u_qog_country_year_country
  )) %>%
  distinct(.) %>%
  arrange(u_qog_country_year_country, 
          u_qog_country_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_qog_country_year)))

write_unit_table(u_qog_country_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_qog_country_year.rds"),
                 tag = "u_qog_country_year")
