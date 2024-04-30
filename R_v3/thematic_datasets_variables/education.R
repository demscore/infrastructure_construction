### With this script we prepare the thematic dataset "education" by filtering the 
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
  filter(grepl("education", cb_section)|
           grepl("education|school|schooling|literacy|univeristy|teach|academi", name)|
           grepl("education|school|schooling|literacy|univeristy|teach|academi", cb_entry))%>%
  filter(!grepl("^qog_oecd_|^qog_std_cs|^vdem_cd|^vdem_coder|^qog_eureg_wide|^vdem_vp_coder|_year|_country", tag_long)) %>%
  arrange(tag_long)


# Exclude variables that were selected but do not actually relate to the topic--


exclude_education <- c("complab_migpol_demig_policy_pol_tool", "complab_migpol_demig_policy_target_group", 
                       "complab_migpol_mipex_overall_wo_health_educ",
                       "qog_ei_edi_jp", "qog_ei_ohi_hab", "qog_ei_ohi_tour",
                       "qog_eqi_ind_17_psweight", "qog_eqi_ind_21_psweight_a", "qog_eqi_ind_21_psweight_o",
                       "qog_eureg_long_eu_emp_oq", "qog_eureg_long_eu_emtk_ab_f", "qog_eureg_long_eu_emtk_ab_m",
                       "qog_eureg_long_eu_emtk_ab_t", "qog_eureg_long_eu_emtk_c_f", "qog_eureg_long_eu_emtk_c_m",
                       "qog_eureg_long_eu_emtk_c_t", "qog_eureg_long_eu_emtk_chtc_f", "qog_eureg_long_eu_emtk_chtc_m",
                       "qog_eureg_long_eu_emtk_chtc_t", "qog_eureg_long_eu_emtk_df_f", "qog_eureg_long_eu_emtk_df_m",
                       "qog_eureg_long_eu_emtk_df_t", "qog_eureg_long_eu_emtk_gu_f", "qog_eureg_long_eu_emtk_gu_m",
                       "qog_eureg_long_eu_emtk_gu_t", "qog_eureg_long_eu_emtk_htc_f", "qog_eureg_long_eu_emtk_htc_m",
                       "qog_eureg_long_eu_emtk_htc_t", "qog_eureg_long_eu_emtk_j_f", "qog_eureg_long_eu_emtk_j_m",
                       "qog_eureg_long_eu_emtk_j_t", "qog_eureg_long_eu_emtk_k_f", "qog_eureg_long_eu_emtk_k_m",
                       "qog_eureg_long_eu_emtk_k_t", "qog_eureg_long_eu_emtk_kis_f", "qog_eureg_long_eu_emtk_kis_m",
                       "qog_eureg_long_eu_emtk_kis_t", "qog_eureg_long_eu_emtk_kl_f", "qog_eureg_long_eu_emtk_kl_m",
                       "qog_eureg_long_eu_emtk_kl_t", "qog_eureg_long_eu_emtk_m_f", "qog_eureg_long_eu_emtk_m_m",
                       "qog_eureg_long_eu_emtk_m_t", "qog_eureg_long_eu_emtk_n_f", "qog_eureg_long_eu_emtk_n_m",
                       "qog_eureg_long_eu_emtk_n_t", "qog_eureg_long_eu_emtk_ou_f", "qog_eureg_long_eu_emtk_ou_m",
                       "qog_eureg_long_eu_emtk_ou_t", "qog_eureg_long_eu_emtk_q_f", "qog_eureg_long_eu_emtk_q_m",
                       "qog_eureg_long_eu_emtk_q_t", "qog_eureg_long_eu_emtk_r_f", "qog_eureg_long_eu_emtk_r_m",
                       "qog_eureg_long_eu_emtk_r_t", "qog_eureg_long_eu_emtk_s_f", "qog_eureg_long_eu_emtk_s_m",
                       "qog_eureg_long_eu_emtk_s_t", "qog_eureg_long_eu_hea_dent", "qog_eureg_long_eu_hea_mdoc",
                       "qog_eureg_long_eu_hea_nurs", "qog_eureg_long_eu_hea_pharm", "qog_eureg_long_eu_hea_phys",
                       "qog_qad_inst_agency_permit", "qog_std_ts_aii_q03", "qog_std_ts_aii_q20",
                       "qog_std_ts_aii_q59", "qog_std_ts_egov_osi", "qog_std_ts_mibu_ibu", "qog_std_ts_sgi_pp",
                       "vdem_cy_v2ellocgov", "vdem_cy_v2elreggov", "vdem_cy_v2elrsthog",
                       "vdem_cy_v2elrsthos", "vdem_cy_v2elrstrct", "vdem_cy_v2pepwrort", "vdem_cy_v3ellocgov",
                       "vdem_cy_v3elreggov", "vdem_cy_v3elrstrlc_0", "vdem_cy_v3elrstrpr_0", "vdem_cy_v3elrstrup_0",
                       "vdem_cy_v3elvstrpr_0", "vdem_cy_v3elvstruc_0","vdem_cy_v2elsuffrage", "vdem_cy_v2x_clpol", 
                       "vdem_cy_v2x_diagacc","vdem_cy_v2x_suffr", "vdem_cy_v2xeg_eqdr", "vdem_vparty_v2paenname", 
                       "vdem_vparty_v2paid", "vdem_vparty_v2paorname","vdem_vparty_v2pashname","complab_migpol_gc_cy_a07_bin", 
                       "complab_migpol_gc_cy_a07_cat", "qog_std_ts_dr_sg",
                       "vdem_cy_v2dlunivl", "qog_std_ts_gii_gii", "complab_migpol_imisem_icit_socialization_general",
                       "complab_migpol_imisem_icit_ordinary_civil", "qog_std_ts_wdi_svapgdp", "qog_std_ts_wdi_svapg",
                       "qog_std_ts_wdi_sva2015")

cb %<>% filter(!grepl(paste(exclude_education, collapse = "|"), tag_long))


#write_file(cb, file.path(Sys.getenv("ROOT_DIR"), "delegated_tasks", "gender.xlsx"), 
#           overwrite = FALSE)

# prepare dataframe to append to thematic_datasets_variables table--------------
df <- data.frame(
  thematic_dataset_id = 8,
  tag_long = cb$tag_long
)

# append to thematic_datasets_variables table-----------------------------------

pg_send_query(db, "DELETE FROM thematic_datasets_variables
WHERE thematic_dataset_id = 8;")

pg_append_table(df, "thematic_datasets_variables", db)
