library(dplyr)
library(demutils)

db <- pg_connect()

cses_imd <- read_datasets("cses_imd", db, original = TRUE)


# Clean column names
names(cses_imd) <- clean_column_names(names(cses_imd))

#df <- cses_imd %>% select(starts_with(c("imd5000","imd5008")))

# Identify unit
no_duplicates(cses_imd, c("imd1006_nam", "imd1008_year", "imd1005"))

cses_imd <- remove_idate_class(cses_imd)
v <- check_multiple_classes(cses_imd)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Create unit columns
cses_imd$u_cses_respondent_id <- 
  cses_imd$imd1005

cses_imd$u_cses_respondent_country <- 
  trimws(cses_imd$imd1006_nam)

cses_imd$u_cses_respondent_country_code <- 
  trimws(cses_imd$imd1006_unalpha3)

cses_imd$u_cses_respondent_vdem_country_code <- 
  cses_imd$imd1006_vdem

cses_imd$u_cses_respondent_year <- 
  cses_imd$imd1008_year

cses_imd$u_cses_respondent_cy_code <- 
  cses_imd$imd1004

# Now df has a new column "row_sums" that contains the row sums of the columns that start with "imd1008_mod"
cses_imd %<>%
  mutate(u_cses_respondent_module = case_when(
    imd1008_mod_1 == 1 ~ 1,
    imd1008_mod_2 == 1 ~ 2,
    imd1008_mod_3 == 1 ~ 3,
    imd1008_mod_4 == 1 ~ 4,
    imd1008_mod_5 == 1 ~ 5,
    TRUE ~ -11111
  ))


# Final check for duplicates in column names
# no_duplicate_names(cses_imd)


write_dataset(cses_imd,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/complab/cleaned_datasets/cses_imd_cleaned.rds"),
              tag = "cses_imd",
              overwrite = TRUE)
