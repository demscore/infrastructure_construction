library(dplyr)
library(demutils)

db <- pg_connect()

qog_qad_inst <- read_datasets("qog_qad_inst", db)

# Create unit table
u_qog_agency_inst <- qog_qad_inst %>% 
  select(u_qog_agency_inst_agency_id, 
         u_qog_agency_inst_agency_name, 
         u_qog_agency_inst_agency_instruction) %>%
  distinct(.) %>%
  arrange(u_qog_agency_inst_agency_name, 
          u_qog_agency_inst_agency_instruction)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_qog_agency_inst)))

write_unit_table(u_qog_agency_inst, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_qog_agency_inst.rds"),
                 tag = "u_qog_agency_inst")
