library(dplyr)
library(demutils)

db <- pg_connect()

qog_eqi_ind_21 <- read_datasets("qog_eqi_ind_21", db)

# Create unit table
u_qog_resp_eqi_21 <- 
  bind_rows(select(qog_eqi_ind_21, 
                   u_qog_resp_eqi_21_resp_id, 
                   u_qog_resp_eqi_21_country,
                   u_qog_resp_eqi_21_nuts1,
                   u_qog_resp_eqi_21_nuts2)) %>%
  distinct(.) %>%
  arrange(u_qog_resp_eqi_21_resp_id)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_qog_resp_eqi_21)))

write_unit_table(u_qog_resp_eqi_21, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_qog_resp_eqi_21.rds"),
                 tag = "u_qog_resp_eqi_21")