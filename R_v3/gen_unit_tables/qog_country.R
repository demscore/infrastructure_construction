library(dplyr)
library(demutils)

db <- pg_connect()

qog_oecd_cs <- read_datasets("qog_oecd_cs", db)
qog_std_cs <- read_datasets("qog_std_cs", db)
qog_exp <- read_datasets("qog_exp", db)

# Create a named list
ds <- list(qog_std_cs = qog_std_cs,
           qog_oecd_cs = qog_oecd_cs, 
           qog_exp = qog_exp)

# Extract classes 
cl_ccode <- lapply(ds, function(c) class(c$u_qog_country_ccode))
cl_cowcode <- lapply(ds, function(c) class(c$u_qog_country_ccodecow))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_ccode, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_ccode, identical, cl_ccode[[1]])))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_cowcode, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_cowcode, identical, cl_cowcode[[1]])))

# Create unit table
u_qog_country <- 
  bind_rows(select(qog_oecd_cs, 
                   u_qog_country_country, 
                   u_qog_country_ccode,
                   u_qog_country_ccodealp,
                   u_qog_country_ccodecow), 
            select(qog_std_cs, 
                   u_qog_country_country,
                   u_qog_country_ccode,
                   u_qog_country_ccodealp,
                   u_qog_country_ccodecow),
            select(qog_exp, 
                   u_qog_country_country,
                   u_qog_country_ccode,
                   u_qog_country_ccodealp,
                   u_qog_country_ccodecow)) %>%
  distinct(.) %>%
  mutate(
    u_qog_country_country = case_when(
      u_qog_country_country == "Bahamas" ~ "Bahamas (the)",
      u_qog_country_country == "Bolivia" ~ "Bolivia (Plurinational State of)",
      u_qog_country_country == "Czech Republic" ~ "Czechia",
      u_qog_country_country == "Cyprus (1975-)" ~ "Cyprus",
      u_qog_country_country == "Ethiopia (1993-)" ~ "Ethiopia",
      u_qog_country_country == "France (1963-)" ~ "France",
      u_qog_country_country == "Korea, South" ~ "Korea (the Republic of)",
      u_qog_country_country == "Malaysia (1966-)" ~ "Malaysia",
      u_qog_country_country == "Moldova" ~ "Moldova (the Republic of)",
      u_qog_country_country == "Netherlands" ~ "Netherlands (the)",
      u_qog_country_country == "Pakistan (1971-)" ~ "Pakistan",
      u_qog_country_country == "Philippines" ~ "Philippines (the)",
      u_qog_country_country == "Russia" ~ "Russian Federation (the)",
      u_qog_country_country == "Sudan (2012)" ~ "Sudan (the)",
      u_qog_country_country == "Syria" ~ "Syrian Arab Republic (the)",
      u_qog_country_country == "Taiwan" ~ "Taiwan (Province of China)",
      u_qog_country_country == "Tanzania" ~ "Tanzania, the Republic of",
      u_qog_country_country == "United Arab Emirates" ~ "United Arab Emirates (the)",
      u_qog_country_country == "United Kingdom" ~ "United Kingdom of Great Britain and Northern Ireland (the)",
      u_qog_country_country == "United States" ~ "United States of America (the)",
      u_qog_country_country == "Venezuela" ~ "Venezuela (Bolivarian Republic of)",
      u_qog_country_country == "Vietnam" ~ "Viet Nam",
      TRUE ~ u_qog_country_country
    )) %>%
  distinct(.) %>%
  arrange(u_qog_country_country)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_qog_country)))

write_unit_table(u_qog_country, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_qog_country.rds"),
           tag = "u_qog_country")
