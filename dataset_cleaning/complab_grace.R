library(dplyr)
library(demutils)

db <- pg_connect()

complab_grace <- read_datasets("complab_grace", db, original = TRUE)

# Clean column names
names(complab_grace) <- clean_column_names(names(complab_grace))

# Create unit columns
complab_grace$u_complab_country_year_country <- 
  complab_grace$country

complab_grace$u_complab_country_year_country_nr <- 
  as.numeric(complab_grace$ccode)

complab_grace$u_complab_country_year_country_code <- 
  complab_grace$iso3c

complab_grace$u_complab_country_year_year <- 
  as.integer(complab_grace$year)


# Final check for duplicates in column names
no_duplicate_names(complab_grace)


write_dataset(complab_grace,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_grace_cleaned.rds"),
              tag = "complab_grace",
              overwrite = TRUE)
