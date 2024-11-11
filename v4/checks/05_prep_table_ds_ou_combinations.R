#!/usr/bin/env Rscript

# Download reference tables, alternatively create database tables!

suppressMessages(library(dbplyr))
suppressMessages(library(dplyr))
suppressMessages(library(magrittr))
suppressMessages(library(vutils))

db <- pg_connect(Sys.getenv("DEFAULT_DB"))
ROOT_DIR <- Sys.getenv("ROOT_DIR")


projects <- DBI::dbGetQuery(db, "SELECT * FROM projects WHERE active IS TRUE;")
datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;") %>%
  filter(grepl(Sys.getenv("DEMSCORE_RELEASE"), demscore_release))
variables <- DBI::dbGetQuery(db, "SELECT * FROM variables;") %>%
  filter(cb_show)
units <- DBI::dbGetQuery(db, "SELECT * FROM units;") %>%
  filter(active)
methodology <- DBI::dbGetQuery(db, "SELECT * FROM methodology;") %>%
  filter(show)
cb_section <- DBI::dbGetQuery(db, "SELECT * FROM cb_section;")
codebook <- DBI::dbGetQuery(db, "SELECT * FROM codebook;")
unit_variables <- DBI::dbGetQuery(db, "SELECT * FROM unit_variables;")


# variables table (df) for download interface
# We join variables and datasets table and clean the data a bit so this does not 
# have to happen later on during the automatic codebook generation.
df_variables <- 
  variables %>%
  inner_join(
    select(datasets, dataset_id, project_short, dataset_citation, dataset_tag = tag), 
    by = "dataset_id") %>%
  left_join(select(codebook, codebook_id, cb_entry), by = "codebook_id")
df_variables %<>% 
  mutate(cb_entry = gsub("[", "{[}", cb_entry, fixed = TRUE)) %>%
  mutate(cb_entry = gsub("]", "{]}", cb_entry, fixed = TRUE)) %>%
  # Replace \\`space`\n with \\\n
  mutate(cb_entry = gsub("\\\\\\\\[[:blank:]]\n", "\\\\\\\\\n", cb_entry)) %>%
  # Every occurence of \n that is not preceded by \\ is replaced with \\\n
  mutate(cb_entry = gsub("(?<!\\\\\\\\)\n", "\\\\\\\\\n", cb_entry, perl = TRUE)) %>%
  
  # Escape & symbol with \&
  mutate(cb_entry = gsub("&", "\\&", cb_entry, fixed = TRUE)) %>%
  mutate(citation = gsub("&", "\\&", citation, fixed = TRUE)) %>%
  mutate(name = gsub("&", "\\&", name, fixed = TRUE)) %>%
  # Replace percentage sign % with percent
  mutate(cb_entry = gsub("%", "percent", cb_entry, fixed = TRUE)) %>%
  mutate(cb_entry = gsub("\\percent", "percent", cb_entry, fixed = TRUE)) %>%
  mutate(name = gsub("%", "percent", name, fixed = TRUE)) %>%
  mutate(name = gsub("\\percent", "percent", name, fixed = TRUE)) %>%
  # Replace ~ with \textasciitilde
  mutate(cb_entry = gsub("~", "\\textasciitilde", cb_entry, fixed = TRUE)) %>%
  mutate(name = gsub("~", "\\textasciitilde", name, fixed = TRUE)) %>%
  mutate(citation = gsub("~", "\\textasciitilde", citation, fixed = TRUE))

# For QoG replace \href with \url
df_variables$citation[df_variables$project_short == "qog"] <- 
  gsub("\\href", "\\url", 
       df_variables$citation[df_variables$project_short == "qog"], 
       fixed = TRUE)




# head_var tables-------------------------------------------------------------
# This is 
head_var_children <- 
  DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;") %>%
  arrange(variable_id) %>%
  select(head_var, tag_long) %>%
  filter(!is.na(head_var)) %>%
  mutate(head_var_children_id = 1:nrow(.))


head_var_parents <- 
  DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;") %>%
  collect(n = Inf) %>%
  arrange(variable_id) %>%
  select(head_var = tag_long) %>%
  filter(head_var %in% head_var_children$head_var) %>%
  mutate(head_var_parents_id = 1:nrow(.))


# Table for dataset selection in download interface---------------------------
df_dataset_selection <- methodology %>%
  arrange(dataset_tag, unit_tag) %>%
  select(dataset_tag, unit_tag, show) %>%
  filter(show) %>%
  select(-show) %>%
  left_join(select(datasets, dataset_tag = tag, dataset_name = name,
                   default_unit), 
            by = "dataset_tag") %>%
  left_join(select(units, unit_tag, unit_name), 
            by = "unit_tag") %>%
  select(dataset_tag, dataset_name, unit_tag, unit_name, default_unit) %>%
  arrange(dataset_tag) %>%
  mutate(dataset_selection_id = 1:nrow(.)) %>%
  select(dataset_selection_id, everything())



# Selection table for donwload interface---------------------------------------



DIR <- file.path(ROOT_DIR, "unit_data")
# Selectable variables are these minus those that disappear.
# New variables should always already exist in variables table!
variables %<>% filter(active, cb_show)

# Sort and remove non-desired combinations
methodology %<>% 
  arrange(unit_tag, dataset_tag) %>%
  filter(show)

# Check dataset_id in methodology
#methodology %>%
#	distinct(dataset_id, dataset_tag) %>%
#	group_by(dataset_id) %>%
#	filter(n() > 1) %>% 
#	arrange(dataset_id) %>%
#	view




# Which ones disappear (per output unit)?
df_from_files <- lapply(1:nrow(methodology), function(i){
  meth <- methodology[i, ]
  # print(i)
  vars <- variables %>% 
    arrange(variable_id) %>%
    filter(dataset_id %in% c(meth$dataset_id),
           !grepl("^u_", tag_long)) %$% tag_long
  
  ll <- file.path(DIR, meth$unit_tag, paste0(vars, ".rds"))
  # Remove those that do not have result
  vars <- vars[file.exists(ll)]
  
  if (length(vars) == 0) {
    print(paste0("No variables for unit: ", meth$unit_tag, ":: dataset ::", meth$dataset_tag))
    return(NULL)
  }
  
  data.frame(
    unit_tag = meth$unit_tag,
    dataset_tag = meth$dataset_tag,
    tag_long = vars)
}) %>% bind_rows

# Check unique cb_sections
check_rows <- 
  cb_section %>%
  group_by(dataset_tag, cb_section_tag) %>%
  filter(n() > 1)  %>%
  arrange(dataset_tag, cb_section_tag)
stopifnot(nrow(check_rows) == 0L)

outdf <-
  df_from_files %>%
  # Add variable names and cb_sections
  left_join(select(variables, tag_long, variable_name = name, tag, cb_section), 
            by = c("tag_long")) %>%
  # Add codebook section identifiers and names
  left_join(select(cb_section, cb_section_tag, dataset_tag, cb_section_name),
            by = c("dataset_tag", "cb_section" = "cb_section_tag")) %>%
  # Add dataset names
  left_join(select(datasets, dataset_tag = tag, dataset_name = name),
            by = c("dataset_tag")) %>%
  # Add unit names
  left_join(select(units, unit_tag, unit_name),
            by = c("unit_tag")) %>%
  mutate(select_id = 1:nrow(.)) %>%
  select(select_id, unit_tag, unit_name, dataset_tag, dataset_name, cb_section, cb_section_name,
         tag, tag_long, variable_name)

# Last checks!
stopifnot(!is.na(outdf$unit_name))
stopifnot(!is.na(outdf$dataset_name))
stopifnot(!is.na(outdf$cb_section))
stopifnot(!is.na(outdf$cb_section_name))
stopifnot(!is.na(outdf$variable_name))

outdf %<>% filter(is.na(variable_name))
