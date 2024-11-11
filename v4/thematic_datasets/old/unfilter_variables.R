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
  filter(grepl("party|parties|election|vote", cb_section)|
           grepl("party|parties", name)|
           grepl("party|parties", cb_entry)|
           grepl("vdem_vparty|repdem", tag_long)) %>%
  filter(!grepl("^qog_oecd_|^qog_std_cs|^vdem_cd|^vdem_coder|^qog_eureg_wide|^vdem_vparty_coder|ucdp_|repdem_paged_paco|country", tag_long)) %>%
  filter(!is.na(tag_long))

# Create vector with variable we want to exclude--------------------------------

exclude_env <- c()

# Exclude variables that were selected but do not actually relate to the topic--

cb %<>% filter(!grepl(paste(exclude_env, collapse = "|"), tag_long))





exclude <- c("^qog_oecd_", "^qog_std_cs", "^vdem_cd", "^vdem_coder", "^qog_eureg_wide",
             "^vdem_vparty_coder", "ucdp_", "repdem_paged_paco", "country")