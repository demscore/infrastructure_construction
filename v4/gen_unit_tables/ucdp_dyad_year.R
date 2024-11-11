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
ucdp_cid_dy <- read_datasets("ucdp_cid_dy", db)

# Create a named list
ds <- list(ucdp_dyadic = ucdp_dyadic,
           ucdp_brd_dyadic = ucdp_brd_dyadic, 
           ucdp_nscia = ucdp_nscia, 
           ucdp_extsupp = ucdp_extsupp,
           ucdp_term_dyadic = ucdp_term_dyadic,
           ucdp_onesided = ucdp_onesided,
           ucdp_vpp = ucdp_vpp,
           ucdp_esd_dy = ucdp_esd_dy,
           ucdp_cid_dy = ucdp_cid_dy)

# Extract classes 
cl_year <- lapply(ds, function(c) class(c$u_ucdp_dyad_year_year))
cl_dyad_id <- lapply(ds, function(c) class(c$u_ucdp_dyad_year_dyad_id))


cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_year, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_year, identical, cl_year[[1]])))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_dyad_id, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_dyad_id, identical, cl_dyad_id[[1]])))

#Bind rows
u_ucdp_dyad_year <- 
  bind_rows(select(ucdp_dyadic, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year,
                   u_ucdp_dyad_year_location),
            select(ucdp_brd_dyadic, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year,
                   u_ucdp_dyad_year_location),
            select(ucdp_nscia, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year,
                   u_ucdp_dyad_year_location),
            select(ucdp_extsupp, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year,
                   u_ucdp_dyad_year_location),
            select(ucdp_term_dyadic, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year,
                   u_ucdp_dyad_year_location),
            select(ucdp_onesided, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year,
                   u_ucdp_dyad_year_location),
            select(ucdp_vpp, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year,
                   u_ucdp_dyad_year_location),
            select(ucdp_esd_dy, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year,
                   u_ucdp_dyad_year_location),
            select(ucdp_cid_dy, 
                   u_ucdp_dyad_year_dyad_id, 
                   u_ucdp_dyad_year_year,
                   u_ucdp_dyad_year_location))

# Remove spaces at end of side_a and side_b names

u_ucdp_dyad_year$u_ucdp_dyad_year_location <- 
  gsub(" $", "", u_ucdp_dyad_year$u_ucdp_dyad_year_location)

u_ucdp_dyad_year$u_ucdp_dyad_year_location <- 
  gsub("^ ", "", u_ucdp_dyad_year$u_ucdp_dyad_year_location)

# Some names for locations, side_a and side_b need to be adjusted as they slightly vary across
# datasets. This adjeustments do not affect the merges to this unit and are only
# relevant for the selective download options for the dyad-year unit

u_ucdp_dyad_year %<>%
  mutate(u_ucdp_dyad_year_location = case_when(
    u_ucdp_dyad_year_dyad_id == 11199 ~ "Afghanistan, United Kingdom, United States of America",
    u_ucdp_dyad_year_dyad_id == 11989 ~ "South Sudan, Sudan",
    u_ucdp_dyad_year_dyad_id == 14619 ~ "Russia (Soviet Union)",
    u_ucdp_dyad_year_dyad_id == 406 ~ "Iran",
    u_ucdp_dyad_year_dyad_id == 428 ~ "Myanmar (Burma)",
    u_ucdp_dyad_year_dyad_id == 453 ~ "India",
    u_ucdp_dyad_year_dyad_id == 560 ~ "Ethiopia, Somalia",
    u_ucdp_dyad_year_dyad_id == 633 ~ "South Vietnam, Vietnam (North Vietnam)",
    u_ucdp_dyad_year_dyad_id == 634 ~ "Cambodia (Kampuchea), Thailand",
    u_ucdp_dyad_year_dyad_id == 674 ~ "Sri Lanka",
    u_ucdp_dyad_year_dyad_id == 703 ~ "South Yemen, Yemen (North Yemen)",
    u_ucdp_dyad_year_dyad_id == 707 ~ "Iran, Iraq",
    u_ucdp_dyad_year_dyad_id == 715 ~ "Cambodia (Kampuchea), Vietnam (North Vietnam)",
    u_ucdp_dyad_year_dyad_id == 737 ~ "China, Vietnam (North Vietnam)",
    u_ucdp_dyad_year_dyad_id == 767 ~ "Argentina, United Kingdom",
    u_ucdp_dyad_year_dyad_id == 773 ~ "Chad, Nigeria",
    u_ucdp_dyad_year_dyad_id == 774 ~ "Grenada, United States of America",
    u_ucdp_dyad_year_dyad_id == 776 ~ "Sri Lanka",
    u_ucdp_dyad_year_dyad_id == 777 ~ "Sri Lanka",
    u_ucdp_dyad_year_dyad_id == 778 ~ "Sri Lanka",
    u_ucdp_dyad_year_dyad_id == 782 ~ "Burkina Faso, Mali",
    u_ucdp_dyad_year_dyad_id == 783 ~ "Laos, Thailand",
    u_ucdp_dyad_year_dyad_id == 788 ~ "Chad, Libya",
    u_ucdp_dyad_year_dyad_id == 796 ~ "Panama, United States of America",
    u_ucdp_dyad_year_dyad_id == 799 ~ "Iraq, Kuwait",
    u_ucdp_dyad_year_dyad_id == 854 ~ "Ecuador, Peru",
    u_ucdp_dyad_year_dyad_id == 858 ~ "Cameroon, Nigeria",
    u_ucdp_dyad_year_dyad_id == 865 ~ "Eritrea, Ethiopia",
    u_ucdp_dyad_year_dyad_id == 877 ~ "North Macedonia",
    u_ucdp_dyad_year_dyad_id == 883 ~ "Australia, Iraq, United Kingdom, United States of America",
    u_ucdp_dyad_year_dyad_id == 892 ~ "Tanzania, Uganda",
    u_ucdp_dyad_year_dyad_id == 898 ~ "Afghanistan, Russia (Soviet Union)",
    u_ucdp_dyad_year_dyad_id == 902 ~ "Turkey",
    u_ucdp_dyad_year_year == 1000 ~ "no location specified in the original dataset",
    TRUE ~ u_ucdp_dyad_year_location
  )) %>% 
  distinct(.) %>% 
  arrange(u_ucdp_dyad_year_dyad_id, u_ucdp_dyad_year_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_dyad_year)))

#write_file(u_ucdp_dyad_year, file.path(Sys.getenv("ROOT_DIR"), "refs", "ucdp", "dy_identifiers.csv"))

dups <- duplicates(u_ucdp_dyad_year, c("u_ucdp_dyad_year_dyad_id", "u_ucdp_dyad_year_year"), keep_all = TRUE) 

# Adjust duplicates
df <- anti_join(u_ucdp_dyad_year, dups)

df %<>%
  filter(u_ucdp_dyad_year_location != "no location specified in original dataset")

u_ucdp_dyad_year <- rbind(u_ucdp_dyad_year, df) %>%
  distinct(u_ucdp_dyad_year_year, u_ucdp_dyad_year_dyad_id, .keep_all = TRUE) %>% 
  mutate(u_ucdp_dyad_year_location = case_when(
    u_ucdp_dyad_year_year == 1000 ~ "no location specified in the original dataset",
                                               TRUE ~ u_ucdp_dyad_year_location)) %>% 
  arrange(u_ucdp_dyad_year_dyad_id, u_ucdp_dyad_year_year)

dups <- duplicates(u_ucdp_dyad_year, c("u_ucdp_dyad_year_dyad_id", "u_ucdp_dyad_year_year"), keep_all = TRUE) 

stopifnot("There are duplicates among the identifiers." = nrow(dups) == 0)

# Save df
write_unit_table(u_ucdp_dyad_year, 
           file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_dyad_year.rds"),
           tag = "u_ucdp_dyad_year")

