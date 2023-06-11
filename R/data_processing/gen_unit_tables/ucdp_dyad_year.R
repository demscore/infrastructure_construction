library(dplyr)
library(demutils)

db <- pg_connect()


#Read datasets
ucdp_dyadic <- read_datasets("ucdp_dyadic", db)
ucdp_brd_dyadic <- read_datasets("ucdp_brd_dyadic", db)
ucdp_nscia <- read_datasets("ucdp_nscia", db) 
ucdp_extsupp <- read_datasets("ucdp_extsupp", db) 
ucdp_term_dyadic <- read_datasets("ucdp_term_dyadic", db)
ucdp_onesided <- read_datasets("ucdp_onesided", db)
ucdp_vpp <- read_datasets("ucdp_vpp", db)
ucdp_esd_dy <- read_datasets("ucdp_esd_dy", db)


#Bind rows
u_ucdp_dyad_year <- 
  bind_rows(select(ucdp_dyadic, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year),
            select(ucdp_brd_dyadic, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year),
            select(ucdp_nscia, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year),
            select(ucdp_extsupp, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year),
            select(ucdp_term_dyadic, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year),
            select(ucdp_onesided, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year),
            select(ucdp_vpp, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year),
            select(ucdp_esd_dy, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year))%>%
  distinct(.) %>% 
  arrange(u_ucdp_dyad_year_dyad_id, u_ucdp_dyad_year_year)



is.na(u_ucdp_dyad_year)

colSums(is.na(u_ucdp_dyad_year))

which(colSums(is.na(u_ucdp_dyad_year)) > 0)

names(which(colSums(is.na(u_ucdp_dyad_year)) > 0))

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_dyad_year)))


# Save df
write_unit_table(u_ucdp_dyad_year, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_dyad_year.rds"),
           tag = "u_ucdp_dyad_year")

