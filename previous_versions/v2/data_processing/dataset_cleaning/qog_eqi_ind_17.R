library(dplyr)
library(demutils)

db <- pg_connect()

qog_eqi_ind_17  <- read_datasets("qog_eqi_ind_17", db, original = TRUE)

# Clean colnames
names(qog_eqi_ind_17) <- clean_column_names(names(qog_eqi_ind_17))

# Duplicates check to identify units
no_duplicates(qog_eqi_ind_17, c("idfinal")) #TRUE

# Make unit column
qog_eqi_ind_17$u_qog_resp_eqi_17_idfinal <- 
  qog_eqi_ind_17$idfinal

qog_eqi_ind_17$u_qog_resp_eqi_17_country <- 
  qog_eqi_ind_17$country

qog_eqi_ind_17$u_qog_resp_eqi_17_nuts1 <- 
  substr(qog_eqi_ind_17$d7_nuts1, 1, 3)

qog_eqi_ind_17$u_qog_resp_eqi_17_nuts2 <- 
  substr(qog_eqi_ind_17$d7_nuts2, 1, 4)

# Duplicate check in colnames
no_duplicate_names(qog_eqi_ind_17)


write_dataset(qog_eqi_ind_17,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_eqi_ind_17_cleaned.rds"),
           tag = "qog_eqi_ind_17",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(qog_eqi_ind_17,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_dta/qog_eqi_ind_17_cleaned.dta"),
           overwrite = TRUE)

write_file(qog_eqi_ind_17,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_csv/qog_eqi_ind_17_cleaned.csv"),
           overwrite = TRUE)