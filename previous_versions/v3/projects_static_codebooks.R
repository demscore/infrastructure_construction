#!/usr/bin/env Rscript

suppressMessages(library(whisker))
suppressMessages(library(dplyr))
suppressMessages(library(demutils))

db <- pg_connect()

VERSION_NR <- Sys.getenv("DEMSCORE_RELEASE")

datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;") %>% 
  filter(demscore_release == VERSION_NR) %>%
  arrange(tag)

projects <- unique(datasets$project_short)

## Prep refs only once before loop

args <- list(help = FALSE,
             include_unit_cols = TRUE, 
             file_format = "CSV",
             outfile = paste0("~/data/demscore_next_release/zip/project_codebooks_v3/qog_codebook.pdf"),
             project = "qog")

create_codebook(args, REF_STATIC_DIR, POSTGRES_TABLES_DIR, LOCAL, prep = TRUE)

# Codebook for projects
for (i in projects) {
  
  args <- list(help = FALSE,
               include_unit_cols = TRUE, 
               file_format = "CSV",
               outfile = paste0("~/data/demscore_next_release/zip/project_codebooks_v3/", i, "_codebook.pdf"),
               project = i)
  
  create_codebook(args, REF_STATIC_DIR, POSTGRES_TABLES_DIR, LOCAL, prep = FALSE)
  
}

df <- read_file("~/data.rds")
df <- read_file("~/3.0/data.rds")
