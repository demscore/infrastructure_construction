library(dplyr)
library(demutils)

db <- pg_connect()

variables <- DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;")
codebook <- DBI::dbGetQuery(db, "SELECT * FROM codebook;") %>% select(-tag)

variables %<>% filter(grepl("^vdem_cy_|vdem_vparty_|qog_std_ts_|vdem_ert_|qog_std_ts_|qog_eureg_long_|qog_ei_|qog_pol_mun|qog_qad_bud_|qog_qad_inst_|qog_eqi_cati_long_|complab_|repdem_paged_pastr_|hdata_infocap_|ucdp_ged_|ucdp_peace_|ucdp_esd_dy_", tag_long, fixed = FALSE)) %>%
  filter(!grepl("^identifie", cb_section, fixed = FALSE)) %>%
  filter(is.na(head_var)) %>%
  select(variable_id, codebook_id, dataset_id, tag, tag_long, name, cb_section) 


variables <- left_join(variables, codebook, by = c("codebook_id")) %>%
  mutate(theme1 = "") %>%
  mutate(theme2 = "") %>%
  mutate(theme3 = "") %>%
  mutate(theme4 = "") %>%
  mutate(theme5 = "") %>%
  mutate(priority = "") %>%
  mutate(comments = "") %>%
  arrange(tag_long, dataset_id)


write_file(variables, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "refs/metadata/variables_for_thematic_grouping_empty.xlsx"),
              overwrite = FALSE)

# INSTRUCTIONS

# Go through the variables and fill columns theme1 - theme5 depending on themes 
# a variable relates to. 

# Themes can be e.g. gender, corruption, environment, social
# welfare, education, migration, poverty, violent conflict, institutions, or anything 
# else you can think of. You can get inspiration from the cb_section column in many
# cases but often the cb_sections are not very fine-grained, and sometimes they do 
# not even say anything about what the variable thematically relates to. 

# A variable can be assigned more than one theme. For now I added five columns but 
# if it should happen that you find that a variable relates to more than five themes, 
# feel free to add more theme columns (but I don't think it will happen often that a 
# variable has many themes, bc how much can a single variable measure?!).

# Come up with a short and unique tag for each theme, max five letters and ending 
# with an underscore (e.g. environment could be env_, does not need to be creative 
# just comprehensive.). Fill the theme1 - theme5 columns with no more than one tag
# each. 

# Fill the priority column with 1 if you think that a variable is vary important
# for a category. For a theme like gender That could for instance be some gender 
# equality index, whereas the number of female primary school teachers or something 
# would not be a priority variable in the gender theme (in that case leave the 
# priority column empty or fill with 0. I have no preference between empty or 0, 
# just be consistent).

# If you want to add additional information or thoughts, write it in the comments 
# column. 
