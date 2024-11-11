### ============================================================================
### With this script we prepare the thematic dataset "unemployment" by filtering the 
### reference tables "variables" and "codebook" from our postreSQL database.
### ============================================================================

#Title: Unempolyment, Out-of_Work Benefits and the Labour Market

library(dplyr)
library(demutils)

# Connect to database and load relevant reference tables------------------------
db <- pg_connect()

variables <- DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;")
codebook <- DBI::dbGetQuery(db, "SELECT * FROM codebook;")

# Merge ref tables and filter for gender terms----------------------------------

# To avoid duplicate vriables, unfilter some datasets
cb <- left_join(codebook, variables, by = c("codebook_id")) %>%
  select(codebook_id, cb_entry, tag_long, name, cb_section) %>%
  filter(grepl("unemployment|labour_market", cb_section)|
           grepl("unempoly.*", name)|
           grepl("unempolyment|unempoyed|Unemployment|Unemployed", cb_entry)|
           grepl("complab_spin_outwb", tag_long)) %>%
  filter(!grepl("year$|country$|country_code|country_nr|iso2$|iso3$|^qog_std_cs|^qog_oecd_ts|full_name$|^repdem|^vdem_vparty|^vdem_vp|^vdem_coder", tag_long)) %>%
  filter(!is.na(tag_long)) %>%
  arrange(tag_long)

# prepare dataframe to append to thematic_datasets_variables table--------------
df <- data.frame(
  thematic_dataset_id = 6,
  tag_long = cb$tag_long
)

# Remember to avoid duplicate entried if you append the whole dataframe!
pg_send_query(db, "DELETE FROM thematic_datasets_variables
                    WHERE thematic_dataset_id = 6;")

pg_append_table(df, "thematic_datasets_variables", db)