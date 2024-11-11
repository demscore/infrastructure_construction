library(dplyr)
library(demutils)

db <- pg_connect()

# Load tables
datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets WHERE demscore_release ~ '4.0';")
variables <- DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;")
units <- DBI::dbGetQuery(db, "SELECT unit_tag, unit_id FROM units WHERE active IS TRUE;")

# Count variables per dataset
vars <- variables %>% filter(new_variable == FALSE) %>%
  group_by(dataset_id) %>%
  count()

ds <- datasets %>% select(dataset_id, tag, name, default_unit, year_coverage) %>%
  left_join(., vars, by = c("dataset_id")) %>%
  left_join(., units, by = c("default_unit" = "unit_tag")) %>%
  mutate(analytical_level = case_when(
    unit_id %in% c(2, 3) ~ "Swedish Agencies",
    unit_id %in% c(1, 8, 23, 34, 44, 101, 87, 32, 7) ~ "Countries",
    unit_id %in% c(57, 58) ~ "European Regions",
    unit_id %in% c(4, 5, 6, 38) ~ "Individual Respondents",
    unit_id %in% c(33, 36) ~ "Country Expert Coders",
    unit_id %in% c(13, 111, 112, 113, 114, 115, 116, 117) ~ "Cabinets",
    unit_id %in% c(59) ~ "Political Parties",
    unit_id %in% c(81) ~ "PRIO-GRID Cells",
    unit_id %in% c(26) ~ "Conflict Dyads",
    unit_id %in% c(19) ~ "Violent Conflicts",
    unit_id %in% c(45) ~ "Foreign Ministers",
    unit_id %in% c(119) ~ "Changes in Migration Policies",
    unit_id %in% c(120) ~ "Migration Tracks",
    unit_id %in% c(39) ~ "Violent Events",
    unit_id %in% c(15) ~ "Actors in Violent Conflict",
    unit_id %in% c(49, 52) ~ "External Support in Violent Conflict",
    unit_id %in% c(118) ~ "Historical Wars",
    unit_id %in% c(100) ~ "Country Dyads",
    unit_id %in% c(123) ~ "Conflict Issues",
    unit_id %in% c(9) ~ "Municipalities",
    unit_id %in% c(9) ~ "Municipalities",
    unit_id %in% c(48) ~ "Intrastate Conflicts",
    unit_id %in% c(18) ~ "Peace Agreements",
    TRUE ~ "other"
  )) %>%
  select(-default_unit, -unit_id) %>%
  rename(n_variables = n)




# Count rows per dataset
tags <- datasets$tag

# Initialize an empty list to store the results
ll <- list()

for (i in seq_along(tags)) {
  
  df <- read_datasets(tags[i], db)
  
  n_rows <- nrow(df)
  
  # Create a data frame with the current dataset's information
  current_result <- data.frame(dataset_id = tags[i], tag = tags[i], n_row = n_rows)
  
  # Store the current result in the list
  ll[[i]] <- current_result
  
}

# Combine the list elements into a data frame
results <- do.call(rbind, ll)
results %<>% rename(rows_total = n_row) %>% select(-dataset_id)

merge <- left_join(ds, results, by = c("tag")) %>%
  select(name, year_coverage, analytical_level, n_variables, rows_total) %>%
  arrange(name) %>%
  filter(!grepl("^CSES", name)) %>%
  mutate(name = case_when(
    name = grepl("^VIEWS Country", name) & n_variables == 10 ~ "VIEWS Country-Month Conflict Predictions (Input Data: April 2023 - July 2024)",
    name = grepl("^VIEWS PRIO", name) & n_variables == 5 ~ "VIEWS PRIO-GRID-Month Conflict Predictions (Input Data: April 2023 - July 2024)",
    name = grepl("^VIEWS Country", name) & n_variables == 9 ~ "VIEWS Country-Month Conflict Predictions (Input Data: January 2022 - March 2023)",
    name = grepl("^VIEWS PRIO", name) & n_variables == 4 ~ "VIEWS PRIO-GRID-Month Conflict Predictions (Input Data: January 2022 - March 2023)",
    TRUE ~ name
  )) %>%
  distinct(name, .keep_all = TRUE)

write_file(merge, file.path(Sys.getenv("ROOT_DIR"), "handbook", "dataset_overview.csv"),
           overwrite = TRUE)
