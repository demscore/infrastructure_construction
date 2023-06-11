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
  as.integer(-11111)

qog_ei$u_qog_country_year_ccodecow <- 
  qog_ei$ccodecow

qog_ei$u_qog_country_year_ccodecow[is.na(qog_ei$u_qog_country_year_ccodecow)] <- 
  as.integer(-11111)

qog_ei$u_qog_country_year_ccodealp <- 
  qog_ei$ccodealp

any(is.na(qog_ei$u_qog_country_year_ccode))

# Check for duplicates in column names
no_duplicate_names(qog_ei)


write_dataset(qog_ei,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_ei_cleaned.rds"),
           tag = "qog_ei",
           overwrite = TRUE)
