library(dplyr)
library(demutils)

db <- pg_connect()

qog_qad_inst <- read_datasets("qog_qad_inst", db, original = TRUE)

# Clean column names
names(qog_qad_inst) <- clean_column_names(names(qog_qad_inst))

# Duplicates check to identify units
no_duplicates(qog_qad_inst, c("agency_id", "agency_instruction")) #TRUE

# Create unit columns
qog_qad_inst$u_qog_agency_inst_agency_id <- 
  qog_qad_inst$agency_id

qog_qad_inst$u_qog_agency_inst_agency_name <- 
  qog_qad_inst$agency_name

qog_qad_inst$u_qog_agency_inst_agency_instruction <- 
  qog_qad_inst$agency_instruction


# Check for duplicates in column names
no_duplicate_names(qog_qad_inst)


write_dataset(qog_qad_inst,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_qad_inst_cleaned.rds"),
           tag = "qog_qad_inst",
           overwrite = TRUE)