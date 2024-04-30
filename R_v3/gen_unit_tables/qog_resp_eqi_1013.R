library(dplyr)
library(demutils)

db <- pg_connect()

qog_eqi_ind_1013 <- read_datasets("qog_eqi_ind_1013", db)

# Create unit table
u_qog_resp_eqi_1013 <- 
  bind_rows(select(qog_eqi_ind_1013, 
                   u_qog_resp_eqi_1013_id, 
                   u_qog_resp_eqi_1013_resp_id,
                   u_qog_resp_eqi_1013_year,
                   u_qog_resp_eqi_1013_nuts,
                   u_qog_resp_eqi_1013_nuts_name,
                   u_qog_resp_eqi_1013_country
                   )) %>%
  distinct(.) %>%
  arrange(u_qog_resp_eqi_1013_id, 
          u_qog_resp_eqi_1013_resp_id)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_qog_resp_eqi_1013)))

write_unit_table(u_qog_resp_eqi_1013, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_qog_resp_eqi_1013.rds"),
                 tag = "u_qog_resp_eqi_1013")