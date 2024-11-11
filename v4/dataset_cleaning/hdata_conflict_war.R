library(dplyr)
library(demutils)

db <- pg_connect()

hdata_conflict_war <- read_datasets("hdata_conflict_war", db, original = TRUE)

# Clean column names
names(hdata_conflict_war) <- clean_column_names(names(hdata_conflict_war))
names(hdata_conflict_war)
any(is.na(hdata_conflict_war$cow_code))

df <- duplicates(hdata_conflict_war, c("isd_country", "war_name", "min_year"))


# Duplicate columns for unit tables
hdata_conflict_war$u_hdata_country_year_war_country <- 
  hdata_conflict_war$isd_country

hdata_conflict_war$u_hdata_country_year_war_min_year <- 
  hdata_conflict_war$min_year

hdata_conflict_war$u_hdata_country_year_war_war_name <- 
  hdata_conflict_war$war_name

hdata_conflict_war$u_hdata_country_year_war_vdem_country <- 
  hdata_conflict_war$v_dem_country

hdata_conflict_war$u_hdata_country_year_war_cowcode <- 
  hdata_conflict_war$cow_code

hdata_conflict_war$u_hdata_country_year_war_cowcode[is.na(hdata_conflict_war$u_hdata_country_year_war_cowcode)] <- 
  as.integer(-11111)

hdata_conflict_war$u_hdata_country_year_war_vdem_country[is.na(hdata_conflict_war$u_hdata_country_year_war_vdem_country)] <- 
  as.character("-11111")

# Final duplicates check column names
no_duplicate_names(hdata_conflict_war)


write_dataset(hdata_conflict_war, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/hdata/cleaned_datasets/hdata_conflict_war_cleaned.rds"),
              tag= "hdata_conflict_war",
              overwrite = TRUE)