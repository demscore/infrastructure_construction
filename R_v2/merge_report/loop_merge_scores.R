# We assume unit_data/ is correct and ready


# Calculating merge scores in the end OU takes over 1h. This needs to be optimized.
# Hence, recalculate scores only when unit data is correct and ready, i.e. 
# when all tasks in tasks table are done. 

# Scores are also stored in files, these are loaded in line 169 onwards.
library(dplyr)
library(demutils)


# Function definitions----------------------------------------
calculate_scores_org_data <- function(df, p){
  
  df[df == -11111] <- NA
  
  df_n <- df %>% summarize(across(.cols = names(df), .fns = ~ sum(!is.na(.)))) 
  
  df_p <- df %>% summarize(across(.cols = names(df), .fns = ~ mean(!is.na(.)) * 100))
  
  # reshape wide to long
  df_p_l <- wide_to_long(df_p) %>% rename(obs_percent = value) 
  df_n_l <- wide_to_long(df_n) %>% rename(obs_sum = value) 
  
  scores <- left_join(df_p_l, df_n_l, by = c("variable")) %>%
    mutate_if(is.numeric, round, digits = 2)
  
  scores %<>% filter(!grepl("^u_", variable))
  
  return(scores)
  
}

calculate_merge_score_end_unit <- function(df) {
  
  df[df == -11111] <- NA
  
  # Count how many matches per translated variable there are within the end output unit
  
  # Absolute matches
  df_n <- df %>% summarize(across(.cols = names(df), .fns = ~ sum(!is.na(.)))) 
  
  # Percentage score in relation to observations in the end output unit
  df_p <- df %>% summarize(across(.cols = names(df), .fns = ~ mean(!is.na(.)) * 100))
  
  
  # reshape wide to long
  df_p_l <- wide_to_long(df_p) %>% rename(end_matched_percent = value) 
  df_n_l <- wide_to_long(df_n) %>% rename(end_matched_sum = value) 
  
  merges <- left_join(df_p_l, df_n_l, by = c("variable")) %>%
    mutate_if(is.numeric, round, digits = 2) %>%
    filter(!grepl("^u_", variable))
  
  return(merges)
  
}

# Load reference tables---------------------------------------------------------
db <- pg_connect()

units <- tbl(db, "units") %>% collect(n = Inf) %>% filter(active)
datasets_tbl <- tbl(db, "datasets") %>% collect(n = Inf)
variables <- tbl(db, "variables") %>% collect(n = Inf) %>% filter(active)
methodology <- tbl(db, "methodology") %>% collect(n = Inf) %>% filter(show)



### -----------------------------------------------------------
### Choose original variables and calculate non-missing obs
### absolute and relative to identifier variables
### -----------------------------------------------------------

# Filter datasets---------------------------------------------------------------

datasets <- datasets_tbl %>% filter(grepl("2.0", demscore_release))
variables %<>% filter(new_variable == FALSE)


# Loop over dataset tags--------------------------------------------------------
all_scores_org <- list()
for (i in 1:nrow(datasets)) {
	# Load dataset
	df <- read_unit_data(datasets$default_unit[i], datasets$tag[i], variables, datasets)
  	# Call the calculate_scores_org_data function
  	scores <- calculate_scores_org_data(df, datasets$tag[i])

	scores %<>% mutate(
		dataset_tag = datasets$tag[i],
		unit_tag = datasets$default_unit[i])

	# Return the scores
	all_scores_org[[i]] <- scores
}
	
# Bind the data.frames together by row
all_scores_org %<>% bind_rows(.) %>%
  select(unit_tag, dataset_tag, variable, everything())

# Write file
write_file(all_scores_org,
              file.path(Sys.getenv("ROOT_DIR"),
                        "merge_scores/all_scores_org_ou.rds"),
              overwrite = TRUE)

df_ou <- read_file(file.path(Sys.getenv("ROOT_DIR"),
                    "merge_scores/all_scores_org_ou.rds"))
### -----------------------------------------------------------
### Define function calculating absolute and percentage scores
### based on non missing observations for every variable in 
### every OU in to which it is translated
### -----------------------------------------------------------

# Filter reference tables-------------------------------------------------------
datasets <- datasets_tbl %>% filter(grepl("2.0", demscore_release))
methodology %<>%
	# Unfilter this combination as the original variables from those datasets 
  # are not translated to the QoG CY unit and vdem_vparty only has new_vars when translated
  filter(!grepl("qog_qad_bud|qog_qad_inst|vdem_vparty", dataset_tag)) %>%
	filter(show = TRUE) %>%
	arrange(dataset_tag, ordering) %>%
	select(dataset_tag, unit_tag)
	

all_scores_end <- list()

# Loop over rows in methodology-------------------------------------------------
for (i in 1:nrow(methodology)) {
	# i <- 1
	ds_tag <- methodology$dataset_tag[i]
	u_tag <- methodology$unit_tag[i]

	# Load data from output unit
	#df <- read_unit_data(u_tag, ds_tag, variables, datasets)

  print(i)
  
	 #Call read_unit_data with the current unit_tag and dataset_tag
     df <- tryCatch({
       	read_unit_data(u_tag, ds_tag, variables, datasets)
      }, error = function(e) {
       	# Check if error message contains "There are no variables for this selection!"
       	if (grepl("There are no variables for this selection!", e$message)) {
         	# Handle the error here, e.g. print a message or take other action
         	print(paste("Error: ", e$message))
         	# Return an empty data frame to continue the loop
         	return(data.frame())
       	} else {
         	# If error message does not match the expected errors, re-throw the error
         	stop(e)
       	}
     })
     
    df_scores <- calculate_merge_score_end_unit(df)
    df_scores %<>% mutate(
		dataset_tag = ds_tag,
		unit_tag = u_tag)
	
	all_scores_end[[i]] <- df_scores
}

all_scores_end %<>% bind_rows(.)


write_file(all_scores_end,
           file.path(Sys.getenv("ROOT_DIR"),
                     "merge_scores/all_scores_end_ou.rds"),
           overwrite = TRUE)



# Read files for merging to not have to run the whole script again--------------
all_scores_org_ou <- read_file(file.path(Sys.getenv("ROOT_DIR"),
                               "merge_scores/all_scores_org_ou.rds"))

all_scores_end_ou <- read_file(file.path(Sys.getenv("ROOT_DIR"),
                               "merge_scores/all_scores_end_ou.rds"))

outdf <- left_join(all_scores_end_ou,
	select(all_scores_org_ou, -dataset_tag, -unit_tag),
	by = "variable") 

# Losses only make sense to calculate for direct translations between same 
# identifiers, hence filter methodology table for ordering == 1. Negative values
# in losses also do not provide useful information for useres and come from 
# aggregations in direct translations. Hence negative values are set to 9999.

methodology <- tbl(db, "methodology") %>% collect(n = Inf) %>%
  select(dataset_tag, unit_tag, ordering) 

dup <- duplicates(methodology, c("unit_tag", "dataset_tag"))

outdf <- inner_join(outdf, methodology, by = c("dataset_tag", "unit_tag"))

outdf %<>% mutate(obs_sum = case_when(
  ordering > 1 ~ 0,
  TRUE ~ obs_sum
  )) %>% 
  mutate(obs_percent = case_when(
    ordering > 1 ~ 0,
    TRUE ~ obs_percent
  )) %>%
  mutate(lost_obs_sum = (.$obs_sum - .$end_matched_sum)) %>%
  mutate(lost_obs_percent = (lost_obs_sum / obs_sum) * 100) %>%
  mutate_if(is.numeric, round, digits = 2) %>%
  rename(obs_percent_org = obs_percent) %>%
  rename(obs_sum_org = obs_sum) %>%
  rename(tag_long = variable) %>%
  mutate(lost_obs_percent = case_when(
    lost_obs_percent < 0 ~ 9999,
    TRUE ~ lost_obs_percent
  )) %>%
  mutate(lost_obs_sum = case_when(
    lost_obs_sum < 0 ~ 9999,
    TRUE ~ lost_obs_sum
  ))

# Append when everything looks good, but delete all current rows before! And reset the PK

#pg_truncate_table("merge_scores", db)  
#pg_send_query(db, "SELECT setval('merge_scores_merge_id_seq', 1, false);")
#pg_append_table(outdf, "merge_scores", db)
#pg_send_query(db, "UPDATE merge_scores
#                     SET lost_obs_percent = NULL,
#                         lost_obs_sum = NULL
#                    WHERE lost_obs_sum = 9999 AND lost_obs_percent = 9999;")
