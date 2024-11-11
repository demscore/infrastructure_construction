library(dplyr)
library(demutils)

db <- pg_connect()

qog_qad_bud <- read_datasets("qog_qad_bud", db, original = TRUE)

# Overwrite column names with clean column names
names(qog_qad_bud) <- clean_column_names(names(qog_qad_bud))

# Duplicates check to identify units
no_duplicates(qog_qad_bud, c("agency_id", "agency_fy")) #TRUE

# Create unit columns
qog_qad_bud$u_qog_agency_year_agency_id <- 
  qog_qad_bud$agency_id

qog_qad_bud$u_qog_agency_year_agency_name <- 
  qog_qad_bud$agency_name

qog_qad_bud$u_qog_agency_year_agency_fy <- 
  qog_qad_bud$agency_fy

#Check for dups in colnames
no_duplicate_names(qog_qad_bud)

write_dataset(qog_qad_bud,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_qad_bud_cleaned.rds"),
           tag = "qog_qad_bud",
           overwrite = TRUE)