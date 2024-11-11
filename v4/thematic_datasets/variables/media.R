### ============================================================================
### With this script we prepare the thematic dataset "media" by filtering the 
### reference tables "variables" and "codebook" from our postreSQL database.
### ============================================================================

library(dplyr)
library(demutils)

# Connect to database and load relevant reference tables------------------------
db <- pg_connect()
variables <- DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;")
codebook <- DBI::dbGetQuery(db, "SELECT * FROM codebook;")

# Merge ref tables and filter for gender terms----------------------------------

# To avoid duplicate variables, unfilter some datasets
# Key words that didn't add anything: advertisement, whistleblower, television, journalism

cb <- left_join(codebook, variables, by = c("codebook_id")) %>%
  select(codebook_id, cb_entry, tag_long, name, cb_section) %>%
  filter(grepl("\\bmedia\\b", cb_section) |
           grepl("\\bmedia\\b|online|^press|radio|censor|^digital|journal|news|internet|telephone|communication|mobile", name) |
           grepl("\\bmedia\\b|online|^press|radio|censor|^digital|journal|news|internet|telephone|communication|mobile",cb_entry))%>%
  filter(!grepl("^qog_oecd_|^qog_std_cs|^vdem_cd|^vdem_coder|^qog_eureg_wide|^vdem_vp_coder|_year|_country|^qog_eureg_long_eu_edatt_ed|^qog_eureg_long_eu_igs_|^vdem_cy_v3|^vdem_cy_e_" , tag_long)) %>%
  arrange(tag_long)


# Exclude variables that were selected but do not actually relate to the topic--

exclude_media <- c("qog_eureg_long_eu_epred12","qog_eureg_long_eu_epred58","qog_std_ts_aii_q09",
                   "qog_std_ts_aii_q22", "qog_std_ts_aii_q29", "qog_std_ts_aii_q30", "qog_std_ts_aii_q42",
                   "qog_std_ts_aii_q43","qog_std_ts_aii_q45", "qog_std_ts_aii_q47", "qog_std_ts_aii_q49",
                   "qog_std_ts_aii_q51", "qog_std_ts_aii_q56", "qog_std_ts_aii_q57","vdem_cy_v2cafres", 
                   "qog_eqi_ind_21_length", "qog_std_ts_vdem_academ",
                   "complab_migpol_imisem_egrantinstitution_consulates_online", "qog_ei_edi_gepd",
                   "qog_ei_edi_gicm", "qog_ei_edi_gip", "qog_ei_edi_gpajad", "qog_ei_wdi_tpa", 
                   "qog_std_ts_egov_egov", "qog_std_ts_egov_epar", "qog_std_ts_egov_osi", "qog_ei_edi_gppa",
                   "qog_std_ts_aii_cilser", "qog_std_ts_aii_rol", "qog_std_ts_bti_ffe", "qog_std_ts_sgi_go", 
                   "qog_std_ts_sgi_qdrlc", "qog_std_ts_vdem_polyarchy", "vdem_cy_v2caautmob", "vdem_cy_v2cacritic",
                   "vdem_cy_v2jupoatck", "vdem_cy_v2x_polyarchy", "vdem_vparty_v2paplur", 
                   "complab_migpol_imisem_egrantinstitution_consulates_mobile", "qog_ei_issp_20am",
                   "qog_ei_issp_20ap", "qog_eqi_ind_1013_typetel", "qog_eqi_ind_17_typetel", 
                   "qog_eqi_ind_21_typeinterview", "qog_eqi_ind_21_typetel", "qog_eureg_long_eu_matdep_pc",
                   "qog_eureg_long_eu_matdep_pc", "qog_eureg_long_eu_troad_rl", "qog_eureg_long_eu_vs_spe", 
                   "qog_perceive_survey17_typetel_", "qog_pol_mun_kol_resp2", "qog_std_ts_aii_q26", 
                   "qog_std_ts_wdi_hwf", "qog_std_ts_wdi_hwfr", "qog_std_ts_wdi_hwfu", "vdem_ert_reg_type",
                   "vdem_ert_row_regch_censored")

cb %<>% filter(!grepl(paste(exclude_media, collapse = "|"), tag_long))


#write_file(cb, file.path(Sys.getenv("ROOT_DIR"), "delegated_tasks", "gender.xlsx"), 
#           overwrite = FALSE)

# prepare dataframe to append to thematic_datasets_variables table--------------
df <- data.frame(
  thematic_dataset_id = 7,
  tag_long = cb$tag_long
)

# append to thematic_datasets_variables table-----------------------------------

# Remember to avoid duplicate entries if you append the whole dataframe!
pg_send_query(db, "DELETE FROM thematic_datasets_variables
              WHERE thematic_dataset_id = 7;")

pg_append_table(df, "thematic_datasets_variables", db)