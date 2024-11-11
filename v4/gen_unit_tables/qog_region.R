library(dplyr)
library(demutils)

db <- pg_connect()

qog_eqi_agg21 <- read_datasets("qog_eqi_agg21", db)

# Create unit table
u_qog_region <- 
  bind_rows(select(qog_eqi_agg21, 
                   u_qog_region_region, 
                   u_qog_region_name,
                   u_qog_region_country)) %>%
  mutate(u_qog_region_name = case_when(
    u_qog_region_name == "Burgenland (AT)" ~ "Burgenland",
    TRUE ~ u_qog_region_name
  )) %>%
  distinct(.) %>%
  arrange(u_qog_region_region, 
          u_qog_region_name)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_qog_region)))

write_unit_table(u_qog_region, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_qog_region.rds"),
                 tag = "u_qog_region")