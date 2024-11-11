library(dplyr)
library(demutils)

db <- pg_connect()

qog_eqi_ind_1013 <- read_datasets("qog_eqi_ind_1013", db, original = TRUE)

# Clean colnames
names(qog_eqi_ind_1013) <- clean_column_names(names(qog_eqi_ind_1013))

# Duplicates check to identify units
no_duplicates(qog_eqi_ind_1013, c("resp_id")) #FALSE, but duplicates are removed below
no_duplicates(qog_eqi_ind_1013, c("id")) #FALSE, but duplicates are removed below

# Create unit columns
qog_eqi_ind_1013$u_qog_resp_eqi_1013_id <- 
  qog_eqi_ind_1013$id

qog_eqi_ind_1013$u_qog_resp_eqi_1013_resp_id <- 
  qog_eqi_ind_1013$resp_id

qog_eqi_ind_1013$u_qog_resp_eqi_1013_year <- 
  qog_eqi_ind_1013$year

qog_eqi_ind_1013$u_qog_resp_eqi_1013_nuts <- 
  qog_eqi_ind_1013$nuts

qog_eqi_ind_1013$u_qog_resp_eqi_1013_nuts_name <- 
  qog_eqi_ind_1013$nuts_name

qog_eqi_ind_1013 %<>%
  mutate(u_qog_resp_eqi_1013_country = case_when(
    country == 1 ~ "France",
    country == 2 ~ "Bulgaria",
    country == 3 ~ "Portugal",
    country == 4 ~ "Denmark",
    country == 5 ~ "Sweden",
    country == 6 ~ "Belgium",
    country == 7 ~ "Croatia",
    country == 8 ~ "Greece",
    country == 9 ~ "Germany",
    country == 10 ~ "Italy",
    country == 11 ~ "Spain",
    country == 12 ~ "UK",
    country == 13 ~ "Hungary",
    country == 14 ~ "Czech Republic",
    country == 15 ~ "Slovakia",
    country == 16 ~ "Romania",
    country == 17 ~ "Austria",
    country == 18 ~ "Netherlands (the)",
    country == 19 ~ "Poland",
    country == 20 ~ "Finland",
    country == 21 ~ "Ireland",
    country == 22 ~ "Turkey",
    country == 23 ~ "Serbia",
    country == 24 ~ "Ukraine",
    country == 25 ~ "Kosovo",
    TRUE ~ as.character(country)
  ))

# Removing the six observations with NA for id, as suggested by QoG.
qog_eqi_ind_1013 <- qog_eqi_ind_1013[!is.na(qog_eqi_ind_1013$id),]

no_duplicates(qog_eqi_ind_1013, c("resp_id"))

# Final duplicate check
no_duplicate_names(qog_eqi_ind_1013)


write_dataset(qog_eqi_ind_1013,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_eqi_ind_1013_cleaned.rds"),
           tag = "qog_eqi_ind_1013",
           overwrite = TRUE)
