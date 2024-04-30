### ============================================================================
### With this script we prepare the thematic dataset "environment" by filtering the 
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
  filter(grepl("environment", cb_section)|
           grepl("^qog_ei|^complab_grace", tag_long)|
           grepl("ocean|forest|earth|air quality|agriculture|rural po|urban po|rural area|urban area", cb_entry)) %>%
  filter(!grepl("^qog_oecd_|^qog_std_cs|^vdem_cd|^vdem_coder|^qog_eureg_wide|^ucdp_extsup|_cname|_ccode|_year", tag_long)) %>%
  distinct(tag_long, .keep_all = TRUE) %>% arrange(tag_long)

exclude_env <- c("qog_std_ts_ht_region", "qog_std_ts_wdi_acelr", "qog_std_ts_wdi_acelu", "qog_std_ts_wdi_area", "qog_std_ts_wdi_areabelow", "qog_std_ts_wdi_birthregr",
                 "qog_std_ts_wdi_birthregu", "qog_std_ts_wdi_hwfr", "qog_std_ts_wdi_hwfu", "qog_std_ts_wdi_idpdis", "qog_std_ts_wdi_poprul", "qog_std_ts_wdi_poprulgr",
                 "qog_std_ts_wdi_popurb", "qog_std_ts_wdi_popurbagr", "qog_std_ts_who_dwrur", "qog_std_ts_who_dwurb", "qog_perceive_survey17_d6", "qog_eureg_long_eu_d3area_lat",
                 "qog_eqi_ind_17_d6", "qog_eqi_ind_21_d7", "qog_eqi_ind_1013_population", "vdem_cy_v2clgeocl", "vdem_cy_v2peasbegeo", "vdem_cy_v2regopploc", 
                 "vdem_cy_v2pepwrgeo", "vdem_cy_v2peasjgeo", "vdem_cy_v3elmalalc", "vdem_cy_e_miurbpop", "vdem_cy_v3peminwagerestr_0", "qog_eqi_ind_1013_d6",
                 "qog_str_ts_oecd_tiva_inter_t1a",
                 "qog_std_ts_oecd_valaddac_t1a", "qog_std_ts_wdi_empagr", "qog_std_ts_wdi_empagrf", "qog_std_ts_wdi_empagrm", "qog_std_ts_wdi_gdpagr", 
                 "qog_eureg_long_eu_emtk_ab_f", "qog_eureg_long_emtk_ab_m", "qog_eureg_long_eu_emtk_ab_t", "qog_eureg_long_eu_emp_a")

cb %<>% filter(!grepl(paste(exclude_env, collapse = "|"), tag_long))

#write_file(cb, file.path(Sys.getenv("ROOT_DIR"), "delegated_tasks", "environment.xlsx"), 
#           overwrite = FALSE)

# prepare dataframe to append to thematic_datasets_variables table--------------
df <- data.frame(
  # add an entry for the new id to themetic_datasets
  thematic_dataset_id = 4,
  tag_long = cb$tag_long
)

# append to thematic_datasets_variables table-----------------------------------

# Remember to avoid duplicate entried if you append the whole dataframe!
pg_send_query(db, "DELETE FROM thematic_datasets_variables
                    WHERE thematic_dataset_id = 4;")

pg_append_table(df, "thematic_datasets_variables", db)