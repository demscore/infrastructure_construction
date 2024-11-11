library(dplyr)
library(demutils)

db <- pg_connect()

qog_eqi_cati_long <- read_datasets("qog_eqi_cati_long", db, original = TRUE)


# Clean column names
names(qog_eqi_cati_long) <- clean_column_names(names(qog_eqi_cati_long))

no_duplicates(qog_eqi_cati_long, c("ccodealp", "year")) # TRUE
no_duplicates(qog_eqi_cati_long, c("cname", "year")) # TRUE


# Create unit columns
qog_eqi_cati_long$u_qog_country_year_country <- 
  qog_eqi_cati_long$cname

qog_eqi_cati_long$u_qog_country_year_year <- 
  qog_eqi_cati_long$year

qog_eqi_cati_long$u_qog_country_year_ccode <- 
  as.numeric(qog_eqi_cati_long$ccode)

qog_eqi_cati_long$u_qog_country_year_ccodecow <- 
  as.numeric(qog_eqi_cati_long$ccodecow)

qog_eqi_cati_long$u_qog_country_year_ccodealp <- 
  qog_eqi_cati_long$ccodealp

# Country names and country codes vary partly across different QoG datasets. 
# We adjust them to the names and codes used in QoG STD TS.

qog_eqi_cati_long %<>%
  mutate(u_qog_country_year_country = case_when(
    u_qog_country_year_country == "Czech Republic" ~ "Czechia",
    u_qog_country_year_country == "Netherlands" ~ "Netherlands (the)",
    u_qog_country_year_country == "United Kingdom" ~ "United Kingdom of Great Britain and Northern Ireland (the)",
    u_qog_country_year_country == "United Kingdom of Great Britain and Northern Ireland" ~ "United Kingdom of Great Britain and Northern Ireland (the)",
    TRUE ~ u_qog_country_year_country)) %>%
  mutate(u_qog_country_year_ccode = case_when(
    u_qog_country_year_country == "Germany" &
      u_qog_country_year_year <= 1990 ~ 280,
    TRUE ~ as.numeric(u_qog_country_year_ccode)
  ))

# Check duplicates in column names
no_duplicate_names(qog_eqi_cati_long)


write_dataset(qog_eqi_cati_long,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_eqi_cati_long_cleaned.rds"),
           tag = "qog_eqi_cati_long",
           overwrite = TRUE)
