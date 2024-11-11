library(dplyr)
library(demutils)

db <- pg_connect()

qog_std_ts <- read_datasets("qog_std_ts", db)
qog_oecd_ts <- read_datasets("qog_oecd_ts", db)
qog_eqi_cati_long <- read_datasets("qog_eqi_cati_long", db)
qog_ei <- read_datasets("qog_ei", db)

# Create a named list
ds <- list(qog_std_ts = qog_std_ts,
           qog_oecd_ts = qog_oecd_ts, 
           qog_eqi_cati_long = qog_eqi_cati_long, 
           qog_ei = qog_ei)

# Extract classes 
cl_year <- lapply(ds, function(c) class(c$u_qog_country_year_year))
cl_ccode <- lapply(ds, function(c) class(c$u_qog_country_year_ccode))
cl_cowcode <- lapply(ds, function(c) class(c$u_qog_country_year_cowcode))


cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_year, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_year, identical, cl_year[[1]])))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_ccode, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_ccode, identical, cl_ccode[[1]])))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_cowcode, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_cowcode, identical, cl_cowcode[[1]])))

# Create unit table
u_qog_country_year <- 
  bind_rows(select(qog_std_ts, 
                   u_qog_country_year_year, 
                   u_qog_country_year_country,
                   u_qog_country_year_ccode,
                   u_qog_country_year_ccodecow,
                   u_qog_country_year_ccodealp),
            select(qog_oecd_ts, 
                   u_qog_country_year_year, 
                   u_qog_country_year_country,
                   u_qog_country_year_ccode,
                   u_qog_country_year_ccodecow,
                   u_qog_country_year_ccodealp),
            select(qog_eqi_cati_long,
                   u_qog_country_year_year, 
                   u_qog_country_year_country,
                   u_qog_country_year_ccode,
                   u_qog_country_year_ccodecow,
                   u_qog_country_year_ccodealp),
            select(qog_ei,
                   u_qog_country_year_year, 
                   u_qog_country_year_country,
                   u_qog_country_year_ccode,
                   u_qog_country_year_ccodecow,
                   u_qog_country_year_ccodealp)
            ) %>%
  mutate(u_qog_country_year_ccodecow = case_when(
    u_qog_country_year_country == 'Czechia' & u_qog_country_year_country == 2022 ~ 316,
    TRUE ~ u_qog_country_year_ccodecow)) %>%
  filter(!is.na(u_qog_country_year_ccodecow)) %>%
  distinct(.) %>%
  arrange(u_qog_country_year_country, 
          u_qog_country_year_year)

#u_qog_country_year$u_qog_country_year_ccodecow <- as.integer(u_qog_country_year$u_qog_country_year_ccodecow)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_qog_country_year)))

write_unit_table(u_qog_country_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_qog_country_year.rds"),
                 tag = "u_qog_country_year")
