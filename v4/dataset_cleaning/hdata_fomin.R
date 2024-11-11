library(dplyr)
library(demutils)
library(lubridate)

db <- pg_connect()

hdata_fomin <- read_datasets("hdata_fomin", db, original = TRUE)

# Check for and remove multiple classes
hdata_fomin <- remove_idate_class(hdata_fomin)
v <- check_multiple_classes(hdata_fomin)
stopifnot("Some variables have multiple classes." = length(v) <= 0)

# Clean column names
names(hdata_fomin) <- clean_column_names(names(hdata_fomin))

# Create unit columns
hdata_fomin$u_hdata_minister_date_minister <- 
  hdata_fomin$foreignminister

hdata_fomin$u_hdata_minister_date_country <- 
  hdata_fomin$country_name

hdata_fomin$u_hdata_minister_date_cowcode <- 
  as.numeric(hdata_fomin$ccode)

hdata_fomin$u_hdata_minister_date_cowcode[is.na(hdata_fomin$u_hdata_minister_date_cowcode)] <- 
  as.numeric(-11111)

# The unit table includes country-years from both H-DATA datasets, despite the H-DATA
# Foreign Minister Dataset not having country-year as a primary unit. Since the name for the United Sates 
# differs across the two datasets, we adjust it. 
hdata_fomin %<>% mutate(u_hdata_minister_date_country = case_when(
  country_name == "United States of America" ~ "United States", 
  TRUE ~ u_hdata_minister_date_country
))


# Create unit columns for in and out date

# Fix NAs in date columns with helper columns that are removed later.
# Pattern for missing is 7777 if unknown (looked but not found)
# 8888 if unknown according to existing research, 6666 if still in office

hdata_fomin <- hdata_fomin %>%
  mutate(fminday_cl = case_when(
         fminday == 7777 ~ 01,
         TRUE ~ as.numeric(fminday)))

hdata_fomin <- hdata_fomin %>%
  mutate(fminmonth_cl = case_when(
    fminmonth == 7777 ~ 01,
    TRUE ~ as.numeric(fminmonth)))

# If FM was still in office at time of data collection, date_out is set to 01-06-2017
hdata_fomin <- hdata_fomin %>%
  mutate(fmoutday_cl = case_when(
    fmoutday == 7777 ~ 01,
    fmoutday == 6666 ~ 01,
    TRUE ~ as.numeric(fmoutday)))

hdata_fomin <- hdata_fomin %>%
  mutate(fmoutmonth_cl = case_when(
    fmoutmonth == 7777 ~ 01,
    fmoutmonth == 6666 ~ 06,
    TRUE ~ as.numeric(fmoutmonth)))

hdata_fomin <- hdata_fomin %>%
  mutate(fmoutyear_cl = case_when(
    fmoutyear == 6666 ~ 2017,
    TRUE ~ as.numeric(fmoutyear)))


# Create unit date cols based on date helper columns (suffix _cl)
hdata_fomin$u_hdata_minister_date_date_in <- 
         as.Date(dmy(paste(hdata_fomin$fminday_cl, 
                           hdata_fomin$fminmonth_cl, 
                           hdata_fomin$fminyear, sep = "-")))

hdata_fomin$u_hdata_minister_date_date_out <-  
         as.Date(dmy(paste(hdata_fomin$fmoutday_cl, 
                           hdata_fomin$fmoutmonth_cl, 
                           hdata_fomin$fmoutyear_cl, sep = "-")))


hdata_fomin$u_hdata_minister_date_year_in <- 
  hdata_fomin$fminyear

hdata_fomin$u_hdata_minister_date_year_out <- 
  hdata_fomin$fmoutyear_cl

# Remove date helper columns
hdata_fomin <- hdata_fomin %>%
  select(-fminday_cl, -fminmonth_cl, -fmoutday_cl, -fmoutmonth_cl, -fmoutyear_cl)

# Duplicates check to identify units
no_duplicates(hdata_fomin, c("foreignminister", "u_hdata_minister_date_date_in")) #TRUE

# Final duplicates check column names
no_duplicate_names(hdata_fomin)


write_dataset(hdata_fomin, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/hdata/cleaned_datasets/hdata_fomin_cleaned.rds"),
              tag= "hdata_fomin",
              overwrite = TRUE)