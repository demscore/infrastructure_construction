library(dplyr)
library(demutils)

db <- pg_connect()

repdem_basic <- read_datasets("repdem_basic", db) 
repdem_wecee <- read_datasets("repdem_wecee", db)

# Create a named list
ds <- list(repdem_basic = repdem_basic,
           repdem_wecee = repdem_wecee)

# Extract classes 
cl_date_in <- lapply(ds, function(c) class(c$u_repdem_cabinet_date_date_in))
cl_date_out <- lapply(ds, function(c) class(c$u_repdem_cabinet_date_date_out))
cl_in_year <- lapply(ds, function(c) class(c$u_repdem_cabinet_date_in_year))
cl_out_year <- lapply(ds, function(c) class(c$u_repdem_cabinet_date_out_year))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_date_in, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_date_in, identical, cl_date_in[[1]])))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_date_out, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_date_out, identical, cl_date_out[[1]])))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_in_year, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_in_year, identical, cl_in_year[[1]])))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_out_year, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_out_year, identical, cl_out_year[[1]])))


# Bind rows
u_repdem_cabinet_date <-
  bind_rows(select(repdem_basic,
                   u_repdem_cabinet_date_cab_name,
                   u_repdem_cabinet_date_date_in,
                   u_repdem_cabinet_date_date_out,
                   u_repdem_cabinet_date_country,
                   u_repdem_cabinet_date_in_year,
                   u_repdem_cabinet_date_out_year),
            select(repdem_wecee,
                   u_repdem_cabinet_date_cab_name,
                   u_repdem_cabinet_date_date_in,
                   u_repdem_cabinet_date_date_out,
                   u_repdem_cabinet_date_country,
                   u_repdem_cabinet_date_in_year,
                   u_repdem_cabinet_date_out_year)
  )%>%
  distinct(.) %>%
  arrange(u_repdem_cabinet_date_country, u_repdem_cabinet_date_in_year) %>%
  filter(!is.na(u_repdem_cabinet_date_date_in))

stopifnot("There are missing values in the unit columns." = !any(is.na(u_repdem_cabinet_date)))

write_unit_table(u_repdem_cabinet_date, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_repdem_cabinet_date.rds"),
           tag = "u_repdem_cabinet_date")