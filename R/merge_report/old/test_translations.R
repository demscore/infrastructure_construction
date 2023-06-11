library(dplyr)
library(demutils)

db <- pg_connect()


### -----------------------------------------------------------
### Load datasets
### -----------------------------------------------------------

hdata_infocap <- read_datasets("hdata_infocap", db)
vdem_ert <- read_datasets("vdem_ert", db)
#vdem_cy <- read_datasets("vdem_cy", db) 

### -----------------------------------------------------------
### Merge data manually
### -----------------------------------------------------------

#manual <- left_join(vdem_cy, hdata_infocap, by = c("country_id" = "vdemcode", 
#                                                    "year" = "year")) %>%
#  select(country_id, year, 4175:4189) 


manual <- left_join(hdata_infocap, vdem_ert, by = c("vdemcode" = "country_id", 
                                                    "year" = "year")) %>%
  select(1:17) 

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