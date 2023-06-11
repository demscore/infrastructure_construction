library(dplyr)
library(demutils)

db <- pg_connect()

# Lost observations when retrieving V-Dem Country Year variables in other Country-Year output units.

# An anti join returns the rows of the first table where it cannot find a match in the second table
  

unit_table_start <- read_unit_table("u_vdem_country_year")
unit_table_end <- read_unit_table("u_ucdp_ged_country_year")
  
# Change codes for V-Dem CoW to UCDP GW 
unit_table_start %<>% 
  mutate(
    u_vdem_country_year_cowcode = case_when(
      u_vdem_country_year_country == "Germany" & u_vdem_country_year_year >= 1991 ~ 260L ,
      u_vdem_country_year_country == "Yemen" & u_vdem_country_year_year >= 1990 ~ 678L ,
      TRUE ~ u_vdem_country_year_cowcode
    ))
  
df <- anti_join(unit_table_start, unit_table_end, by = c("u_vdem_country_year_cowcode" = "u_ucdp_ged_country_year_country_id_cy",
                                                           "u_vdem_country_year_year" = "u_ucdp_ged_country_year_year_cy"))
  
write_file(df, file.path(Sys.getenv("ROOT_DIR"),
             "merge_scores/lost_obs_vdem_cy_to_ucdp_ged_cy.csv"),
             overwrite = TRUE)

df2 <- anti_join(unit_table_end, unit_table_start, by = c("u_ucdp_ged_country_year_country_id_cy" = "u_vdem_country_year_cowcode",
                                                         "u_ucdp_ged_country_year_year_cy" = "u_vdem_country_year_year"))

write_file(df, file.path(Sys.getenv("ROOT_DIR"),
                         "merge_scores/lost_obs_ucdp_ged_cy_to_vdem_cy.csv"),
           overwrite = TRUE)