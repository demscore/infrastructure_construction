### ============================================================================
### With this script we prepare the thematic dataset "physical security" by filtering the 
### reference tables "variables" and "codebook" from our postreSQL database.
### ============================================================================

library(dplyr)
library(demutils)

# Connect to database and load relevant reference tables------------------------
db <- pg_connect()

variables <- tbl(db, "variables") %>% collect(n = Inf)
codebook <- tbl(db, "codebook") %>% collect(n = Inf)

# Merge ref tables and filter for gender terms----------------------------------

# To avoid duplicate variables, unfilter some datasets
cb <- left_join(codebook, variables, by = c("codebook_id")) %>%
  select(codebook_id, cb_entry, tag_long, name, cb_section) %>%
  filter(grepl("violence|\\bwar\\b|conflict|terrorism|death|crisis|weapons|battle|\\bcoup\\b|protest|riot|torture", cb_section) |
           grepl("violence|\\bwar\\b|conflict|terrorism|death|crisis|weapons|battle|\\bcoup\\b|protest|riot|torture", name) |
           grepl("violence|\\bwar\\b|conflict|terrorism|death|crisis|weapons|battle|\\bcoup\\b|protest|riot|torture", cb_entry) |
           grepl("violence|\\bwar\\b|conflict|terrorism|death|crisis|weapons|battle|\\bcoup\\b|protest|riot|torture", tag_long)) %>%
  filter(!grepl("^qog_oecd_|^qog_std_cs|^vdem_cd|^vdem_coder|crisis|^qog_eureg_wide|^vdem_vp_coder|_year|_country", tag_long)) %>%
  arrange(tag_long)


# Exclude variables that were selected but do not actually relate to the topic--

exclude_physical_violence <- c("cses_imd_imd3002_outgov", "cses_imd_imd3015_1", "cses_imd_imd3015_2", 
                               "cses_imd_imd3015_3", "cses_imd_imd3015_4", "cses_imd_imd5008_c", 
                               "cses_imd_imd5028", "cses_imd_imd5029_a", "cses_imd_imd5029_b", 
                               "cses_imd_imd5029_c", "cses_imd_imd5029_d", "cses_imd_imd5029_e", 
                               "cses_imd_imd5029_f", "cses_imd_imd5029_g", "cses_imd_imd5029_h", 
                               "cses_imd_imd5029_i", "hdata_fomin_foreignminister", "hdata_infocap_civreg", 
                               "qog_ei_edi_gadrei", "qog_std_ts_aii_q08", "qog_std_ts_aii_q14", 
                               "qog_std_ts_aii_q37", "qog_std_ts_aii_q39", "qog_std_ts_aii_q40", 
                               "qog_std_ts_aii_q53", "qog_std_ts_bti_ig", "qog_std_ts_bti_nird", 
                               "qog_std_ts_cbi_cobj", "qog_std_ts_cbie_index", "qog_std_ts_cbie_policy", 
                               "qog_std_ts_cbie_policyref", "qog_std_ts_wgov_minmil", "qog_std_ts_wgov_totmil", 
                               "qog_std_ts_wvs_confaf", "qog_std_ts_wvs_fight", "qog_std_ts_wvs_psarmy", 
                               "qog_std_ts_bti_nird", "vdem_cy_v2exaphogp", "vdem_cy_v2exdeathog", 
                               "vdem_cy_v2exdeathos", "complab_migpol_mipex_bc36")
cb %<>% filter(
  !grepl(paste(exclude_physical_violence, collapse = "|"), tag_long) & 
    !grepl("cab_info|vindoc", cb_section)
)


#write_file(cb, file.path(Sys.getenv("ROOT_DIR"), "physical_security.xlsx"), 
          #overwrite = TRUE)

# prepare dataframe to append to thematic_datasets_variables table--------------
df <- data.frame(
  thematic_dataset_id = 9,
  tag_long = cb$tag_long
)

# append to thematic_datasets_variables table-----------------------------------

# Remember to avoid duplicate entries if you append the whole dataframe!
pg_send_query(db, "DELETE FROM thematic_datasets_variables
                    WHERE thematic_dataset_id = 9;")

pg_append_table(df, "thematic_datasets_variables", db)
