library(dplyr)
library(demutils)

db <- pg_connect()

# Define the directory path
UNITS_DIR <- file.path(Sys.getenv("ROOT_DIR"), "unit_data")
units <- DBI::dbGetQuery(db, "SELECT unit_tag, unit_id FROM units WHERE active IS TRUE;")
variables <- DBI::dbGetQuery(db, "SELECT tag_long, variable_id FROM variables WHERE active IS TRUE;")

unit_names <- list.files(UNITS_DIR)

print(unit_names)

file_list <- list()

# Loop over each unit directory
for (u in unit_names) {

  # For testing purposes, only process one unit
  # u = "u_complab_country_year"

  # Define the path to the unit directory
  unit_path <- file.path(UNITS_DIR, u)
  
  # List all files in the unit directory with .rds extension
  files <- list.files(unit_path, pattern = "\\.rds$", full.names = FALSE)

    # Print the unit path to debug
  cat("Checking directory:", unit_path, "\n")
  
  # Print debug information
  # cat("Unit:", u, "\n")
  # cat("Files:", files, "\n")
  
  file_names <- gsub("\\.rds$", "", files)
  
  df <- data.frame(unit_tag = rep(u, length(file_names)), 
                   file_name = file_names, 
                   stringsAsFactors = FALSE)

  file_list <- append(file_list, list(df))
}

result_df <- bind_rows(file_list)
rs <- result_df %>% filter(is.na(unit_tag))


# Merge in ids
final_df <- result_df %>%
  left_join(units, by = c("unit_tag")) %>%
  left_join(variables, by = c("file_name" = "tag_long")) %>%
  select(unit_id, variable_id) %>%
  filter(!is.na(variable_id)) %>%
  filter(!is.na(unit_id))

pg_send_query(db, "TRUNCATE TABLE variable_unit_combinations;")

pg_append_table(final_df, "variable_unit_combinations", db)

prepare_autogen()

