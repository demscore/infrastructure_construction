library(dplyr)
library(demutils)

db <- pg_connect()


qog_eqi_ind_21 <- read_datasets("qog_eqi_ind_21", db, original = TRUE)

# Clean colnames
names(qog_eqi_ind_21) <- clean_column_names(names(qog_eqi_ind_21))

# Duplicates check to identify units
no_duplicates(qog_eqi_ind_21, c("resp_id")) #TRUE

#Duplicate column for unit table
qog_eqi_ind_21$u_qog_resp_eqi_21_resp_id <- 
  qog_eqi_ind_21$resp_id

qog_eqi_ind_21$u_qog_resp_eqi_21_country <- 
  qog_eqi_ind_21$country

qog_eqi_ind_21$u_qog_resp_eqi_21_nuts1 <- 
  qog_eqi_ind_21$nuts1

qog_eqi_ind_21$u_qog_resp_eqi_21_nuts2 <- 
  qog_eqi_ind_21$nuts2

# Cheack dups in colnames
no_duplicate_names(qog_eqi_ind_21)

write_dataset(qog_eqi_ind_21,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_eqi_ind_21_cleaned.rds"),
           tag = "qog_eqi_ind_21",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(qog_eqi_ind_21,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_dta/qog_eqi_ind_21_cleaned.dta"),
           overwrite = TRUE)

write_file(qog_eqi_ind_21,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_csv/qog_eqi_ind_21_cleaned.csv"),
           overwrite = TRUE)