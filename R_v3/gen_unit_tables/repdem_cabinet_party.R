library(dplyr)
library(demutils)

db <- pg_connect()

repdem_basic_party <- read_datasets("repdem_basic_party", db) 
repdem_wecee_party <- read_datasets("repdem_wecee_party", db)

# Create a named list
ds <- list(repdem_basic_party = repdem_basic_party,
           repdem_wecee_party = repdem_wecee_party)

# Extract classes 
cl_year <- lapply(ds, function(c) class(c$u_repdem_cabinet_party_year))
cl_paco <- lapply(ds, function(c) class(c$u_repdem_cabinet_party_partycode))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_year, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_year, identical, cl_year[[1]])))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_paco, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_paco, identical, cl_paco[[1]])))

# Bind rows
u_repdem_cabinet_party <- 
  bind_rows(select(repdem_basic_party, 
                   u_repdem_cabinet_party_cab_id,
                   u_repdem_cabinet_party_cab_name, 
                   u_repdem_cabinet_party_partycode,
                   u_repdem_cabinet_party_partystr,
                   u_repdem_cabinet_party_year,
                   u_repdem_cabinet_party_country), 
            select(repdem_wecee_party, 
                   u_repdem_cabinet_party_cab_id,
                   u_repdem_cabinet_party_cab_name, 
                   u_repdem_cabinet_party_partycode,
                   u_repdem_cabinet_party_partystr,
                   u_repdem_cabinet_party_year,
                   u_repdem_cabinet_party_country) 
  )%>%
  distinct(.) %>%
  arrange(u_repdem_cabinet_party_country, u_repdem_cabinet_party_partycode)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_repdem_cabinet_party)))

dups <- duplicates(u_repdem_cabinet_party, c("u_repdem_cabinet_party_cab_id", "u_repdem_cabinet_party_partycode"))
stopifnot("There are duplicates among the identifiers." = nrow(dups) == 0)

write_unit_table(u_repdem_cabinet_party, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_repdem_cabinet_party.rds"),
                 tag = "u_repdem_cabinet_party")
