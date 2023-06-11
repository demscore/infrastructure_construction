library(dplyr)
library(demutils)

db <- pg_connect()

### -----------------------------------------------------------
### Load datasets
### -----------------------------------------------------------

hdata_infocap <- read_datasets("hdata_infocap", db)
vdem_ert <- read_datasets("vdem_ert", db)
vdem_cy <- read_datasets("vdem_cy", db) 

### -----------------------------------------------------------
### Merge data manually
### -----------------------------------------------------------

#manual <- left_join(vdem_cy, hdata_infocap, by = c("country_id" = "vdemcode", 
#                                                    "year" = "year")) %>%
#  select(country_id, year, 4175:4189) 


manual <- left_join(vdem_ert, hdata_infocap, by = c("country_id" = "vdemcode", 
                                                   "year" = "year")) %>%
  select(country_id, year, 46:60) 
  
calculate_merge_score_end_unit <- function(df, p) {
  
  # Count how many matches per translated variable there are 
  # within the end output unit
  
  # Absolute matches
  df_n <- df %>% summarize(across(.fns = ~ sum(!is.na(.)))) 
  
  # Percentage score in relation to observations in the end output unit
  df_p <- df %>% summarize(across(.fns = ~ mean(!is.na(.)) * 100))
  
  
  # reshape wide to long
  df_p_l <- wide_to_long(df_p) %>% rename(man_matched_percent = value) 
  df_n_l <- wide_to_long(df_n) %>% rename(man_matched_sum = value) 
  
  merges <- left_join(df_p_l, df_n_l, by = c("variable")) %>%
    mutate_if(is.numeric, round, digits = 2) %>%
    filter(!grepl("^u_", variable))
  
  merges$variable <- paste0(p, merges$variable)
  
  return(merges)
  
}

manual_scores <- calculate_merge_score_end_unit(manual, "hdata_infocap_")

### ===========================================================
### COMPARE TO DEMSCORE METHOD
### ===========================================================

### -----------------------------------------------------------
### Choose original variables and calculate non-missing obs
### absolute and relative to identifier variables
### -----------------------------------------------------------

calculate_scores_org_data <- function(df, p){
  
  df_n <- df %>% summarize(across(.fns = ~ sum(!is.na(.)))) 
  
  df_p <- df %>% summarize(across(.fns = ~ mean(!is.na(.)) * 100))
  
  # reshape wide to long
  df_p_l <- wide_to_long(df_p) %>% rename(obs_percent = value) 
  df_n_l <- wide_to_long(df_n) %>% rename(obs_sum = value) 
  
  scores <- left_join(df_p_l, df_n_l, by = c("variable")) %>%
    mutate_if(is.numeric, round, digits = 2)
  
  scores %<>% filter(!grepl("^u_", variable))
  
  scores$variable <- paste0(p, scores$variable)
  
  return(scores)
  
}

df <- read_datasets("hdata_infocap", db)
hdata_org_scores <- calculate_scores_org_data(df, "hdata_infocap_")

### -----------------------------------------------------------
### Translate H-DATA Infocap to V-Dem Country Year OU
### -----------------------------------------------------------

variables <- tbl(db, "variables") %>% collect(n = Inf)
datasets <- tbl(db, "datasets") %>% collect(n = Inf)
df <- read_unit_data("u_hdata_country_year", "hdata_infocap",  variables, datasets)

test <- to_u_vdem_country_year(df)

### -----------------------------------------------------------
### Define function calculating absolute and percentage scores
### based on non missing observations for every H-DATA Infocap
### variable in the V-Dem CY Output Unit
### -----------------------------------------------------------

calculate_merge_score_end_unit <- function(df) {
  
  # Absolute matches
  df_n <- df %>% summarize(across(.fns = ~ sum(!is.na(.)))) 
  
  # Percentage score in relation to observations in the end output unit
  df_p <- df %>% summarize(across(.fns = ~ mean(!is.na(.)) * 100))
  
  # reshape wide to long
  df_p_l <- wide_to_long(df_p) %>% rename(end_matched_percent = value) 
  df_n_l <- wide_to_long(df_n) %>% rename(end_matched_sum = value) 
  
  merges <- left_join(df_p_l, df_n_l, by = c("variable")) %>%
    mutate_if(is.numeric, round, digits = 2)
  
  return(merges)
  
}

hdata_end_scores <- calculate_merge_score_end_unit(test)

### -----------------------------------------------------------
### Calculate the absolute and relative loss for each variable
### -----------------------------------------------------------

loss <- left_join(hdata_org_scores, hdata_end_scores, by = c("variable")) %>%
  #select(-end_matched_percent, -obs_percent) %>%
  mutate(lost_obs = (.$obs_sum - .$end_matched_sum)) %>%
  mutate(lost_obs_perc = (lost_obs / obs_sum) * 100) %>%
  mutate_if(is.numeric, round, digits = 2)

### -----------------------------------------------------------
### Add Demscore's added value score for each H-Data Infocap
### variable when translated to V-Dem CY
### -----------------------------------------------------------

added_value <- left_join(loss, manual_scores, by = c("variable")) %>%
  filter(variable != "hdata_infocap_year") %>%
  filter(variable != "hdata_infocap_cname") %>%
  mutate(added_value_abs = (obs_sum - man_matched_sum)) %>%
  mutate(added_value_perc = (obs_percent - man_matched_percent)) 
           
