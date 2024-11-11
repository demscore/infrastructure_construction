library(dplyr)
library(demutils)

db <- pg_connect()

# Create Demscore Country-Year Unit based on V-Dem, H-DATA and GW

# Create H-DATA CY unit table
hdata_infocap <- read_datasets("hdata_infocap", db)
hdata_fomin <- read_datasets("hdata_fomin", db)

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
                   u_hdata_country_year_year)) %>%
  mutate(u_hdata_country_year_cowcode = case_when(
    u_hdata_country_year_country == "Germany" & 
      u_hdata_country_year_year <= 1991 &
      u_hdata_country_year_year >= 1951 ~ 255, 
    TRUE ~ as.numeric(u_hdata_country_year_cowcode)
  )) %>%
  mutate(u_hdata_country_year_cowcode = case_when(
    u_hdata_country_year_country == "Austria" ~ 305,
    TRUE ~ as.numeric(u_hdata_country_year_cowcode)
  )) %>%
  distinct(.) %>%
  arrange(u_hdata_country_year_country, u_hdata_country_year_year)


u_hdata_country_year %<>% filter(u_hdata_country_year_year < 1789) %>%
  select(u_demscore_country_year_country = u_hdata_country_year_country,
         u_demscore_country_year_code = u_hdata_country_year_cowcode,
         u_demscore_country_year_year = u_hdata_country_year_year)

# Create V-Dem CY unit table
vdem_cy <- read_datasets("vdem_cy", db)
vdem_ert <- read_datasets("vdem_ert", db)

u_vdem_country_year <- 
  bind_rows(select(vdem_cy, 
                   u_vdem_country_year_country,
                   u_vdem_country_year_country_text_id,
                   u_vdem_country_year_country_id,
                   u_vdem_country_year_cowcode,
                   u_vdem_country_year_year), 
            select(vdem_ert, 
                   u_vdem_country_year_country,
                   u_vdem_country_year_country_text_id,
                   u_vdem_country_year_country_id,
                   u_vdem_country_year_cowcode,
                   u_vdem_country_year_year)) %>%
  mutate(u_vdem_country_year_country = case_when(
    u_vdem_country_year_country == "Czech Republic" ~ "Czechia", 
    TRUE ~ u_vdem_country_year_country
  )) %>%
  distinct(.) %>% 
  arrange(u_vdem_country_year_country, 
          u_vdem_country_year_year)

u_vdem_country_year %<>% select(u_demscore_country_year_country = u_vdem_country_year_country,
                                u_demscore_country_year_code = u_vdem_country_year_cowcode,
                                u_demscore_country_year_year = u_vdem_country_year_year)

# Add missing country units with GW countries
gw_bahamas <- data.frame(u_demscore_country_year_country = "Bahamas", 
                         u_demscore_country_year_year = 1973:2022,
                         u_demscore_country_year_code = 31)

gw_belize <- data.frame(u_demscore_country_year_country = "Belize", 
                         u_demscore_country_year_year = 1981:2022,
                         u_demscore_country_year_code = 80)

gw_brunei <- data.frame(u_demscore_country_year_country = "Brunei", 
                         u_demscore_country_year_year = 1984:2022,
                         u_demscore_country_year_code = 835)

gw_easttimor <- data.frame(u_demscore_country_year_country = "East Timor", 
                         u_demscore_country_year_year = 2002:2022,
                         u_demscore_country_year_code = 860)

gw_gambia <- data.frame(u_demscore_country_year_country = "Gambia", 
                         u_demscore_country_year_year = 1965:2022,
                         u_demscore_country_year_code = 420)

gw_macedonia <- data.frame(u_demscore_country_year_country = "Macedonia (Former Yugoslav Republic of)", 
                         u_demscore_country_year_year = 1991:2022,
                         u_demscore_country_year_code = 343)

gw_surinam <- data.frame(u_demscore_country_year_country = "Surinam", 
                         u_demscore_country_year_year = 1975:2022,
                         u_demscore_country_year_code = 115)

gw_tibet <- data.frame(u_demscore_country_year_country = "Tibet", 
                         u_demscore_country_year_year = 1946:2022,
                         u_demscore_country_year_code = 711)


# Bind all dataframes to one unit table
u_demscore_country_year <- rbind(u_hdata_country_year, u_vdem_country_year, gw_bahamas, 
                                 gw_belize, gw_brunei, gw_easttimor, gw_gambia,
                                 gw_macedonia, gw_surinam, gw_tibet) %>%
  arrange(u_demscore_country_year_country, u_demscore_country_year_year) %>%
  distinct(.)

u_demscore_country_year$u_demscore_country_year_year <-
  as.integer(u_demscore_country_year$u_demscore_country_year_year)

u_demscore_country_year$u_demscore_country_year_code <- 
  as.integer(u_demscore_country_year$u_demscore_country_year_code)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_demscore_country_year)))


write_unit_table(u_demscore_country_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_demscore_country_year.rds"),
                 tag = "u_demscore_country_year")
