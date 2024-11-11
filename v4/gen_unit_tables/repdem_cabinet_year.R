library(dplyr)
library(demutils)

db <- pg_connect()

repdem_basic_year <- read_datasets("repdem_basic_year", db) 
repdem_wecee_year <- read_datasets("repdem_wecee_year", db)

# Create a named list
ds <- list(repdem_basic_year = repdem_basic_year,
           repdem_wecee_year = repdem_wecee_year)

# Extract classes 
cl_year <- lapply(ds, function(c) class(c$u_repdem_cabinet_year_year))
cl_cab_id <- lapply(ds, function(c) class(c$u_repdem_cabinet_year_cab_id))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_year, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_year, identical, cl_year[[1]])))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_cab_id, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_cab_id, identical, cl_cab_id[[1]])))

# Bind rows
u_repdem_cabinet_year <- 
  bind_rows(select(repdem_basic_year, 
                   u_repdem_cabinet_year_cab_id,
                   u_repdem_cabinet_year_cab_name, 
                   u_repdem_cabinet_year_year,
                   u_repdem_cabinet_year_country,
                   u_repdem_cabinet_year_unique_id), 
            select(repdem_wecee_year, 
                   u_repdem_cabinet_year_cab_id,
                   u_repdem_cabinet_year_cab_name, 
                   u_repdem_cabinet_year_year,
                   u_repdem_cabinet_year_country,
                   u_repdem_cabinet_year_unique_id), 
  )%>%
  distinct(.) %>%
  arrange(u_repdem_cabinet_year_country, u_repdem_cabinet_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_repdem_cabinet_year)))

dups <- duplicates(u_repdem_cabinet_year, c("u_repdem_cabinet_year_cab_id", "u_repdem_cabinet_year_year"))
stopifnot("There are duplicates among the identifiers." = nrow(dups) == 0)

write_unit_table(u_repdem_cabinet_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_repdem_cabinet_year.rds"),
                 tag = "u_repdem_cabinet_year")
