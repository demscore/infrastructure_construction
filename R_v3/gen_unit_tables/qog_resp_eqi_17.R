library(dplyr)
library(demutils)

db <- pg_connect()

qog_eqi_ind_17  <- read_datasets("qog_eqi_ind_17", db)

# Create unit table
u_qog_resp_eqi_17 <- 
  bind_rows(select(qog_eqi_ind_17, 
                   u_qog_resp_eqi_17_idfinal, 
                   u_qog_resp_eqi_17_country,
                   u_qog_resp_eqi_17_nuts1,
                   u_qog_resp_eqi_17_nuts2)
  )%>%
  distinct(.) %>%
  arrange(u_qog_resp_eqi_17_idfinal, u_qog_resp_eqi_17_country)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_qog_resp_eqi_17)))

write_unit_table(u_qog_resp_eqi_17, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_qog_resp_eqi_17.rds"),
                 tag = "u_qog_resp_eqi_17")
