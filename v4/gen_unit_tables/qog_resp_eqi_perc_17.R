library(dplyr)
library(demutils)

db <- pg_connect()

qog_perceive_survey17 <- read_datasets("qog_perceive_survey17", db)

# Create unit table
u_qog_resp_eqi_perc_17 <- 
  	qog_perceive_survey17 %>%
	  select(u_qog_resp_eqi_perc_17_id,
	         u_qog_resp_eqi_perc_17_nuts1,
	         u_qog_resp_eqi_perc_17_nuts2,
	         u_qog_resp_eqi_perc_17_country) %>%
  distinct(.) %>%
  arrange(u_qog_resp_eqi_perc_17_id, u_qog_resp_eqi_perc_17_country)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_qog_resp_eqi_perc_17)))

write_unit_table(u_qog_resp_eqi_perc_17, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_qog_resp_eqi_perc_17.rds"),
           tag = "u_qog_resp_eqi_perc_17")