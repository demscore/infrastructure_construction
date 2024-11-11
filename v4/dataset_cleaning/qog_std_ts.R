library(dplyr)
library(demutils)

db <- pg_connect()

qog_std_ts <- read_datasets("qog_std_ts", db, original = TRUE)



# Remove country-year observations for countries before their independence, i.e.
# rows that only have missing values or NAs
qog_std_ts <- 
  qog_std_ts[rowSums(is.na(qog_std_ts[, !grepl("^ccode|^cname|^version|^year", 
                                               names(qog_std_ts))]) | 
                                   qog_std_ts[, !grepl("^ccode|^cname|^version|^year", 
                                               names(qog_std_ts))] == "") < 
               ncol(qog_std_ts[, !grepl("^ccode|^cname|^version|^year", 
                                               names(qog_std_ts))]),]


# Removing variables for which QoG did not receive permission to include in Demscore.
qog_std_ts <- select(qog_std_ts, !starts_with(c("shec_", "al_", "lp_", "bi_")))

# Clean column names
names(qog_std_ts) <- clean_column_names(names(qog_std_ts))

# Create unit columns
qog_std_ts$u_qog_country_year_country <- 
  qog_std_ts$cname

qog_std_ts$u_qog_country_year_year <- 
  as.integer(qog_std_ts$year)

qog_std_ts$u_qog_country_year_ccode <- 
  as.numeric(qog_std_ts$ccode)

qog_std_ts$u_qog_country_year_ccodecow <- 
  as.numeric(qog_std_ts$ccodecow) # has NAs 

qog_std_ts$u_qog_country_year_ccodecow[is.na(qog_std_ts$u_qog_country_year_ccodecow)] <- 
  as.numeric(-11111)

qog_std_ts$u_qog_country_year_ccodealp <- 
  qog_std_ts$ccodealp


qog_std_ts %<>% mutate(u_qog_country_year_country = case_when(
  u_qog_country_year_ccode == 384 ~ "Ivory Coast",
  TRUE ~ u_qog_country_year_country
))

# Check for duplicates in column names
# no_duplicate_names(qog_std_ts)


# Save
write_dataset(qog_std_ts,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_std_ts_cleaned.rds"),
           tag = "qog_std_ts",
           overwrite = TRUE)