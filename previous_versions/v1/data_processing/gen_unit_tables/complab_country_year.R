library(dplyr)
library(demutils)

db <- pg_connect()

complab_spin_cbd <- read_datasets("complab_spin_cbd", db)
complab_spin_outwb <- read_datasets("complab_spin_outwb", db)
complab_spin_plb <- read_datasets("complab_spin_plb", db)
complab_spin_samip <- read_datasets("complab_spin_samip", db)
complab_spin_scip <- read_datasets("complab_spin_scip", db)
complab_spin_sied <- read_datasets("complab_spin_sied", db)
complab_spin_ssfd <- read_datasets("complab_spin_ssfd", db)
complab_spin_hben <- read_datasets("complab_spin_hben", db)
complab_grace <- read_datasets("complab_grace", db)

# The SAMIP data has two entries for Italy and for Norway which adds a extra 0 at the 
# end of the country number OR _adjusted to the country_fname. Both options available in the 
# SAMIP cleaning script.
# For now we remove country_nr from the unit table and create the unit data with the unadjusted 
# country numbers. If the adjusted country number is to be used, an additional coulmn needs
# to be created in all complab cleaning scripts and added to the unit table script. 


# Create unit table by binding unit columns from datasets which have u_complab_country_year
# as a primary output unit.
u_complab_country_year <- 
  bind_rows(select(complab_spin_cbd, 
                   u_complab_country_year_country,
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code,
                   u_complab_country_year_country_nr), 
            select(complab_spin_plb, 
                   u_complab_country_year_country,
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code,
                   u_complab_country_year_country_nr),
            select(complab_spin_samip, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code,
                   u_complab_country_year_country_nr),
            select(complab_spin_sied, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code,
                   u_complab_country_year_country_nr),
            select(complab_spin_ssfd, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code,
                   u_complab_country_year_country_nr),
            select(complab_spin_scip, 
                   u_complab_country_year_country,
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code,
                   u_complab_country_year_country_nr),
            select(complab_spin_outwb, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code,
                   u_complab_country_year_country_nr),
            select(complab_spin_hben, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code,
                   u_complab_country_year_country_nr),
            select(complab_grace, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code,
                   u_complab_country_year_country_nr)
            )%>%
  mutate(u_complab_country_year_country = case_when(
    u_complab_country_year_country == "Slovak Republic" ~ "Slovakia",
    u_complab_country_year_country == "Korea, Rep." ~ "South Korea",
    TRUE ~ u_complab_country_year_country
  )) %>%
  mutate(u_complab_country_year_country_code = case_when(
    u_complab_country_year_country_code == "Slovak Republic" ~ "SVK",
    TRUE ~ u_complab_country_year_country_code
  )) %>%
  distinct(.) %>%
  arrange(u_complab_country_year_country, u_complab_country_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_complab_country_year)))

write_unit_table(u_complab_country_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_complab_country_year.rds"),
                 tag = "u_complab_country_year")