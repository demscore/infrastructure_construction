#!/usr/bin/env Rscript

suppressMessages(library(whisker))
suppressMessages(library(dplyr))
suppressMessages(library(demutils))

db <- pg_connect()

system("mkdir -p ~/data/demscore_next_release/zip/dataset_codebooks")

# Make sure we use the correct frontpage for the codebooks
system("cp ~/proj/demscore/reference_documents/demscorecodebook/codebookfrontpage.pdf ~/data/demscore_next_release/autogenerated_refs/static/codebookfrontpage.pdf")

VERSION_NR <- Sys.getenv("DEMSCORE_RELEASE")

# Create one codebook per dataset
# Make sure refs are prepped so the argument can be set to FALSE in the loop ----
args <- list(help = FALSE,
             include_unit_cols = TRUE, 
             file_format = "CSV",
             outfile = paste0("~/data/demscore_next_release/zip/dataset_codebooks/hdata_fomin_codebook.pdf"),
             dataset = "hdata_fomin")

create_codebook(args, REF_STATIC_DIR, POSTGRES_TABLES_DIR, LOCAL, prep = TRUE)

if (file.exists(args$outfile)) {
  status <- 'done'
} else {
  status <- 'error'
}

print(paste("Dataset: hdata_fomin; Status:", status))

query <- paste0("UPDATE tasks SET status = '", status, "' WHERE task_name = 'hdata_fomin' AND module_name = 'dataset_codebooks';")
DBI::dbSendQuery(db, query)

## Loop over datasets ----------------------------------------------------------
datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;") %>% 
  filter(demscore_release == VERSION_NR) %>%
  arrange(tag)

tags <- datasets$tag

# Codebook for a specific dataset
for (i in tags) {
  print(i)
  
  args <- list(help = FALSE,
               include_unit_cols = TRUE, 
               file_format = "CSV",
               outfile = paste0("~/data/demscore_next_release/zip/dataset_codebooks/", i, "_codebook.pdf"),
               dataset = i)
  
  create_codebook(args, REF_STATIC_DIR, POSTGRES_TABLES_DIR, LOCAL, prep = FALSE)
  
  if (file.exists(args$outfile)) {
    status <- 'done'
  } else {
    status <- 'error'
  }
  
  print(paste("Dataset:", i, "Status:", status))
  
  query <- paste0("UPDATE tasks SET status = '", status, "' WHERE task_name = '", i, "' AND module_name = 'dataset_codebooks';")
  DBI::dbSendQuery(db, query)
  
}
