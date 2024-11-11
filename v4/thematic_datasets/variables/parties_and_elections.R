### ============================================================================
### With this script we prepare the thematic dataset "parties" by filtering the 
### reference tables "variables" and "codebook" from our postreSQL database.
### ============================================================================

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
  filter(!grepl("^qog_oecd_|^qog_std_cs|^vdem_cd|^vdem_coder|^complab_migpol|^qog_eureg_wide|^vdem_vparty_coder|ucdp_|repdem_paged_paco|repdem_paco|repdem_pastr|country", tag_long)) %>%
  filter(!is.na(tag_long))

exclude_party <- c("complab_grace_ecoaudit", "qog_ei_act_act", "qog_std_ts_van_index", "qog_std_ts_aii_cilser", "qog_std_ts_aii_q08",
                   "qog_std_ts_aii_q14", "qog_std_ts_aii_q39", "qog_std_ts_br_coup", "qog_std_ts_br_cw", "qog_std_ts_br_fcoup", "qog_std_ts_br_scoup",
                   "qog_std_ts_chisols_auttrans", "qog_std_ts_chisols_hybrid", "qog_std_ts_chisols_mil", "qog_std_ts_chisols_per", "qog_std_ts_chisols_sp",
                   "qog_std_ts_ciri_assn", "qog_std_ts_fh_pair", "qog_std_ts_fi_legprop", "qog_std_ts_fi_legprop_pd", "qog_std_ts_iiag_par", "qog_std_ts_sgi_go",
                   "goq_std_ts_wdi_brdeath", "qog_std_ts_wjp_gov_pow_ngov", "vdem_vparty_cowcode", "vdem_vparty_codingend", "vdem_vparty_project", "vdem_vparty_gapstart", 
                   "vdem_vparty_gapend", "vdem_vparty_e_regionpol", "vdem_vparty_year", "vdem_vparty_historical_date", "vdem_vparty_codingstart", "vdem_vparty_e_regiongeo",
                   "vdem_vparty_histname", "vdem_vparty_e_regionpol_6c", "vdem_cy_v2csreprss", "vdem_cy_v2cademmob", "vdem_cy_v2caacadfree", "vdem_cy_v2x_regime_amb", 
                   "vdem_cy_v2merange", "vdem_cy_v2x_neopat", "vdem_cy_v2dlencmps", "vdem_cy_v2xlg_legcon", "vdem_cy_v2csantimv", "vdem_cy_v2caviol", "vdem_cy_v2cainsaut", 
                   "vdem_cy_v2casurv", "vdem_cy_v3cllabrig", "vdem_cy_v2xnp_client", "vdem_cy_v2x_clpol", "vdem_cy_v2smonper", "vdem_cy_e_bnr_dem", "vdem_cy_e_chga_demo",
                   "vdem_cy_v2csanmvch_0", "vdem_cy_v2clrgstch_0", "vdem_cy_v2clrgwkch_0", "vdem_cy_v2medstatebroad", "vdem_cy_v2medstateprint", "vdem_cy_v2medpolstate",
                   "vdem_cy_v2medentrain", "vdem_cy_v2edscpatriot", "vdem_cy_v2edscpatriot_mode", "vdem_cy_v2edscextracurr", "vdem_cy_v2edteunionindp", 
                   "vdem_cy_v2edtehire", "vdem_cy_v2edtefire", "qoq_eqi_ind_1013_q24", "qog_eqi_ind_1013_q25", "qog_pol_mun_kfu_polcon1", "qog_std_ts_aii_rol",
                   "qog_std_ts_ciri_wopol", "qog_std_ts_cses_pc", "qog_std_ts_ht_regtype", "qog_std_ts_icrg_qog", "qog_std_ts_sgi_qdrlc", "qog_perceive_survey17_q6",
                   "qog_pol_mun_kfu_polcon2", "qog_eqi_ind_17_q26a1", "qog_eqi_ind_17_q26a2", "qog_eqi_ind_21_party_w", "qog_eqi_ind_21_party_w_truc",
                   "qog_eqi_ind_17_q25", "qog_eqi_ind_17_q26a3", "qog_eqi_ind_17_q26a4", "qog_eqi_ind_17_q26b1", "qog_eqi_ind_17_q26b2", "qog_eqi_ind_17_q26b3",
                   "qog_eqi_ind_17_q26b4", "qog_eqi_ind_21_q21", "vdem_cy_v2x_veracc", "vdem_cy_v2regpower", "vdem_cy_v2regimpoppgroup", "vdem_cy_v2regoppgroupssize", 
                   "vdem_cy_v2x_horacc", "vdem_cy_v2regimpgroup", "vdem_cy_v2regopploc", "vdem_cy_v2regproreg", "vdem_cy_v2regantireg", "vdem_cy_v2dlcommon",
                   "vdem_cy_v2dlcountr", "vdem_cy_v2dlconslt", "vdem_cy_v2cseeorgs", "vdem_cy_v2caautmob", "vdem_cy_v2castate", "vdem_cy_v2catrauni", "vdem_cy_v2canonpol",
                   "vdem_cy_v2x_feduni", "vdem_cy_v2exrmhsol_0", "vdem_cy_v2regoppgroups_0", "vdem_cy_v2regoppgroupsact_0")

#write_file(cb, file.path(Sys.getenv("ROOT_DIR"), "delegated_tasks", "parties.xlsx"), 
#           overwrite = FALSE)

# Exclude variables that were selected but do not actually relate to the topic--

cb %<>% filter(!grepl(paste(exclude_party, collapse = "|"), tag_long)) %>% arrange(tag_long)

# prepare dataframe to append to thematic_datasets_variables table--------------
df <- data.frame(
  thematic_dataset_id = 5,
  tag_long = cb$tag_long
)

# append to thematic_datasets_variables table-----------------------------------

# Remember to avoid duplicate entried if you append the whole dataframe!
pg_send_query(db, "DELETE FROM thematic_datasets_variables
                  WHERE thematic_dataset_id = 5;")

pg_append_table(df, "thematic_datasets_variables", db)
