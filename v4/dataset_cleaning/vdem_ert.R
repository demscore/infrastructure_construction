library(dplyr)
library(demutils)

db <- pg_connect()

vdem_ert <- read_datasets("vdem_ert", db, original = TRUE)

# Removing first column because it is not a V-Dem variable, just a repeat of row numbering.
vdem_ert <- select(vdem_ert, -1)

# Remove rows for DDR 1945 to 1948
vdem_ert %<>% filter(!(country_text_id == "DDR" & year < 1949))

# Clean column names
names(vdem_ert) <- clean_column_names(names(vdem_ert))

# Duplicates check to identify units
no_duplicates(vdem_ert, c("country_text_id", "year")) #TRUE
#no_duplicates(vdem_ert, c("country_id", "year")) #TRUE
#no_duplicates(vdem_ert, c("reg_id", "year")) #FALSE, 44 dups 

# Create unit columns
vdem_ert$u_vdem_country_year_country <- 
  vdem_ert$country_name

vdem_ert$u_vdem_country_year_country_text_id <- 
  vdem_ert$country_text_id

vdem_ert$u_vdem_country_year_country_id <- 
  vdem_ert$country_id

vdem_ert$u_vdem_country_year_year <- 
  as.numeric(vdem_ert$year)

# We need to create this column as it is necessary for the V-Dem CY unit but does
# not originally exist in vdem_ert. Therefore we first have to merge in the cowcodes
cowcodes <- read_file(file.path(Sys.getenv("ROOT_DIR"), "datasets", "vdem", "ERT", "cowcodes.rds"))

vdem_ert <- left_join(vdem_ert, cowcodes, by = c("u_vdem_country_year_country_text_id", "u_vdem_country_year_year"))

vdem_ert %<>% mutate(u_vdem_country_year_country = case_when(
  u_vdem_country_year_country == "Turkey" ~ 'Türkiye',
  TRUE ~ u_vdem_country_year_country
))

#save
write_dataset(vdem_ert,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/vdem/cleaned_datasets/vdem_ert_cleaned.rds"),
           tag = "vdem_ert",
           overwrite = TRUE)
