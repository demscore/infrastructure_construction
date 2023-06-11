library(dplyr)
library(demutils)

db <- pg_connect()

### -----------------------------------------------------------
### Choose original variables and calculate non-missing obs
### absolute and relative to identifier variables
### -----------------------------------------------------------

calculate_scores_org_data <- function(df, p){
  
    df_n <- df %>% summarize(across(.cols = names(df), .fns = ~ sum(!is.na(.)))) 
  
    df_p <- df %>% summarize(across(.cols = names(df), .fns = ~ mean(!is.na(.)) * 100))
  
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
  
  # Count how many matches per translated variable there are 
  # within the end output unit
  
  # Absolute matches
  df_n <- df %>% summarize(across(.cols = names(test), .fns = ~ sum(!is.na(.)))) 
  
  # Percentage score in relation to observations in the end output unit
  df_p <- df %>% summarize(across(.cols = names(test), .fns = ~ mean(!is.na(.)) * 100))
  
  
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
  select(-end_matched_percent, -obs_percent) %>%
  mutate(lost_obs = (.$obs_sum - .$end_matched_sum)) %>%
  mutate(lost_obs_perc = (lost_obs / obs_sum) * 100) %>%
  mutate_if(is.numeric, round, digits = 2)

# When translating the variable hdata_infocap_ybcov_ability from the hdata_infocap 
# dataset to the V-Dem Country-Year Output Unit, we lose 2172 total non-missing observations. 
# This corrensponds to 12.52% of the non-missing observations from the original dataset 
# for this variable.
