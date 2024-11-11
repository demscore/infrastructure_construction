library(dplyr)
library(demutils)

db <- pg_connect()

# Load tables
variables <- 
  DBI::dbGetQuery(db, "SELECT variable_id, tag_long, name, dataset_id, 
                       cb_section, graphable,codebook_id 
                       FROM variables WHERE active IS TRUE AND head_var IS NULL;") %>%
  filter(!grepl("identifiers|identifier_variables|id", cb_section)) %>%
  select(-cb_section)

thematic_datasets_variables <- 
  DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets_variables;")

codebook <- DBI::dbGetQuery(db, "SELECT * FROM codebook;")


# Combine thematic dataset IDs into a single column
thematic_combined <- thematic_datasets_variables %>%
  group_by(tag_long) %>%
  summarise(theme = paste(unique(thematic_dataset_id), 
                          collapse = ","))

# Join with variables
out <- left_join(variables, thematic_combined, by = "tag_long") %>%
  left_join(., codebook, by = c("codebook_id")) %>%
  select(variable_id, dataset_id, codebook_id, tag, tag_long,
         name, cb_entry, graphable, theme) %>%
  arrange(dataset_id, theme, tag)

write_file(out, file.path(Sys.getenv("ROOT_DIR"), "checks", "4.0", "variables",
                          "themes.csv"), overwrite = F)


