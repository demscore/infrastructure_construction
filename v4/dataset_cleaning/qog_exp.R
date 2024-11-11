library(dplyr)
library(demutils)

db <- pg_connect()

qog_exp <- read_datasets("qog_exp", db, original = TRUE)

# Clean column names
names(qog_exp) <- clean_column_names(names(qog_exp))

no_duplicates(qog_exp, c("cname"))
no_duplicates(qog_exp, c("ccodealp"))
no_duplicates(qog_exp, c("ccodecow"))
no_duplicates(qog_exp, c("ccode"))
no_duplicates(qog_exp, c("ccodewb"))

# Create unit columns
qog_exp$u_qog_country_country <- qog_exp$cname

qog_exp$u_qog_country_ccodealp <- qog_exp$ccodealp

qog_exp$u_qog_country_ccodecow <- qog_exp$ccodecow

qog_exp$u_qog_country_ccode <- qog_exp$ccode

# Replace missing values
qog_exp$u_qog_country_ccodecow[is.na(qog_exp$u_qog_country_ccodecow)] <- 
  as.integer(-11111)

qog_exp$u_qog_country_ccode[is.na(qog_exp$u_qog_country_ccode)] <- 
  as.integer(-11111)

qog_exp %<>% mutate(u_qog_country_ccodealp = case_when(
  u_qog_country_ccodealp == "" ~ "XXX",
  TRUE ~ u_qog_country_ccodealp
))
  
# Check for duplicates in column names
no_duplicate_names(qog_exp)


write_dataset(qog_exp,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_exp_cleaned.rds"),
           tag = "qog_exp",
           overwrite = TRUE)
