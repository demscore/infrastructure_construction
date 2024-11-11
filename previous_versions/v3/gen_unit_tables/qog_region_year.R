library(dplyr)
library(demutils)

db <- pg_connect()

qog_eqi_long <- read_datasets("qog_eqi_long", db)
qog_eureg_long <- read_datasets("qog_eureg_long", db)
qog_eureg_wide1 <- read_datasets("qog_eureg_wide1", db)
qog_eureg_wide2 <- read_datasets("qog_eureg_wide2", db)

# Create a named list
ds <- list(qog_eqi_long = qog_eqi_long,
           qog_eureg_long = qog_eureg_long, 
           qog_eureg_wide1 = qog_eureg_wide1, 
           qog_eureg_wide2 = qog_eureg_wide2)

# Extract classes 
cl_year <- lapply(ds, function(c) class(c$u_qog_region_year_year))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_year, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_year, identical, cl_year[[1]])))

# Create unit table
u_qog_region_year <- 
  bind_rows(select(qog_eqi_long, 
                   u_qog_region_year_region, 
                   u_qog_region_year_year, 
                   u_qog_region_year_region_name), 
            select(qog_eureg_long, 
                   u_qog_region_year_region, 
                   u_qog_region_year_year, 
                   u_qog_region_year_region_name),
            select(qog_eureg_wide1, 
                   u_qog_region_year_region, 
                   u_qog_region_year_year, 
                   u_qog_region_year_region_name),
            select(qog_eureg_wide2, 
                   u_qog_region_year_region, 
                   u_qog_region_year_year, 
                   u_qog_region_year_region_name)) %>%
  mutate(u_qog_region_year_region_name = case_when(
    u_qog_region_year_region_name == "Burgenland (AT)" ~ "Burgenland",
    u_qog_region_year_region_name == "Burgenland (At)" ~ "Burgenland",
    TRUE ~ u_qog_region_year_region_name
  )) %>%
  distinct(.) %>% 
  arrange(u_qog_region_year_region, 
          u_qog_region_year_year)


# Convert all caps country names
#temp <- u_qog_region_year %>% 
#  filter(nchar(u_qog_region_year_region) == 2) 

# Make sure to only convert regions at country level
#countries <- c(temp$u_qog_region_year_region_name)
#temp$u_qog_region_year_region_name <- stringr::str_to_title(countries) 

# bind back converted country unit observations
#u_qog_region_year %<>%
#  filter(!nchar(u_qog_region_year_region) == 2) %>%
#  rbind(temp) %>%
#  distinct(.)
  
stopifnot("There are missing values in the unit columns." = !any(is.na(u_qog_region_year)))

write_unit_table(u_qog_region_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_qog_region_year.rds"),
                 tag = "u_qog_region_year")
