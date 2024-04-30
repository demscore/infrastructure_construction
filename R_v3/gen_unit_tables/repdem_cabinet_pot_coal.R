library(dplyr)
library(demutils)

db <- pg_connect()

repdem_basic_potcoal <- read_datasets("repdem_basic_potcoal", db) 
repdem_wecee_potcoal <- read_datasets("repdem_wecee_potcoal", db)

# Create a named list
ds <- list(repdem_basic_potcoal = repdem_basic_potcoal,
           repdem_wecee_potcoal = repdem_wecee_potcoal)

# Extract classes 
cl_cab <- lapply(ds, function(c) class(c$u_repdem_cabinet_pot_coal_cab_id))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_cab, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_cab, identical, cl_cab[[1]])))


# Bind rows
u_repdem_cabinet_pot_coal <- 
  bind_rows(select(repdem_basic_potcoal, 
                   u_repdem_cabinet_pot_coal_cab_id, 
                   u_repdem_cabinet_pot_coal_coalition,
                   u_repdem_cabinet_pot_coal_country), 
            select(repdem_wecee_potcoal, 
                   u_repdem_cabinet_pot_coal_cab_id, 
                   u_repdem_cabinet_pot_coal_coalition,
                   u_repdem_cabinet_pot_coal_country), 
  )%>%
  distinct(.) %>%
  arrange(u_repdem_cabinet_pot_coal_country, u_repdem_cabinet_pot_coal_cab_id)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_repdem_cabinet_pot_coal)))

write_unit_table(u_repdem_cabinet_pot_coal, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_repdem_cabinet_pot_coal.rds"),
                 tag = "u_repdem_cabinet_pot_coal")
