### ============================================================================
### With this script we prepare the thematic dataset "corruption" by filtering the 
### reference tables "variables" and "codebook" from our postreSQL database.
### ============================================================================

library(dplyr)
library(demutils)

# Connect to database and load relevant reference tables------------------------
db <- pg_connect()

variables <- tbl(db, "variables") %>% collect(n = Inf)
codebook <- tbl(db, "codebook") %>% collect(n = Inf)

# Merge ref tables and filter for gender terms----------------------------------

# To avoid duplicate vriables, unfilter some datasets
cb <- left_join(codebook, variables, by = c("codebook_id")) %>%
  select(codebook_id, cb_entry, tag_long, name, cb_section) %>%
  filter(grepl("corruption|bribery|accountability|integrity|transparency|fraud|embezzlement|nepotism|\\bvote buying\\b|clientelism|patronage", cb_section)|
           grepl("corruption|bribery|accountability|integrity|transparency|fraud|embezzlement|nepotism|\\bvote buying\\b|clientelism|patronage", name)|
           grepl("corruption|bribery|accountability|integrity|transparency|fraud|embezzlement|nepotism|\\bvote buying\\b|clientelism|patronage", cb_entry)) %>%
  filter(!grepl("^qog_oecd_|^qog_std_cs|^vdem_cd|^vdem_coder|^qog_eureg_wide|^vdem_vp_coder|_year|_country", tag_long)) %>%
  arrange(tag_long)

# Exclude variables that were selected but do not actually relate to the topic--


exclude_corruption <- c("complab_migpol_gc_cy_l09_bin", 
                        "complab_migpol_gc_cy_l09_cat", 
                        "complab_migpol_gc_loss_l09_category",
                        "complab_migpol_gc_loss_l09_specification",
                        "complab_migpol_imisem_igrantsoc_family_rejectionfraud_agricultural", 
                        "complab_migpol_imisem_igrantsoc_family_rejectionfraud_coethnics", 
                        "complab_migpol_imisem_igrantsoc_family_rejectionfraud_domestic", 
                        "complab_migpol_imisem_igrantsoc_family_rejectionfraud_medical", 
                        "complab_migpol_imisem_igrantsoc_family_rejectionfraud_permanent", 
                        "complab_migpol_imisem_igrantsoc_family_rejectionfraud_refugees", 
                        "complab_migpol_imisem_igrantsoc_family_rejectionfraud_seekers", 
                        "complab_migpol_mipex_bc35", 
                        "cses_imd_imd5049", 
                        "vdem_cy_e_v2x_clphy_3c")

cb %<>% filter(!grepl(paste(exclude_corruption, collapse = "|"), tag_long))


#write_file(cb, file.path(Sys.getenv("ROOT_DIR"), "corruption.xlsx"), 
     # overwrite = TRUE)

# prepare dataframe to append to thematic_datasets_variables table--------------
df <- data.frame(
  thematic_dataset_id = 2,
  tag_long = cb$tag_long
)

# append to thematic_datasets_variables table-----------------------------------

# Remember to avoid duplicate entries if you append the whole dataframe!
pg_send_query(db, "DELETE FROM thematic_datasets_variables
                    WHERE thematic_dataset_id = 2;")

pg_append_table(df, "thematic_datasets_variables", db)