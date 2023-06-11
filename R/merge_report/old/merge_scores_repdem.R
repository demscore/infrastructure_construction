library(dplyr)
library(demutils)

db <- pg_connect()


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

df <- read_datasets("repdem_paged_paco", db)
repdem_org_scores <- calculate_scores_org_data(df, "repdem_paged_paco_")

### -----------------------------------------------------------
### Translate H-DATA Infocap to V-Dem Country Year OU
### -----------------------------------------------------------

variables <- tbl(db, "variables") %>% collect(n = Inf)
datasets <- tbl(db, "datasets") %>% collect(n = Inf)
df <- read_unit_data("u_repdem_cabinet_date", "repdem_paged_paco",  variables, datasets)

test <- to_u_vdem_country_year(df)

### -----------------------------------------------------------
### Define function calculating absolute and percentage scores
### based on non missing observations for every Repdem PAGED 
### Party Codes variable in the V-Dem CY Output Unit
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

repdem_end_scores <- calculate_merge_score_end_unit(test)

### -----------------------------------------------------------
### Calculate the absolute and relative loss for each variable
### -----------------------------------------------------------

loss <- left_join(repdem_org_scores, repdem_end_scores, by = c("variable")) %>%
  #select(-end_matched_percent, -obs_percent) %>%
  mutate(lost_obs = (.$obs_sum - .$end_matched_sum)) %>%
  mutate(lost_obs_perc = (lost_obs / obs_sum) * 100) %>%
  mutate_if(is.numeric, round, digits = 2)