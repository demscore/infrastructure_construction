library(dplyr)
library(demutils)

db <- pg_connect()

vdem_cy <- read_datasets("vdem_cy", db)
vdem_ert <- read_datasets("vdem_ert", db)

# Create a named list
ds <- list(vdem_cy = vdem_cy,
           vdem_ert = vdem_ert)

# Extract classes 
cl_year <- lapply(ds, function(c) class(c$u_vdem_country_year_year))
cl_country_id <- lapply(ds, function(c) class(c$u_vdem_country_year_country_id))
cl_cowcode <- lapply(ds, function(c) class(c$u_vdem_country_year_cowcode))


cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_year, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_year, identical, cl_year[[1]])))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_country_id, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_country_id, identical, cl_country_id[[1]])))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_cowcode, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_cowcode, identical, cl_cowcode[[1]])))

# Create unit table
u_vdem_country_year <- 
  bind_rows(select(vdem_cy, 
                   u_vdem_country_year_country,
                   u_vdem_country_year_country_text_id,
                   u_vdem_country_year_country_id,
                   u_vdem_country_year_cowcode,
                   u_vdem_country_year_year), 
            select(vdem_ert, 
                   u_vdem_country_year_country,
                   u_vdem_country_year_country_text_id,
                   u_vdem_country_year_country_id,
                   u_vdem_country_year_cowcode,
                   u_vdem_country_year_year)) %>%
  mutate(u_vdem_country_year_country = case_when(
    u_vdem_country_year_country == "Czech Republic" ~ "Czechia", 
    TRUE ~ u_vdem_country_year_country
  )) %>%
  distinct(.) %>% 
  arrange(u_vdem_country_year_country, 
          u_vdem_country_year_year)

dups <- duplicates(u_vdem_country_year, c('u_vdem_country_year_country', 'u_vdem_country_year_year'))

stopifnot("There are missing values in the unit columns." = !any(is.na(u_vdem_country_year)))

write_unit_table(u_vdem_country_year, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_vdem_country_year.rds"), 
           tag = "u_vdem_country_year")
