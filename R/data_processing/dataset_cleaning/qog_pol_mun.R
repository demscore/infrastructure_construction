library(dplyr)
library(demutils)

db <- pg_connect()

qog_pol_mun <- read_datasets("qog_pol_mun", db, original = TRUE)

# Clean column names
names(qog_pol_mun) <- clean_column_names(names(qog_pol_mun))

# Duplicates check to identify units
no_duplicates(qog_pol_mun, c("municipality", "year")) #TRUE

# Create unit cols
qog_pol_mun$u_qog_municipality_year_municipality <- 
  qog_pol_mun$municipality

qog_pol_mun$u_qog_municipality_year_year <- 
  qog_pol_mun$year

# Check for duplicates in column names
no_duplicate_names(qog_pol_mun)


write_dataset(qog_pol_mun,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_pol_mun_cleaned.rds"),
           tag = "qog_pol_mun",
           overwrite = TRUE)