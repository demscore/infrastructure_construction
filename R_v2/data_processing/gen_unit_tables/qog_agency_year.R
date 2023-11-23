library(dplyr)
library(demutils)

db <- pg_connect()

qog_qad_bud <- read_datasets("qog_qad_bud", db)

# Create unit table
u_qog_agency_year <- qog_qad_bud %>% 
  select(u_qog_agency_year_agency_id,
         u_qog_agency_year_agency_name,
         u_qog_agency_year_agency_fy) %>%
  distinct(.) %>%
  arrange(u_qog_agency_year_agency_name, 
          u_qog_agency_year_agency_fy)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_qog_agency_year)))

write_unit_table(u_qog_agency_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_qog_agency_year.rds"),
                 tag = "u_qog_agency_year")
