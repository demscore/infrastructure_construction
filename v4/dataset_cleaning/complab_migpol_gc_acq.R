library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_gc_acq <- read_datasets("complab_migpol_gc_acq", db, original = TRUE)

no_duplicates(complab_migpol_gc_acq, c("country_full_name", "year"))

# Clean column names
names(complab_migpol_gc_acq) <- clean_column_names(names(complab_migpol_gc_acq))

# Create unit columns
complab_migpol_gc_acq$u_complab_country_year_country <- 
  complab_migpol_gc_acq$country_full_name

complab_migpol_gc_acq$u_complab_country_year_country_code <- 
  toupper(complab_migpol_gc_acq$iso3)

complab_migpol_gc_acq$u_complab_country_year_year <- 
  as.integer(complab_migpol_gc_acq$year)


# Final check for duplicates in column names
no_duplicate_names(complab_migpol_gc_acq)

write_dataset(complab_migpol_gc_acq,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_migpol_gc_acq_cleaned.rds"),
              tag = "complab_migpol_gc_acq",
              overwrite = TRUE)
