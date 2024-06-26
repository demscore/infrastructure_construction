library(dplyr)
library(demutils)

db <- pg_connect()

# Truncate table, set counter to 1
# TRUNCATE country_years
pg_send_query(db, "TRUNCATE country_dates;")

# Set counter to 1
pg_send_query(db, 
              "SELECT setval('country_dates_cd_id_seq', 1, false);")

variables <- readRDS(file.path(
  Sys.getenv("ROOT_DIR"), "autogenerated_refs", "refs_prepped", "variables.rds"))

units_online <- DBI::dbGetQuery(db, "SELECT * FROM units;")

# Country-year units
CY_UNITS <- units_online %>%
  filter(unit_id %in% c(13, 117, 32, 45)) %$% unit_tag


lapply(CY_UNITS, function(u) {
  # u <- CY_UNITS[3]
  
  print(u)
  
  utable <- read_unit_table(u)
  UNIT_ID <- units_online$unit_id[units_online$unit_tag == u]
  stopifnot(!is.na(UNIT_ID))
  
  units_filtered <- units_online %>% filter(unit_id == UNIT_ID)
  country_col <- units_filtered$country_col
  min_date_col <- units_filtered$min_date_col
  max_date_col <- units_filtered$max_date_col
  
  
  stopifnot(!is.na(min_date_col), !is.na(max_date_col), !is.na(country_col))
  stopifnot(min_date_col %in% names(utable), 
            max_date_col %in% names(utable), 
            country_col %in% names(utable))
  
  names(utable)[names(utable) == country_col] <- "country_name"
  names(utable)[names(utable) == min_date_col] <- "min_date"
  
  if (u == "u_vdem_country_date"){
    utable %<>% mutate(max_date = min_date)
  } else {
        names(utable)[names(utable) == max_date_col] <- "max_date"
    }
  
  
  # Select only country_name
  utable %<>% distinct(country_name, min_date, max_date)
  class(utable) <- "data.frame"
  
  utable$unit_id <- UNIT_ID
  
  pg_send_query(db, 
                paste0("DELETE FROM country_dates WHERE unit_id = ", 
                       UNIT_ID, ";"))
  pg_append_table(utable, "country_dates", db)
  
})

DBI::dbDisconnect(db)
