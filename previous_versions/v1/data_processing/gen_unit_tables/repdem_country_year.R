library(dplyr)
library(demutils)

db <- pg_connect()

u_repdem_country_year <- read_file(file.path(Sys.getenv("ROOT_DIR"), "datasets", "repdem", "repdem_country_years.rds"))

stopifnot("There are missing values in the unit columns." = !any(is.na(u_repdem_country_year)))

#save
write_unit_table(u_repdem_country_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_repdem_country_year.rds"), 
                 tag = "u_repdem_country_year")