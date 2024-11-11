library(dplyr)
library(demutils)

db <- pg_connect()

DEMSCORE_RELEASE <- Sys.getenv("DEMSCORE_RELEASE")

### ============================================================================
# Run this script BEFORE generating secondary unit data!

# The aim is that all dataframes created in this script have 0 rows, i.e. that 
# there are no inconsistencies in the entries across the loaded tables. 

# This script extracts the primary and secondary units column from the datasets 
# table as well as the start and finish columns from the unit_trans table.

# In a first step it checks whether all datasets with the same primary unit have
# the same secondary units listed by grouping by primary_units and secondary_
# units and then checking whether the length of each group is 1. NOTE that it is 
# important that the secondary units are listed in the exact same order for each
# dataset from a similar unit.

# In a second step, the extracts the primary and secondary units column from the 
# datasets table as well as the start and finish columns from the unit_trans 
# table and checks whether unit combinations from the datasets table are missing
# in the unit_trans table and vice versa.

# In a third step, the script checks whether dataset to unit combinations from 
# the datasets table are missing in the methodology table.
### ============================================================================




### ============================================================================
### STEP 1: Check datasets' primary and secondary units
### ============================================================================

datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;")

ds <- datasets %>% select(primary_units, secondary_units) %>%
  distinct() %>%
  filter(!is.na(secondary_units)) %>%
  count(primary_units)

stopifnot(`Secondary units are not the same for all datasets with the same primary 
           unit!` = all(ds$n == 1))

# If stops, uncomment to print primary units for which that is the case and check
# in the datasets table
#ds %<>% filter(ds$n != 1) %>%
 #print(ds$primary_units)







### ============================================================================
### STEP 2: Check unit_trans table
### ============================================================================

# Load datasets table, select columns and stretch secondary units---------------
datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;")

df <- datasets %>% select(primary_units, secondary_units) %>%
  distinct(primary_units, .keep_all = TRUE)

df <- tidyr::separate_rows(df, secondary_units, sep = ",") %>%
  arrange(primary_units, secondary_units)


# Load unit_trans table, select columns-----------------------------------------
unit_trans <- DBI::dbGetQuery(db, "SELECT * FROM unit_trans;")

# Before comparing, check if there are duplicate entries in unit_trans----------

dups <- duplicates(unit_trans, c("start", "finish"))

stopifnot(`There are duplicate entries in unit_trans!` = nrow(dups) == 0)

df1 <- unit_trans %>% select(start, finish) %>%
  arrange(start, finish)

# Differences: Which unit combinations do not have an entry in unit_trans? -----
# anti_join returns all rows from x without a match in y

diff_utrans <- anti_join(df, df1, by = c("primary_units" = "start",
                                         "secondary_units" = "finish")) %>%
  arrange(primary_units, secondary_units) %>%
  filter(!is.na(secondary_units))
  
diff_utrans %<>% filter(!grepl(",", diff_utrans$primary_units))

# Are units missing in the secondary_units column in the datasets table?--------
diff_ds <- anti_join(df1, df, by = c("start" = "primary_units",
                                     "finish" = "secondary_units")) %>%
  arrange(start, finish) 


# If a lot is missing, create dataframe that can be appended to unit_trans. 
# Change trans_ids!!

# Get latest trans_id
trans_id_latest_rn <- 
  unit_trans %>%
  data.frame() %>%
  filter(trans_id == max(trans_id)) %>%
  select(trans_id) %>%
  pull(trans_id)

id_start <- trans_id_latest_rn+1
id_end <- trans_id_latest_rn+nrow(diff_utrans)

df <- data.frame(
  trans_id = id_start:id_end,
  start = diff_utrans$primary_units,
  finish = diff_utrans$secondary_units,
  direct = TRUE,
  # For direct
  path = paste0("to_", diff_utrans$secondary_units)
) %>%
  arrange(start, finish)

# If it looks good, append it to unit_trans
# pg_append_table(df, "unit_trans", db)






### ============================================================================
### STEP 2: Check methodology table
### ============================================================================

# Load datasets table, select columns and stretch secondary units --------------

datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;")

df <- datasets %>% select(tag, primary_units, secondary_units) %>%
  distinct(tag, .keep_all = TRUE)

df <- tidyr::separate_rows(df, secondary_units, sep = ",") %>%
  arrange(tag, secondary_units)


# Load and check methodology table, select columns------------------------------
methodology <- DBI::dbGetQuery(db, "SELECT * FROM methodology;")


# Check if there are duplicat entries in methodology----------------------------

dups <- duplicates(methodology, c("dataset_tag", "unit_tag")) %>% filter(show = TRUE)

stopifnot(`There are duplicate entries in methodology!` = nrow(dups) == 0)

# Check whether unit tags have the correct unit ids and datasets have the 
# correct dataset_ids ----------------------------------------------------------

# units
dups2 <- methodology %>% select(unit_id, unit_tag, dataset_id, dataset_tag) %>%
  distinct(unit_id, unit_tag, .keep_all = TRUE) %>%
  count(unit_tag)

stopifnot(`Unit IDs are not consistenly assigned to unit tags!` = all(dups2$n == 1))

# If script stops, uncomment this to check
#dups2 %<>% filter(dups2$n != 1) %>%
#  print(dups2$unit_tag)

# datasets
dups3 <- methodology %>% select(unit_id, unit_tag, dataset_id, dataset_tag) %>%
  distinct(dataset_id, dataset_tag, .keep_all = TRUE) %>%
  count(dataset_tag)

stopifnot(`Dataset IDs are not consistenly assigned to dataset tags!` = all(dups3$n == 1))

dups3 %<>% filter(dups3$n != 1) %>%
  print(dups2$dataset_tag)

# Select relevant columns ------------------------------------------------------
df1 <- methodology %>% #filter(ordering != 0) %>%
  select(dataset_tag, unit_tag) %>%
  arrange(dataset_tag, unit_tag)

# Differences: Which combinations do not have an entry in methodology? ---------
# anti_join returns all rows from x without a match in y

diff_meth <- anti_join(df, df1, by = c("tag" = "dataset_tag",
                                         "secondary_units" = "unit_tag")) %>%
  arrange(tag, secondary_units) %>%
  filter(!is.na(secondary_units))


# Are units missing in the secondary_units column in the datasets table?--------
diff_ds <- anti_join(df1, df, by = c("dataset_tag" = "tag",
                                     "unit_tag" = "secondary_units")) %>%
  arrange(dataset_tag, unit_tag)

# If a lot is missing, create a dataframe that can be appended to methodology.
# Join in ids 

datasets %<>% select(tag, dataset_id)

diff_meth <- left_join(diff_meth, datasets, by = c("tag"))

units <- DBI::dbGetQuery(db, "SELECT * FROM units;")

units %<>% select(unit_id, unit_tag)

diff_meth <- left_join(diff_meth, units, by = c("secondary_units" = "unit_tag")) %>%
  filter(tag != "repdem_paged_paco_basic")

meth_id_latest_rn <- 
  methodology %>%
  data.frame() %>%
  filter(meth_id == max(meth_id)) %>%
  select(meth_id) %>%
  pull(meth_id)

id_start <- meth_id_latest_rn+1
id_end <- meth_id_latest_rn+nrow(diff_meth)
  
# Create dataframe that can be appended, change meth_ids!
df <- data.frame(
  meth_id = id_start:id_end,
  dataset_id = diff_meth$dataset_id,
  dataset_tag = diff_meth$tag,
  unit_id = diff_meth$unit_id,
  unit_tag = diff_meth$secondary_units,
  show = TRUE,
  ordering = 1
) %>%
  arrange(unit_tag, dataset_tag)

# If it looks good, append to methodology
# pg_append_table(df, "methodology", db)

# Change ordering manually if necessary!

### ============================================================================
### STEP 3: Check if primary units are missing in the methodology table
### ============================================================================

# Load datasets table, select columns and stretch secondary units --------------

datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;") %>%
  filter(demscore_release == DEMSCORE_RELEASE)

units <- DBI::dbGetQuery(db, "SELECT * FROM units;") %>%
  select(unit_tag, unit_id, unit_name)

df <- datasets %>% select(tag, primary_units, secondary_units) %>%
  distinct(tag, .keep_all = TRUE)


# Load and check methodology table, select columns------------------------------
methodology <- DBI::dbGetQuery(db, "SELECT * FROM methodology;")

meth_id_latest_rn <- 
  methodology %>%
  data.frame() %>%
  filter(meth_id == max(meth_id)) %>%
  select(meth_id) %>%
  pull(meth_id)

diff_meth_primary_ou <- anti_join(df, df1, by = c("tag" = "dataset_tag",
                                                  "primary_units" = "unit_tag")) %>%
  arrange(tag, secondary_units) %>%
  select(tag, primary_units)

datasets %<>% select(dataset_id, tag)

diff_meth_primary_ou %<>% left_join(datasets, ., by = c("tag")) 

diff_meth_primary_ou %<>% left_join(units, ., by = c("unit_tag" = "primary_units")) %>%
  filter(tag != "")

# Get ids
id_start <- meth_id_latest_rn+1
id_end <- meth_id_latest_rn+nrow(diff_meth_primary_ou)

# Create dataframe that can be appended, change meth_ids!
df <- data.frame(
  meth_id = id_start:id_end,
  dataset_id = diff_meth_primary_ou$dataset_id,
  dataset_tag = diff_meth_primary_ou$tag,
  unit_id = diff_meth_primary_ou$unit_id,
  unit_tag = diff_meth_primary_ou$unit_tag,
  show = TRUE, 
  ordering = 0,
  translation_path = paste0(diff_meth_primary_ou$unit_name, " (Primary Output Unit)")
) %>%
  arrange(unit_tag, dataset_tag) 

# If it looks good, append to methodology
# pg_append_table(df, "methodology", db)
