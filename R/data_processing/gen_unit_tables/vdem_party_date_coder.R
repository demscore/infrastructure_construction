library(dplyr)
library(demutils)

db <- pg_connect()

vdem_vp_coder_level <- read_datasets("vdem_vp_coder_level", db)

# Create unit table
u_vdem_party_date_coder <- vdem_vp_coder_level %>% 
  select(u_vdem_party_date_coder_country_text_id, 
         u_vdem_party_date_coder_v2paid, 
         u_vdem_party_date_coder_historical_date, 
         u_vdem_party_date_coder_coder_id) %>% 
  arrange(u_vdem_party_date_coder_v2paid,
          u_vdem_party_date_coder_historical_date)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_vdem_party_date_coder)))

write_unit_table(u_vdem_party_date_coder, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_vdem_party_date_coder.rds"),
           tag = "u_vdem_party_date_coder")