library(dplyr)
library(demutils)

db <- pg_connect()

qog_oecd_ts <- read_datasets("qog_oecd_ts", db, original = TRUE)

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

qog_oecd_ts$u_qog_country_year_year <- 
  qog_oecd_ts$year

qog_oecd_ts$u_qog_country_year_ccode <- 
  as.numeric(qog_oecd_ts$ccode)

qog_oecd_ts$u_qog_country_year_ccodecow <- 
  qog_oecd_ts$ccodecow

qog_oecd_ts$u_qog_country_year_ccodecow[is.na(qog_oecd_ts$u_qog_country_year_ccodecow)] <- 
  as.integer(-11111)

qog_oecd_ts$u_qog_country_year_ccodealp <- 
  qog_oecd_ts$ccodealp

# Check for duplicates in column names
no_duplicate_names(qog_oecd_ts)


write_dataset(qog_oecd_ts,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_oecd_ts_cleaned.rds"),
           tag = "qog_oecd_ts",
           overwrite = TRUE)