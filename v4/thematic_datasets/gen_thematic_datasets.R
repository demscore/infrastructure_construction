#!/usr/bin/env Rscript

suppressMessages(library(dplyr))
suppressMessages(library(demutils))

db <- pg_connect()

ll <- list.files("~/proj/demscore/data_processing/modules/thematic_datasets_variables", 
                 pattern = "*.R$", full.names = TRUE)
THEMES <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets;") %>% pull(tag)
OUTPUT_UNIT <- "u_demscore_country_year"
VERSION_NR <- Sys.getenv("DEMSCORE_RELEASE")
DIR <- file.path(Sys.getenv("ROOT_DIR"), paste0("unit_data/", OUTPUT_UNIT))
OUT_DIR <- file.path(Sys.getenv("ROOT_DIR"), "themes", VERSION_NR)
FILES <- list.files(DIR) %>%
  tools::file_path_sans_ext(.)

#variables <- DBI::dbGetQuery(db, "SELECT * FROM variables;")
#thematic_datasets <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets;")
#thematic_datasets_variables <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets_variables;")


for (THEME in THEMES) {
  # THEME <- "gender"
  # Filter variables
  
  print(THEME)
  
  variables <- DBI::dbGetQuery(db, "SELECT * FROM variables;")
  thematic_datasets <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets;")
  thematic_datasets_variables <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets_variables;")
   
  
  thematic_datasets %<>% dplyr::filter(tag == THEME)
  thematic_datasets_variables %<>% 
    dplyr::filter(thematic_dataset_id %in% 
                    thematic_datasets$thematic_dataset_id)
  variables %<>% 
    dplyr::filter(tag_long %in% 
                    thematic_datasets_variables$tag_long) %>%
    filter(tag_long %in% FILES)
  
  # Parse docopt string arguments and options
  args <- list(help = FALSE,
               include_unit_cols = TRUE, 
               file_format = "R", 
               output_unit_tag = OUTPUT_UNIT,
               outfile = file.path(OUT_DIR, paste0(THEME, "_dataset.rds")),
               select_all_rows = TRUE,
               country = c("Norway"),
               min_year = 1750,
               max_year = 2023,
               variables = variables$tag_long,
               conflict_location = c("India"),
               region = c("Albania"),
               min_date = c("1919-01-07"),
               max_date = c("1997-01-20"))
  
  # Functions
  generate_data(args, POSTGRES_TABLES_DIR, UNIT_DATA_DIR, LOCAL,
                UNIT_TABLE_DIR, prep = TRUE)
  
  df <- read_file(file.path(OUT_DIR, paste0(THEME, "_dataset.rds")))
  write_file(df, file.path(OUT_DIR, paste0(THEME, "_dataset.csv")))
  write_file(df, file.path(OUT_DIR, paste0(THEME, "_dataset.dta")))

  
  print(THEME)
  info("Generate thematic codebook...")
  
  args$thematic <- THEME
  args$outfile <- file.path(OUT_DIR, paste0(THEME, "_codebook.pdf"))
  create_codebook(args, REF_STATIC_DIR, POSTGRES_TABLES_DIR, 
                  LOCAL, prep = FALSE)
  
}


### ============================================================================
### Migration Policy Change
### ============================================================================
THEME <- "migration"

ll <- list.files("~/proj/demscore/data_processing/modules/thematic_datasets_variables", 
                 pattern = "*.R$", full.names = TRUE)
THEMES <- ll %>% basename %>% tools::file_path_sans_ext(.)
OUTPUT_UNIT <- "u_complab_country_year_change"
VERSION_NR <- Sys.getenv("DEMSCORE_RELEASE")
DIR <- file.path(Sys.getenv("ROOT_DIR"), paste0("unit_data/", OUTPUT_UNIT))
OUT_DIR <- file.path(Sys.getenv("ROOT_DIR"), "themes", VERSION_NR)
FILES <- list.files(DIR) %>%
  tools::file_path_sans_ext(.)

variables <- DBI::dbGetQuery(db, "SELECT * FROM variables;")
thematic_datasets <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets;")
thematic_datasets_variables <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets_variables;")


thematic_datasets %<>% dplyr::filter(tag == THEME)
thematic_datasets_variables %<>% 
  dplyr::filter(thematic_dataset_id %in% 
                  thematic_datasets$thematic_dataset_id)
variables %<>% 
  dplyr::filter(tag_long %in% 
                  thematic_datasets_variables$tag_long) %>%
  filter(tag_long %in% FILES)

args <- list(help = FALSE,
             include_unit_cols = TRUE, 
             file_format = "R", 
             output_unit_tag = OUTPUT_UNIT,
             outfile = file.path(OUT_DIR, paste0(THEME, "_dataset_change.rds")),
             select_all_rows = TRUE,
             country = c("Norway"),
             min_year = 1721,
             max_year = 2020,
             variables = variables$tag_long,
             conflict_location = c("India"),
             region = c("Albania"),
             min_date = c("1919-01-07"),
             max_date = c("1997-01-20"))

generate_data(args, POSTGRES_TABLES_DIR, UNIT_DATA_DIR, LOCAL,
              UNIT_TABLE_DIR, prep = TRUE)


df <- read_file(file.path(OUT_DIR, paste0(THEME, "_dataset_change.rds")))
write_file(df, file.path(OUT_DIR, paste0(THEME, "_dataset_change.csv")))
write_file(df, file.path(OUT_DIR, paste0(THEME, "_dataset_change.dta")))

print(THEME)
info("Generate thematic codebook...")

args$thematic <- THEME
args$outfile <- file.path(OUT_DIR, paste0(THEME, "_codebook_change.pdf"))
create_codebook(args, REF_STATIC_DIR, POSTGRES_TABLES_DIR, 
                LOCAL, prep = FALSE)


### ============================================================================
### Repdem Cabinet Date
### ============================================================================
THEME <- "parties_and_elections"

ll <- list.files("~/proj/demscore/data_processing/modules/thematic_datasets_variables", 
                 pattern = "*.R$", full.names = TRUE)
THEMES <- ll %>% basename %>% tools::file_path_sans_ext(.)
OUTPUT_UNIT <- "u_repdem_cabinet_date"
VERSION_NR <- Sys.getenv("DEMSCORE_RELEASE")
DIR <- file.path(Sys.getenv("ROOT_DIR"), paste0("unit_data/", OUTPUT_UNIT))
OUT_DIR <- file.path(Sys.getenv("ROOT_DIR"), "themes", VERSION_NR)
FILES <- list.files(DIR) %>%
  tools::file_path_sans_ext(.)

variables <- DBI::dbGetQuery(db, "SELECT * FROM variables;")
thematic_datasets <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets;")
thematic_datasets_variables <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets_variables;")


thematic_datasets %<>% dplyr::filter(tag == THEME)
thematic_datasets_variables %<>% 
  dplyr::filter(thematic_dataset_id %in% 
                  thematic_datasets$thematic_dataset_id)
variables %<>% 
  dplyr::filter(tag_long %in% 
                  thematic_datasets_variables$tag_long) %>%
  filter(tag_long %in% FILES)

args <- list(help = FALSE,
             include_unit_cols = TRUE, 
             file_format = "R", 
             output_unit_tag = OUTPUT_UNIT,
             outfile = file.path(OUT_DIR, paste0(THEME, "_dataset_cabinet_date.rds")),
             select_all_rows = TRUE,
             country = c("Norway"),
             min_year = 1944,
             max_year = 2023,
             variables = variables$tag_long,
             conflict_location = c("India"),
             region = c("Albania"),
             min_date = c("1919-01-07"),
             max_date = c("1997-01-20"))

generate_data(args, POSTGRES_TABLES_DIR, UNIT_DATA_DIR, LOCAL,
              UNIT_TABLE_DIR, prep = TRUE)


df <- read_file(file.path(OUT_DIR, paste0(THEME, "_dataset_cabinet_date.rds")))
write_file(df, file.path(OUT_DIR, paste0(THEME, "_dataset_cabinet_date.csv")))
write_file(df, file.path(OUT_DIR, paste0(THEME, "_dataset_cabinet_date.dta")))


print(THEME)
info("Generate thematic codebook...")

args$thematic <- THEME
args$outfile <- file.path(OUT_DIR, paste0(THEME, "_codebook_cabinet_date.pdf"))
create_codebook(args, REF_STATIC_DIR, POSTGRES_TABLES_DIR, 
                LOCAL, prep = FALSE)

### ============================================================================
### V-Dem Party-Country-Year
### ============================================================================
THEME <- "parties_and_elections"

ll <- list.files("~/proj/demscore/data_processing/modules/thematic_datasets_variables", 
                 pattern = "*.R$", full.names = TRUE)
THEMES <- ll %>% basename %>% tools::file_path_sans_ext(.)
OUTPUT_UNIT <- "u_vdem_party_country_year"
VERSION_NR <- Sys.getenv("DEMSCORE_RELEASE")
DIR <- file.path(Sys.getenv("ROOT_DIR"), paste0("unit_data/", OUTPUT_UNIT))
OUT_DIR <- file.path(Sys.getenv("ROOT_DIR"), "themes", VERSION_NR)
FILES <- list.files(DIR) %>%
  tools::file_path_sans_ext(.)

variables <- DBI::dbGetQuery(db, "SELECT * FROM variables;")
thematic_datasets <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets;")
thematic_datasets_variables <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets_variables;")


thematic_datasets %<>% dplyr::filter(tag == THEME)
thematic_datasets_variables %<>% 
  dplyr::filter(thematic_dataset_id %in% 
                  thematic_datasets$thematic_dataset_id)
variables %<>% 
  dplyr::filter(tag_long %in% 
                  thematic_datasets_variables$tag_long) %>%
  filter(tag_long %in% FILES)

args <- list(help = FALSE,
             include_unit_cols = TRUE, 
             file_format = "R", 
             output_unit_tag = OUTPUT_UNIT,
             outfile = file.path(OUT_DIR, paste0(THEME, "_dataset_party_country_year.rds")),
             select_all_rows = TRUE,
             country = c("Norway"),
             min_year = 1900,
             max_year = 2019,
             variables = variables$tag_long,
             conflict_location = c("India"),
             region = c("Albania"),
             min_date = c("1919-01-07"),
             max_date = c("1997-01-20"))

generate_data(args, POSTGRES_TABLES_DIR, UNIT_DATA_DIR, LOCAL,
              UNIT_TABLE_DIR, prep = TRUE)


df <- read_file(file.path(OUT_DIR, paste0(THEME, "_dataset_party_country_year.rds")))
write_file(df, file.path(OUT_DIR, paste0(THEME, "_dataset_party_country_year.csv")))
write_file(df, file.path(OUT_DIR, paste0(THEME, "_dataset_party_country_year.dta")))

print(THEME)
info("Generate thematic codebook...")

args$thematic <- THEME
args$outfile <- file.path(OUT_DIR, paste0(THEME, "_codebook_party_country_year.pdf"))
create_codebook(args, REF_STATIC_DIR, POSTGRES_TABLES_DIR, 
                LOCAL, prep = FALSE)