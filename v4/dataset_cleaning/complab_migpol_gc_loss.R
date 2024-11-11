library(dplyr)
library(demutils)

db <- pg_connect()

complab_migpol_gc_loss <- read_datasets("complab_migpol_gc_loss", db, original = TRUE)

no_duplicates(complab_migpol_gc_loss, c("country_full_name", "year"))

# Clean column names
names(complab_migpol_gc_loss) <- clean_column_names(names(complab_migpol_gc_loss))

# Create unit columns
complab_migpol_gc_loss$u_complab_country_year_country <- 
  complab_migpol_gc_loss$country_full_name

complab_migpol_gc_loss$u_complab_country_year_country_code <- 
  toupper(complab_migpol_gc_loss$iso3)

complab_migpol_gc_loss$u_complab_country_year_year <- 
  as.integer(complab_migpol_gc_loss$year)

# Final check for duplicates in column names
no_duplicate_names(complab_migpol_gc_loss)

write_dataset(complab_migpol_gc_loss,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/complab_migpol_gc_loss_cleaned.rds"),
              tag = "complab_migpol_gc_loss",
              overwrite = TRUE)