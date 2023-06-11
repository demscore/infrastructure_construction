library(dplyr)
library(demutils)

db <- pg_connect()

### -----------------------------------------------------------
### Translate H-DATA Infocap to V-Dem Country Year OU
### -----------------------------------------------------------


variables <- tbl(db, "variables") %>% collect(n = Inf)
datasets <- tbl(db, "datasets") %>% collect(n = Inf)
df <- read_unit_data("u_hdata_country_year", "hdata_infocap",  variables, datasets)

test <- to_u_vdem_country_year(df)

### -----------------------------------------------------------
### Define function calculating absolute and percentage scores
### based on non missing observations for every QoG STD TS 
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
  df_p_l <- wide_to_long(df_p) %>% rename(matched_percent = value) 
  df_n_l <- wide_to_long(df_n) %>% rename(matched_sum = value) 
  
  merges <- left_join(df_p_l, df_n_l, by = c("variable")) %>%
    mutate_if(is.numeric, round, digits = 2) %>%
    filter(!grepl("^u_", variable))
  
  return(merges)
  
}

### -----------------------------------------------------------
### Apply function
### -----------------------------------------------------------

test_merge_scores <- calculate_merge_score_end_unit(test)

### -----------------------------------------------------------
### Discussion
### -----------------------------------------------------------

# One problem with this is that we do not take into account that 
# some observations are missing in the original data (qog std ts)
# That makes the scores looks lower than they actually are
