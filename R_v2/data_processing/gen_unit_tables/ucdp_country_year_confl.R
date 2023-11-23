library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_onset_inter_v1 <- read_datasets("ucdp_onset_inter_v1", db)
ucdp_onset_intra_v1 <- read_datasets("ucdp_onset_intra_v1", db)
ucdp_onset_inter_multiple <- read_datasets("ucdp_onset_inter_multiple", db)
ucdp_onset_intra_multiple <- read_datasets("ucdp_onset_intra_multiple", db)

# Create unit table
u_ucdp_country_year_confl <- 
  bind_rows(select(ucdp_onset_inter_v1, 
                   u_ucdp_country_year_confl_gwno_a,
                   u_ucdp_country_year_confl_name, 
                   u_ucdp_country_year_confl_year,
                   u_ucdp_country_year_confl_conflict_id),
            select(ucdp_onset_intra_v1, 
                   u_ucdp_country_year_confl_gwno_a,
                   u_ucdp_country_year_confl_name, 
                   u_ucdp_country_year_confl_year,
                   u_ucdp_country_year_confl_conflict_id),
            select(ucdp_onset_intra_multiple, 
                   u_ucdp_country_year_confl_gwno_a,
                   u_ucdp_country_year_confl_name, 
                   u_ucdp_country_year_confl_year,
                   u_ucdp_country_year_confl_conflict_id),
            select(ucdp_onset_intra_multiple, 
                   u_ucdp_country_year_confl_gwno_a,
                   u_ucdp_country_year_confl_name, 
                   u_ucdp_country_year_confl_year,
                   u_ucdp_country_year_confl_conflict_id)) %>%
  distinct(.) %>% 
  arrange(u_ucdp_country_year_confl_name, u_ucdp_country_year_confl_year)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_ucdp_country_year_confl)))

write_unit_table(u_ucdp_country_year_confl, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_ucdp_country_year_confl.rds"),
                 tag = "u_ucdp_country_year_confl")