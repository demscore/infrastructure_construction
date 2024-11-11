### ============================================================================
### With this script we prepare the thematic dataset "migration" by filtering the 
### reference tables "variables" and "codebook" from our postreSQL database.
### ============================================================================

library(dplyr)
library(demutils)

# Connect to database and load relevant reference tables------------------------
db <- pg_connect()

variables <- tbl(db, "variables") %>% collect(n = Inf) %>% filter(active)
codebook <- tbl(db, "codebook") %>% collect(n = Inf)

# Merge ref tables and filter for gender terms----------------------------------

# To avoid duplicate vriables, unfilter some datasets
cb <- left_join(codebook, variables, by = c("codebook_id")) %>%
  select(codebook_id, cb_entry, tag_long, name, cb_section) %>%
  filter(grepl("migration", cb_section)|
           grepl("migrat*|migrant|^immigr|^emigr", name)|
           grepl("migrat*|migrant|^immigr|^emigr", cb_entry)|
           grepl("complab_migpol", tag_long)) %>%
  filter(!grepl("year$|country$|iso2$|iso3$|^qog_std_cs|^qog_oecd_ts|full_name$|^repdem|^vdem_vparty|^vdem_vp|^vdem_coder", tag_long)) %>%
  filter(!is.na(tag_long)) %>%
  arrange(tag_long)

# prepare dataframe to append to thematic_datasets_variables table--------------
df <- data.frame(
  thematic_dataset_id = 3,
  tag_long = cb$tag_long
)

# Remember to avoid duplicate entried if you append the whole dataframe!
pg_send_query(db, "DELETE FROM thematic_datasets_variables
                    WHERE thematic_dataset_id = 3;")

pg_append_table(df, "thematic_datasets_variables", db)
