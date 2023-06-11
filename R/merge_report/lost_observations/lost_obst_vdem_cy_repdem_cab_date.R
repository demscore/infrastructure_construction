library(dplyr)
library(demutils)

db <- pg_connect()

# Lost observations when retrieving V-Dem Country Year variables in other Country-Year output units.

# An anti join returns the rows of the first table where it cannot find a match in the second table
unit_table_start <- read_unit_table("u_vdem_country_year")
unit_table_end <- read_unit_table("u_repdem_cabinet_date")

unit_table_start %<>% 
  dplyr::mutate(
    u_vdem_country_year_country = case_when(
      u_vdem_country_year_country == "Netherlands" ~ "the Netherlands",
      u_vdem_country_year_country == "Czechia" ~ "Czech Republic",
      TRUE ~ u_vdem_country_year_country
    ))

df <- anti_join(unit_table_start, unit_table_end, by = c("u_vdem_country_year_country" = "u_repdem_cabinet_date_country",
                                                         "u_vdem_country_year_year" = "u_repdem_cabinet_date_out_year"))
write_file(df, file.path(Sys.getenv("ROOT_DIR"),
                         "merge_scores/lost_obs_vdem_cy_to_repdem_cab.csv"),
           overwrite = TRUE)

df2 <- anti_join(unit_table_end, unit_table_start, by = c("u_repdem_cabinet_date_country" = "u_vdem_country_year_country",
                                                         "u_repdem_cabinet_date_out_year" = "u_vdem_country_year_year"))

write_file(df, file.path(Sys.getenv("ROOT_DIR"),
                         "merge_scores/lost_obs_repdem_cab_date_to_vdem_cy.csv"),
           overwrite = TRUE)



27555 - 26961


unit_table_end %<>% distinct(u_repdem_cabinet_date_country, u_repdem_cabinet_date_out_year) 
dups <- duplicates(unit_table_end, c("u_repdem_cabinet_date_country", "u_repdem_cabinet_date_out_year")) %>% distinct
