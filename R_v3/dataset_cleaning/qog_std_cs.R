library(dplyr)
library(demutils)

db <- pg_connect()

qog_std_cs <- read_datasets("qog_std_cs", db, original = TRUE)

# Only keep variables form CS dataset that are not in TS dataset
qog_std_ts <- read_datasets("qog_std_ts", db, original = TRUE)

cs <- setdiff(names(qog_std_cs), names(qog_std_ts))

cs <- c("ccode", "cname", "ccode_qog", "cname_qog", "ccodealp", "ccodecow", "version", cs)

qog_std_cs <- qog_std_cs[names(qog_std_cs) %in% cs]


# Identify dataset unit
no_duplicates(qog_std_cs, c("ccode_qog")) #TRUE
no_duplicates(qog_std_cs, c("cname_qog")) #TRUE
no_duplicates(qog_std_cs, c("cname")) #TRUE
no_duplicates(qog_std_cs, c("ccodealp")) #TRUE
no_duplicates(qog_std_cs, c("ccodecow")) #TRUE, but NAs
no_duplicates(qog_std_cs, c("ccode")) #TRUE

# Clean column names
names(qog_std_cs) <- clean_column_names(names(qog_std_cs))

# Create unit columns
qog_std_cs$u_qog_country_country <- qog_std_cs$cname

qog_std_cs$u_qog_country_ccodealp <- qog_std_cs$ccodealp

qog_std_cs$u_qog_country_ccodecow <- qog_std_cs$ccodecow

qog_std_cs$u_qog_country_ccode <- qog_std_cs$ccode

# Replace missing values
qog_std_cs$u_qog_country_ccodecow[is.na(qog_std_cs$u_qog_country_ccodecow)] <- 
  as.integer(-11111)

qog_std_cs$u_qog_country_ccode[is.na(qog_std_cs$u_qog_country_ccode)] <- 
  as.integer(-11111)


# Check for duplicates in column names
no_duplicate_names(qog_std_cs)

write_dataset(qog_std_cs,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_std_cs_cleaned.rds"),
           tag = "qog_std_cs",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(qog_std_cs,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_dta/qog_std_cs_cleaned.dta"),
           overwrite = TRUE)

write_file(qog_std_cs,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_csv/qog_std_cs_cleaned.csv"),
           overwrite = TRUE)