library(dplyr)
library(demutils)

db <- pg_connect()

vdem_vp_coder_level <- read_datasets("vdem_vp_coder_level", db, original = TRUE)

# Clean column names
names(vdem_vp_coder_level) <- clean_column_names(names(vdem_vp_coder_level))

# Duplicates check to identify units
no_duplicates(vdem_vp_coder_level, c("v2paid", "historical_date", "coder_id")) #TRUE

# Create unit columns for u_vdem_party_date_coder
vdem_vp_coder_level$historical_date <- as.Date(vdem_vp_coder_level$historical_date)

vdem_vp_coder_level$u_vdem_party_date_coder_country_text_id <- 
  vdem_vp_coder_level$country_text_id 

vdem_vp_coder_level$u_vdem_party_date_coder_v2paid <- 
  vdem_vp_coder_level$v2paid 

vdem_vp_coder_level$u_vdem_party_date_coder_historical_date <- 
  vdem_vp_coder_level$historical_date

vdem_vp_coder_level$u_vdem_party_date_coder_coder_id <- 
  vdem_vp_coder_level$coder_id

# Check for duplicates in column names
no_duplicate_names(vdem_vp_coder_level)

# Replace NAs
vdem_vp_coder_level[is.na(vdem_vp_coder_level)] <- -11111

#save
write_dataset(vdem_vp_coder_level,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/vdem/cleaned_datasets/vdem_vp_coder_level_cleaned.rds"),
           tag = "vdem_vp_coder_level",
           overwrite = TRUE)
