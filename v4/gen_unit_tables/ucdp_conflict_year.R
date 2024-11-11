library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_term_conflict <- read_datasets("ucdp_term_conflict", db)
ucdp_nonstate <- read_datasets("ucdp_nonstate", db)
ucdp_prio_acd <- read_datasets("ucdp_prio_acd", db)
ucdp_brd_conflict <- read_datasets("ucdp_brd_conflict", db)

# Check if similar columns are of the same class across datasets.
# If there are differences, they need to be adjusted in the cleaning scripts.

# Create a named list
ds <- list(ucdp_term_conflict = ucdp_term_conflict,
           ucdp_nonstate = ucdp_nonstate, 
           ucdp_prio_acd = ucdp_prio_acd, 
           ucdp_brd_conflict = ucdp_brd_conflict)

# Extract classes 
cl_year <- lapply(ds, function(c) class(c$u_ucdp_conflict_year_year))
cl_conflict_id <- lapply(ds, function(c) class(c$u_ucdp_conflict_year_conflict_id))


cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_year, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_year, identical, cl_year[[1]])))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_conflict_id, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_conflict_id, identical, cl_conflict_id[[1]])))



# Create unit table
u_ucdp_conflict_year <- 
  bind_rows(select(ucdp_term_conflict, 
                   u_ucdp_conflict_year_conflict_id, 
                   u_ucdp_conflict_year_year,
                   u_ucdp_conflict_year_location), 
            select(ucdp_nonstate, 
                   u_ucdp_conflict_year_conflict_id, 
                   u_ucdp_conflict_year_year,
                   u_ucdp_conflict_year_location),
            select(ucdp_brd_conflict, 
                   u_ucdp_conflict_year_conflict_id, 
                   u_ucdp_conflict_year_year,
                   u_ucdp_conflict_year_location),
            select(ucdp_prio_acd, 
                   u_ucdp_conflict_year_conflict_id, 
                   u_ucdp_conflict_year_year,
                   u_ucdp_conflict_year_location)) %>% 
  mutate(u_ucdp_conflict_year_location = case_when(
    u_ucdp_conflict_year_conflict_id == 218 ~ "India, Pakistan", 
    u_ucdp_conflict_year_conflict_id == 274 ~ "China, India",
    u_ucdp_conflict_year_conflict_id == 294 ~ "Cambodia (Kampuchea), Thailand",
    u_ucdp_conflict_year_conflict_id == 368 ~ "Panama, United States of America",
    u_ucdp_conflict_year_conflict_id == 371 ~ "Iraq, Kuwait",
    u_ucdp_conflict_year_conflict_id == 403 ~ "Ecuador, Peru",
    u_ucdp_conflict_year_conflict_id == 405 ~ "Cameroon, Nigeria",
    u_ucdp_conflict_year_conflict_id == 435 ~ "Djibouti, Eritrea",
    u_ucdp_conflict_year_conflict_id == 420 ~ "Australia, Iraq, United Kingdom, United States of America",
    u_ucdp_conflict_year_conflict_id == 13324 ~ "Kyrgyzstan, Tajikistan",
    u_ucdp_conflict_year_conflict_id == 13692 ~ "Afghanistan, United Kingdom, United States of America",
    TRUE ~ u_ucdp_conflict_year_location
  )) %>%
  distinct(.) %>% 
  arrange(u_ucdp_conflict_year_conflict_id, 
          u_ucdp_conflict_year_year)

stopifnot("There are duplicates in the identifier columns." =
            !any(duplicated(u_ucdp_conflict_year[, c("u_ucdp_conflict_year_conflict_id", 
                                                     "u_ucdp_conflict_year_year")])))

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_conflict_year)))

write_unit_table(u_ucdp_conflict_year, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_conflict_year.rds"),
           tag = "u_ucdp_conflict_year")

