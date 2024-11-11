library(dplyr)
library(demutils)

db <- pg_connect()

qog_ei <- read_datasets("qog_ei", db, original = TRUE, encoding = "Latin-1")

# Removing first column, repeat of row numbering.
qog_ei <- select(qog_ei, -1)

# Removing variables which QoG did not receive permission to use in demscore.
qog_ei <- select(qog_ei, !starts_with(c("shec_", "al_", "lp_", "bi_")))

# Clean column names
names(qog_ei) <- clean_column_names(names(qog_ei))

# Create unit columns
qog_ei$u_qog_country_year_country <- 
  qog_ei$cname

qog_ei$u_qog_country_year_year <- 
  qog_ei$year

qog_ei$u_qog_country_year_ccode <- 
  as.numeric(qog_ei$ccode)

qog_ei$u_qog_country_year_ccode[is.na(qog_ei$u_qog_country_year_ccode)] <- 
  as.numeric(-11111)

qog_ei$u_qog_country_year_ccodecow <- 
  as.numeric(qog_ei$ccodecow)

qog_ei$u_qog_country_year_ccodecow[is.na(qog_ei$u_qog_country_year_ccodecow)] <- 
  as.numeric(-11111)

qog_ei$u_qog_country_year_ccodealp <- 
  qog_ei$ccodealp

# Country names and country codes vary partly across different QoG datasets. 
# We adjust them to the names and codes used in QoG STD TS.

qog_ei %<>%
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
    u_qog_country_year_country == "Venezuela, Bolivarian Republic of" ~ "Venezuela (Bolivarian Republic of)",
    u_qog_country_year_country == "United States of America" ~ "United States of America (the)",
    u_qog_country_year_country == "United Arab Emirates" ~ "United Arab Emirates (the)",
    u_qog_country_year_country == "Syrian Arab Republic" ~ "Syrian Arab Republic (the)",
    u_qog_country_year_country == "Democratic Yemen" ~ "Yemen Democratic",
    u_qog_country_year_country == "Russia" ~ "Russian Federation (the)",
    u_qog_country_year_country == "Guinea Bissau" ~ "Guinea-Bissau",
    u_qog_country_year_country == "Philippines" ~ "Philippines (the)",
    u_qog_country_year_country == "Federated States of Micronesia" ~ "Micronesia (Federated States of)",
    u_qog_country_year_country == "Niger" ~ "Niger (the)",
    u_qog_country_year_country == "Republic of Moldova" ~ "Moldova (the Republic of)",
    u_qog_country_year_country == "Lao People’s Democratic Republic" ~ "Lao People's Democratic Republic (the)",
    u_qog_country_year_country == "Republic of Korea" ~ "Korea (the Republic of)",
    u_qog_country_year_country == "Democratic People's Republic of Korea" ~ "Korea (the Democratic People's Republic of)",
    u_qog_country_year_country == "Taiwan" ~ "Taiwan (Province of China)",
    u_qog_country_year_country == "South Vietnam" ~ "Vietnam, South",
    u_qog_country_year_country == "North Vietnam" ~ "Vietnam, North",
    u_qog_country_year_ccodecow == 812 ~ "Lao People's Democratic Republic (the)",
    u_qog_country_year_ccode == 384 ~ "Ivory Coast",
    u_qog_country_year_ccodealp == "SDN" & 
      u_qog_country_year_year >= 2012 ~ "Sudan (the)",
    u_qog_country_year_country == "Yemen Arab Republic" ~ "Yemen",
    TRUE ~ u_qog_country_year_country)) %>%
  mutate(u_qog_country_year_ccode = case_when(
    # In QOG EI Sudan 2012-2021 has ccode == 736 (-2011 ccode == 729), in QoG STD TS Sudan -2011 AND Sudan 2012-2021 have ccode = 729.
    u_qog_country_year_ccode == 736 ~ 729,
    # Tibet has a ccode in GoG STD TS but not in QoG EI
    u_qog_country_year_country == "Tibet" ~ 994,
    u_qog_country_year_country == "Vietnam, South" ~ 999,
    u_qog_country_year_country == "Vietnam, North" ~ 998,
    u_qog_country_year_country == "Yemen" & 
      u_qog_country_year_year <= 1989 ~ 886,
    # In QoG EI, Germany 1946-2020 has ccode 276, in QoG STD TS Germany 1949-1990 has ccode 280
    u_qog_country_year_country == "Germany" &
      u_qog_country_year_year <= 1990 ~ 280,
    TRUE ~ as.numeric(u_qog_country_year_ccode)
  )) 

any(is.na(qog_ei$u_qog_country_year_ccode))

# Check for duplicates in column names
no_duplicate_names(qog_ei)


write_dataset(qog_ei,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_ei_cleaned.rds"),
           tag = "qog_ei",
           overwrite = TRUE)

