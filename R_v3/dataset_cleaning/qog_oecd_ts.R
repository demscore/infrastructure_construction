library(dplyr)
library(demutils)

db <- pg_connect()

qog_oecd_ts <- read_datasets("qog_oecd_ts", db, original = TRUE)

qog_oecd_ts <- 
  qog_oecd_ts[rowSums(is.na(qog_oecd_ts[, !grepl("^ccode|^cname|^version|^year", 
                                               names(qog_oecd_ts))]) | 
                       qog_oecd_ts[, !grepl("^ccode|^cname|^version|^year", 
                                           names(qog_oecd_ts))] == "") < 
               ncol(qog_oecd_ts[, !grepl("^ccode|^cname|^version|^year", 
                                        names(qog_oecd_ts))]),]


# Removing variables for which QoG did not receive permission to include in Demscore.
qog_oecd_ts <- select(qog_oecd_ts, !starts_with(c("shec_", "al_", "lp_", "bi_")))

no_duplicates(qog_oecd_ts, c("cname_qog", "year")) #TRUE
no_duplicates(qog_oecd_ts, c("cname", "year")) #TRUE
no_duplicates(qog_oecd_ts, c("ccodealp", "year")) #TRUE
no_duplicates(qog_oecd_ts, c("cname_year")) #TRUE
no_duplicates(qog_oecd_ts, c("ccodealp_year")) #TRUE
no_duplicates(qog_oecd_ts, c("ccodecow", "year")) #FALSE
no_duplicates(qog_oecd_ts, c("ccode_qog", "year")) #TRUE


# Clean column names
names(qog_oecd_ts) <- clean_column_names(names(qog_oecd_ts))

# Create unit columns
qog_oecd_ts$u_qog_country_year_country <- 
  qog_oecd_ts$cname

unique(qog_oecd_ts$u_qog_country_year_country)

qog_oecd_ts$u_qog_country_year_year <- 
  qog_oecd_ts$year

qog_oecd_ts$u_qog_country_year_ccode <- 
  as.numeric(qog_oecd_ts$ccode)

qog_oecd_ts$u_qog_country_year_ccodecow <- 
  as.numeric(qog_oecd_ts$ccodecow)

qog_oecd_ts$u_qog_country_year_ccodecow[is.na(qog_oecd_ts$u_qog_country_year_ccodecow)] <- 
  as.numeric(-11111)

qog_oecd_ts$u_qog_country_year_ccodealp <- 
  qog_oecd_ts$ccodealp

qog_oecd_ts %<>%
  mutate(u_qog_country_year_country = case_when(
    u_qog_country_year_country == "Czechia" & u_qog_country_year_year <= 1992 ~ "Czechoslovakia",
    TRUE ~ u_qog_country_year_country)) %>%
  mutate(u_qog_country_year_ccodealp = case_when(
    u_qog_country_year_country == "Czechoslovakia" & u_qog_country_year_year <= 1992 ~ "CSK",
    TRUE ~ u_qog_country_year_ccodealp)) %>%
  mutate(u_qog_country_year_ccode = case_when(
    u_qog_country_year_ccode == 203 & u_qog_country_year_year <= 1992 ~ 200,
    TRUE ~ u_qog_country_year_ccode)) %>%
  mutate(u_qog_country_year_ccodecow = case_when(
    u_qog_country_year_ccodecow == 316 & u_qog_country_year_year <= 1992 ~ 315,
    TRUE ~ u_qog_country_year_ccodecow
  ))

# Check for duplicates in column names
no_duplicate_names(qog_oecd_ts)


write_dataset(qog_oecd_ts,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_oecd_ts_cleaned.rds"),
           tag = "qog_oecd_ts",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(qog_oecd_ts,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_dta/qog_oecd_ts_cleaned.dta"),
           overwrite = TRUE)

write_file(qog_oecd_ts,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_csv/qog_oecd_ts_cleaned.csv"),
           overwrite = TRUE)
