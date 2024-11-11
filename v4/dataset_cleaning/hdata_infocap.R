library(dplyr)
library(demutils)

db <- pg_connect()

hdata_infocap <- read_datasets("hdata_infocap", db, original = TRUE)

# Clean column names
names(hdata_infocap) <- clean_column_names(names(hdata_infocap))

# Duplicates check to identify units
no_duplicates(hdata_infocap, c("ccodecow", "year")) #TRUE
no_duplicates(hdata_infocap, c("cname", "year")) #TRUE

# Duplicate columns for unit tables
hdata_infocap$u_hdata_country_year_country <- 
  hdata_infocap$cname

hdata_infocap$u_hdata_country_year_year <- 
  as.integer(hdata_infocap$year)

hdata_infocap$u_hdata_country_year_cowcode <- 
  as.numeric(hdata_infocap$ccodecow)

hdata_infocap$u_hdata_country_year_cowcode[is.na(hdata_infocap$u_hdata_country_year_cowcode)] <- 
  as.numeric(-11111)

# Final duplicates check column names
no_duplicate_names(hdata_infocap)


write_dataset(hdata_infocap, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/hdata/cleaned_datasets/hdata_infocap_cleaned.rds"),
              tag= "hdata_infocap",
              overwrite = TRUE)