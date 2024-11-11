library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_nscia <- read_datasets("ucdp_nscia", db, original = TRUE)

#Clean column names 
names(ucdp_nscia) <- clean_column_names(names(ucdp_nscia))

# Duplicate checks
no_duplicates(ucdp_nscia, c("dyad_id", "year"))

# Duplicate columns for unit tables
ucdp_nscia$u_ucdp_dyad_year_dyad_id <- 
  as.character(ucdp_nscia$dyad_id)

ucdp_nscia$u_ucdp_dyad_year_year <- 
  ucdp_nscia$year

# create location column for unit selectors
ucdp_nscia %<>% 
  mutate(u_ucdp_dyad_year_location = case_when(
    gwno_location == 520 ~ "Somalia",
    gwno_location == 452 ~ "Ghana",
    gwno_location == 475 ~ "Nigeria",
    gwno_location == 530 ~ "Ethiopia",
    gwno_location == 490 ~ "DR Congo (Zaire)",
    gwno_location == 625 ~ "Sudan",
    gwno_location == 500 ~ "Uganda",
    gwno_location == 626 ~ "South Sudan",
    gwno_location == 516 ~ "Burundi",
    gwno_location == 483 ~ "Chad",
    gwno_location == 501 ~ "Kenya",
    gwno_location == 437 ~ "Ivory Coast",
    gwno_location == 433 ~ "Senegal",
    gwno_location == 615 ~ "Algeria",
    gwno_location == 471 ~ "Cameroon",
    gwno_location == 581 ~ "Comoros",
    gwno_location == 438 ~ "Guinea",
    gwno_location == 450 ~ "Liberia",
    gwno_location == 432 ~ "Mali",
    gwno_location == 541 ~ "Mozambique",
    gwno_location == 560 ~ "South Africa",
    gwno_location == 461 ~ "Togo",
    gwno_location == 580 ~ "Madagascar (Malagasy)",
    gwno_location == 435 ~ "Mauritania",
    gwno_location == 482 ~ "Central African Republic",
    gwno_location == 451 ~ "Sierra Leone",
    TRUE ~ "-11111"))

# Save 
write_dataset(ucdp_nscia, 
           file.path(Sys.getenv("ROOT_DIR"),
                     "datasets/ucdp/cleaned_datasets/ucdp_nscia_cleaned.rds"),
           tag = "ucdp_nscia",
           overwrite = TRUE)
