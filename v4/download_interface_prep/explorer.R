library(dplyr)
library(demutils)

db <- pg_connect()

# -- Load tables ----------------------------------------------------------------
variables <- 
  DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;")
codebook <- 
  DBI::dbGetQuery(db, "SELECT codebook_id, cb_entry FROM codebook;")
cb_section <- 
  DBI::dbGetQuery(db, "SELECT cb_section_name, cb_section_tag, dataset_id FROM cb_section;")
units <- 
  DBI::dbGetQuery(db, "SELECT unit_id, unit_tag, unit_name FROM units WHERE active IS TRUE;")
datasets <- 
  DBI::dbGetQuery(db, "SELECT tag, name, default_unit, dataset_id FROM datasets WHERE demscore_release ~ '4.0';")

# -- Select relevant columns -----------------------------------------------------
vars <- variables %>% select(variable_id, codebook_id, dataset_id, var_tag = tag, 
                             tag_long, var_name = name, r_data_type, cb_section)

# -- Merge with codebook ---------------------------------------------------------
final <- left_join(vars, codebook, by = "codebook_id") %>%
    select(-codebook_id) %>%
    left_join(cb_section, by = c("dataset_id", "cb_section" = "cb_section_tag")) %>%
    left_join(datasets, by = "dataset_id") %>%
    left_join(units, by = c("default_unit" = "unit_tag")) %>%
  select(-tag, -default_unit, -unit_id, -dataset_id,
         -cb_section, -r_data_type) %>%
  arrange(name, cb_section_name, var_name)


# ==============================================================================
# Additional meta data
# ==============================================================================

# -- Prepare for min_year, max_year and country coverage -----------------------

# Filter out units that do not have a year column
datasets %<>% 
  #filter(project_short == "repdem") %>%
  #filter(!grepl("u_qog_country$|u_qog_region$|u_qog_agency_inst|u_qog_resp_eqi_17|u_qog_resp_eqi_21|u_qog_resp_eqi_perc_17", default_unit)) %>%
  rename(dataset_tag = tag)

# Prepare additional variable infor for merging
info <- left_join(datasets, variables, by = c("dataset_id")) %>% 
  select(variable_id, dataset_tag, dataset_id, tag)

# Loop over datasets and grow empty list
tags <- datasets$dataset_tag

ll <- list()
lll <- list()

for(t in tags) {
  
  # Read the dataset for the current tag
  df <- read_datasets(t, db)
  
  # Get min and max years
  year_var <- grep("^(u_(?!.*(out_|location_|_pa_conflict|_pa_dyad|_pa_country|_end)).*year$|.*_year_in|.*_agency_fy)", 
                   names(df), value = TRUE, perl = TRUE)

  # Initialize an empty dataframe to store results
  result_df <- data.frame(variable = character(), 
                          min_year = integer(), 
                          max_year = integer(), 
                          dataset_tag = character(),
                          stringsAsFactors = FALSE)
  
  # Check if any element in year_var matches any column name in df
  if (any(year_var %in% names(df))) {
    
    # Loop over each variable
    for (i in 1:ncol(df)) {  
      non_missing_years <- df[, year_var][!is.na(df[, i])]
      if (length(non_missing_years) > 0) {
        min_years <- min(non_missing_years)
        max_years <- max(non_missing_years)
      } else {
        min_years <- NA
        max_years <- NA
      }
      dataset_tag <- t
      result_df <- rbind(result_df, 
                         data.frame(
                           variable = names(df)[i], 
                           min_year = min_years,
                           max_year = max_years,
                           dataset_tag = dataset_tag))
    }
    
    ll[[t]] <- result_df
    
  } else {
    
    result_df2 <- data.frame(variable = character(), 
                             min_year = integer(), 
                             max_year = integer(), 
                             dataset_tag = character(),
                             stringsAsFactors = FALSE)
    
    # Loop over each variable
    for (i in 1:ncol(df)) {
      dataset_tag <- t
      result_df2 <- rbind(result_df2, 
                          data.frame(
                            variable = names(df)[i], 
                            min_year = 0,
                            max_year = 0,
                            dataset_tag = dataset_tag))
    }
    lll[[t]] <- result_df2
  }
}

out <- do.call(rbind, c(ll, lll))



# Remove unit variables
out <- left_join(out, info, 
                 by = c("dataset_tag", "variable" = "tag"))

out %<>% filter(!is.na(variable_id))


# ==============================================================================
# Merge final and outdf
# ==============================================================================
out <- left_join(out, final, by = c("variable_id")) 

df <- out %>% 
  select(-variable, -dataset_tag, -name) %>%
  rename(primary_unit = unit_name)

checks <- df %>% filter(max_year == -Inf) %>%
  select(-cb_entry)

write_file(checks, file.path(Sys.getenv("ROOT_DIR"), "checks", "4.0", 
                             "variables", "checks_selection_tool.csv"))

df %<>% filter(max_year != -Inf) %>%
  filter(!is.na(var_name))

df <- clean_latex(df, "cb_entry")

# Update the years for vdem_cd and vdem_coder level using the years from vdem_cy
cys <- df %>% filter(dataset_id == 16) 
df_f <- df %>% filter(dataset_id %in% c(17, 18))
df %<>%
  filter(!(dataset_id %in% c(17, 18)))

merged_df <- merge(df_f, cys, 
                   by = "var_tag", 
                   suffixes = c("_dest", "_source"))

merged_df$min_year_dest <- 
  ifelse(merged_df$min_year_source != 0, 
         merged_df$min_year_source, 
         merged_df$min_year_dest)

merged_df$max_year_dest <- 
  ifelse(merged_df$max_year_source != 0, 
         merged_df$max_year_source, 
         merged_df$max_year_dest)

names(merged_df) <- gsub("_dest", "", names(merged_df))

merged_df %<>%
  select(-ends_with("source"))

df <- rbind(df, merged_df) 

# Update years for vpert coder level

cys <- df %>% filter(dataset_id == 22) 
df_f <- df %>% filter(dataset_id == 23)
df %<>%
  filter(!(dataset_id %in% c(23)))

merged_df <- merge(df_f, cys, 
                   by = "var_tag", 
                   suffixes = c("_dest", "_source"))

merged_df$min_year_dest <- 
  ifelse(merged_df$min_year_source != 0, 
         merged_df$min_year_source, 
         merged_df$min_year_dest)

merged_df$max_year_dest <- 
  ifelse(merged_df$max_year_source != 0, 
         merged_df$max_year_source, 
         merged_df$max_year_dest)

names(merged_df) <- gsub("_dest", "", names(merged_df))

merged_df %<>%
  select(-ends_with("source"))

df <- rbind(df, merged_df) 

# Add years for views pgm

df %<>%
  mutate(
    min_year = case_when(
      grepl("^views_", tag_long) & grepl("_22", tag_long) ~ "2022",
      grepl("^views_", tag_long) & grepl("_23", tag_long) ~ "2023",
      grepl("^views_", tag_long) & grepl("_24", tag_long) ~ "2024",
      TRUE ~ min_year
    ),
    max_year = case_when(
      grepl("^views_", tag_long) & grepl("_22", tag_long) ~ "2025",
      grepl("^views_", tag_long) & grepl("_23", tag_long) ~ "2026",
      grepl("^views_", tag_long) & grepl("_24", tag_long) ~ "2027",
      TRUE ~ max_year
    )
  )

df %<>% filter(!is.na(cb_entry))

dups <- duplicates(df, c("variable_id"), keep_all = TRUE)

stopifnot(nrow(dups) == 0)

# ==============================================================================
# Append to postgres
# ==============================================================================

pg_send_query(db, "TRUNCATE TABLE variable_search;")

pg_append_table(df, "variable_search", db)

# ==============================================================================
# Prepare refs to have latest version available
# ==============================================================================

prepare_autogen()
