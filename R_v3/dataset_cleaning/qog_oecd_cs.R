library(dplyr)
library(demutils)

db <- pg_connect()

qog_oecd_cs <- read_datasets("qog_oecd_cs", db, original = TRUE)

# Only keep variables form CS dataset that are not in TS dataset
qog_std_ts <- read_datasets("qog_std_ts", db, original = TRUE)

cs <- setdiff(names(qog_oecd_cs), names(qog_std_ts))

cs <- c("ccode", "cname", "ccode_qog", "cname_qog", "ccodealp", "ccodecow", "version", cs)

qog_oecd_cs <- qog_oecd_cs[names(qog_oecd_cs) %in% cs]

# Identify dataset unit
no_duplicates(qog_oecd_cs, c("ccode_qog")) #TRUE
no_duplicates(qog_oecd_cs, c("cname_qog")) #TRUE
no_duplicates(qog_oecd_cs, c("cname")) #TRUE
no_duplicates(qog_oecd_cs, c("ccodealp")) #TRUE
no_duplicates(qog_oecd_cs, c("ccodecow")) #TRUE
no_duplicates(qog_oecd_cs, c("ccode")) #TRUE

# clean colnames
names(qog_oecd_cs) <- clean_column_names(names(qog_oecd_cs))

#Make unit column
qog_oecd_cs$u_qog_country_country <- qog_oecd_cs$cname

qog_oecd_cs$u_qog_country_ccodealp <- qog_oecd_cs$ccodealp

qog_oecd_cs$u_qog_country_ccodecow <- qog_oecd_cs$ccodecow

qog_oecd_cs$u_qog_country_ccode <- qog_oecd_cs$ccode

# Check dups in colnames
no_duplicate_names(qog_oecd_cs)

write_dataset(qog_oecd_cs,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets/qog_oecd_cs_cleaned.rds"),
           tag = "qog_oecd_cs",
           overwrite = TRUE)

# Create static files in dta and csv format
write_file(qog_oecd_cs,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_dta/qog_oecd_cs_cleaned.dta"),
           overwrite = TRUE)

write_file(qog_oecd_cs,
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/qog/cleaned_datasets_csv/qog_oecd_cs_cleaned.csv"),
           overwrite = TRUE)