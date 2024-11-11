library(dplyr)
library(demutils)

db <- pg_connect()

variables <- DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;")

gender_vars <- variables %>%
  select(tag_long, cb_section) %>%
  filter(grepl("gender", cb_section))

df <- data.frame(
  id = 1:nrow(gender_vars),
  thematic_dataset_id = 1,
  tag_long = gender_vars$tag_long
)

#pg_append_table(df, "thematic_datasets_variables", db)         


mig_vars <- variables %>%
  select(tag_long, cb_section) %>%
  filter(grepl("migration", cb_section))

df <- data.frame(
  id = 62:130,
  thematic_dataset_id = 2,
  tag_long = mig_vars$tag_long
)

#pg_append_table(df, "thematic_datasets_variables", db) 


corr_vars <- variables %>%
  select(tag_long, cb_section) %>%
  filter(grepl("corruption", cb_section))

df <- data.frame(
  id = 131:166,
  thematic_dataset_id = 3,
  tag_long = corr_vars$tag_long
)

#pg_append_table(df, "thematic_datasets_variables", db) 
