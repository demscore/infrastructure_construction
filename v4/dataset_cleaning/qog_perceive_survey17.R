library(dplyr)
library(demutils)

db <- pg_connect()

qog_perceive_survey17 <- read_datasets("qog_perceive_survey17", db, original = TRUE)

# Clean column names
names(qog_perceive_survey17) <- clean_column_names(names(qog_perceive_survey17))

#changing typetel_ to typetel
if ("typetel_" %in% names(qog_perceive_survey17)) {
  names(qog_perceive_survey17)[names(qog_perceive_survey17) == "typetel_"] <- "typetel"
}

# Duplicates check to identify units
no_duplicates(qog_perceive_survey17, c("id")) #TRUE

# Create unit columns
qog_perceive_survey17$u_qog_resp_eqi_perc_17_country <- 
  qog_perceive_survey17$country

qog_perceive_survey17$u_qog_resp_eqi_perc_17_id <- 
  as.numeric(qog_perceive_survey17$id)

qog_perceive_survey17$u_qog_resp_eqi_perc_17_nuts1 <- 
  substr(qog_perceive_survey17$d8_nuts1, 1, 3)

qog_perceive_survey17$u_qog_resp_eqi_perc_17_nuts2 <- 
  substr(qog_perceive_survey17$d8_nuts2, 1, 4)

# Check for duplicates in column names
no_duplicate_names(qog_perceive_survey17)


write_dataset(qog_perceive_survey17,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_perceive_survey17_cleaned.rds"),
           tag = "qog_perceive_survey17",
           overwrite = TRUE)
