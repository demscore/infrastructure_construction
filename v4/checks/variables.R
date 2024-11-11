library(dplyr)
library(demutils)

db <- pg_connect()

#==============================================================================
# CHECKS ON THE VARIABLES TABLE 
#
# The variables table in the PostgreSQL database does not update automatically.
# This script checks whether there are variables in the variables table that 
# do not exist in the datasets anymore or if there are new variables that are 
# not yet in the variables table. Reason for both could be data updates by the
# partnering modules. Changes are to made manually directly in pgAdmin
# (unless it seems more useful to do it from within R).
#
# In addition to that, the script checks for duplicate long_tags in step 3 and 
# makes sure that all tags are a substrings of their long_tags in step 4. 
#==============================================================================

datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;") %>%
  filter(grepl(Sys.getenv("DEMSCORE_RELEASE"), demscore_release))

# datasets %<>% filter(tag == 'ucdp_orgv_cy')

#==============================================================================
# 1. Get tags from all datasets
#==============================================================================

# Fix original column names for complab dataset
fix_complab_spin_plb <- function(df) {
  names(df) <- df[1, ]
  return(df)
}

i <- datasets$tag
ll <- list()

for(i in 1:nrow(datasets)){
  
  
  tag = names(read_datasets(paste0(datasets$tag[i]), db))
  
  newvars <- data.frame(
    dataset_id = paste(datasets$dataset_id[i]),
    tag = tag,
    tag_long = paste(datasets$tag[i], tag, sep = "_"), 
    r_data_type = sapply(tag, class)
  )
  
  # Deselect unit cols. Make sure no other variable starts with u_, if it does, 
  # adjust the pattern
  newvars %<>% filter(!grepl("^u_", tag))
  
  print(i)
  
  ll[[i]] <- newvars
}

outdf <- bind_rows(ll)

#==============================================================================
# 2. Get tags from variables table and compare
#==============================================================================
variables <- DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;")

variables %<>% select(tag, tag_long, dataset_id)

diff1 <- anti_join(outdf, variables, by = c("tag_long"))
diff2 <- anti_join(variables, outdf, by = c("tag_long"))

#==============================================================================
# 3. Make sure that there are no duplicates in the variables table.
#==============================================================================

variables <- DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;")

stopifnot(nrow(variables) == length(unique(variables$tag_long)))

### ============================================================================
# 4. Check long_tags
# 
# This section checks whether all tags in the variables table are a substring of
# tag_long in the same table. If there are inconsistencies, adjust them manually!

# All is fine when the filtered variable df has 0 rows and 3 cols in the end.
### ============================================================================

variables %<>%
  filter(active) %>%
  select(tag, tag_long)

tag <- variables$tag
tag_long <- variables$tag_long

variables$comp <- mapply(grepl, variables$tag, variables$tag_long)

variables %<>% filter(comp == FALSE)

stopifnot(nrow(variables) == 0)
