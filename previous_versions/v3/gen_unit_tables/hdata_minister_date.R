library(dplyr)
library(demutils)

db <- pg_connect()

hdata_fomin <- read_datasets("hdata_fomin", db)


# Check for duplicates
no_duplicates(hdata_fomin, c("u_hdata_minister_date_date_in", "u_hdata_minister_date_minister"))

#For this I am using date_in, but date out also uniquely identifies, and so would a combination of date_in and date_out
#so if we want, we could interpolate between those dates for all dates a minister is in office.
#Adding country to the unit table, although it's not necessary.

#bind
u_hdata_minister_date <- 
  bind_rows(select(hdata_fomin, 
                   u_hdata_minister_date_minister, 
                   u_hdata_minister_date_country,
                   u_hdata_minister_date_cowcode,
                   u_hdata_minister_date_date_in,
                   u_hdata_minister_date_date_out,
                   u_hdata_minister_date_year_in,
                   u_hdata_minister_date_year_out,
                   ))%>%
  distinct(.) %>%
  arrange(u_hdata_minister_date_country, u_hdata_minister_date_year_in)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_hdata_minister_date)))

#save
write_unit_table(u_hdata_minister_date, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_hdata_minister_date.rds"), 
                 tag = "u_hdata_minister_date")