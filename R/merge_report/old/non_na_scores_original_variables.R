library(dplyr)
library(demutils)

db <- pg_connect()

### -----------------------------------------------------------
### Choose original variables and calculate non-missing obs
### absolute and relative to identifier variables
### -----------------------------------------------------------

# Put this into one function called calculate_original_scores

calculate_scores_org_data <- function(df, p){
  
  df_n <- df %>% summarize(across(.cols = names(df), .fns = ~ sum(!is.na(.)))) 
  
  df_p <- df %>% summarize(across(.cols = names(df), .fns = ~ mean(!is.na(.)) * 100))
  
  # reshape wide to long
  df_p_l <- wide_to_long(df_p) %>% rename(obs_percent = value) 
  df_n_l <- wide_to_long(df_n) %>% rename(obs_sum = value) 
  
  scores <- left_join(df_p_l, df_n_l, by = c("variable")) %>%
    mutate_if(is.numeric, round, digits = 2)
  
  scores %<>% filter(!grepl("^u_", variable))
  
  scores$variable <- paste0(p, "_", scores$variable)
  
  return(scores)
  
}

units <- tbl(db, "units") %>% collect(n = Inf)
datasets <- tbl(db, "datasets") %>% collect(n = Inf) #%>%
  #filter(grepl("^hdata_", tag))

dataset_tags <- datasets$tag

ds <- list()
for (i in seq_along(dataset_tags)) {
  ds[[i]] <- read_datasets(dataset_tags[i], db)
}

all_scores <- data.frame()

# Loop through each dataset
for (i in seq_along(ds)) {
  
  # Get the current dataset and its corresponding tag
  df <- ds[[i]]
  tag <- dataset_tags[i]
  
  scores <- calculate_scores_org_data(df, tag)
  
  all_scores <- rbind(all_scores, scores)
}