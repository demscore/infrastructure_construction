### ============================================================================
### With this script we prepare the thematic dataset "gender" by filtering the 
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
  filter(grepl("gender", cb_section)|
           grepl("gender|women|woman|female|girl", name)|
           grepl("women|gender|girl|female", cb_entry)|
           grepl("complab_spin_plb_", tag_long)) %>%
  filter(!grepl("^qog_oecd_|^qog_std_cs|^vdem_cd|^vdem_coder|^qog_eureg_wide|^vdem_vp_coder|_year|_country", tag_long)) %>%
  arrange(tag_long)


# Exclude variables that were selected but do not actually relate to the topic--


exclude_gender <- c("qog_std_ts_dr_sg", "qog_std_ts_fh_pair", "qog_std_ts_rsf_sci", "qog_std_ts_undp_hdi", "qog_std_ts_vdem_egal", "qog_perceive_survey17_iweight",
                    "qog_pol_mun_scb_incmedtot", "qog_eqi_ind_17_iweight", "qog_eqi_ind_21_psweight_a", "qog_eqi_ind_21_psweight_o", "qog_eqi_ind_17_psweight", 
                    "vdem_cy_v2x_diagacc", "vdem_vparty_v2paculsup", "vdem_cy_v2peasjoc", "vdem_cy_v2peasbsoc", "vdem_cy_e_lexical_index", "vdem_cy_v2xeg_eqdr", 
                    "vdem_cy_v2lgello", "vdem_cy_v3lgello", "vdem_cy_v3stcensus", "vdem_cy_v2x_regime", "vdem_cy_v2xeg_eqaccess", "vdem_cy_v2x_freexp_altinf",
                    "vdem_cy_v2xcl_rol", "vdem_cy_v2x_cspart", "vdem_cy_v2x_egal", "vdem_cy_e_v2x_cspart_3c", "vdem_cy_v2dlconslt", "vdem_cy_v2castate",
                    "vdem_cy_v3lgqumin", "vdem_cy_v2x_clpol", "vdem_cy_v2x_clpriv", "vdem_cy_v2x_rule", "vdem_cy_v2xcl_acjst", "vdem_cy_v2xcl_prpty", "vdem_cy_v2x_freexp",
                    "vdem_cy_v2xcl_disc", "vdem_cy_v2xcl_dmove", "vdem_cy_v2xcl_slave", "vdem_cy_v2edpoledrights", "qog_ei_edi_gaarr", "qog_std_ts_gendip_mar",
                    "qog_std_ts_gendip_mas", "qog_std_ts_gendip_nar", "qog_std_ts_gendip_rec", "qog_std_ts_gendip_send", "qog_std_ts_oecd_selfempl_t1c", 
                    "qog_std_ts_who_anpreg", "qog_std_ts_wjp_cj_discr", "qog_std_ts_wjp_crsys_discr", "vdem_cy_v2elsuffrage", "vdem_cy_v2x_suffr")

cb %<>% filter(!grepl(paste(exclude_gender, collapse = "|"), tag_long))


#write_file(cb, file.path(Sys.getenv("ROOT_DIR"), "delegated_tasks", "gender.xlsx"), 
#           overwrite = FALSE)

# prepare dataframe to append to thematic_datasets_variables table--------------
df <- data.frame(
  thematic_dataset_id = 1,
  tag_long = cb$tag_long
)

# append to thematic_datasets_variables table-----------------------------------

# Remember to avoid duplicate entries if you append the whole dataframe!
pg_send_query(db, "DELETE FROM thematic_datasets_variables
                    WHERE thematic_dataset_id = 1;")

pg_append_table(df, "thematic_datasets_variables", db)