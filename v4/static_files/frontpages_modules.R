library(dplyr)
library(demutils)

source_dir <- "~/proj/demscore/reference_documents/demscorecodebook/"
dest_dir <- "~/data/demscore_next_release/autogenerated_refs/static/"

files <- list(
  complab = "complabfrontpage.pdf",
  hdata = "hdatafrontpage.pdf",
  qog = "qogfrontpage.pdf",
  repdem = "repdemfrontpage.pdf",
  ucdp = "ucdpfrontpage.pdf",
  vdem = "vdemfrontpage.pdf"
)

db <- pg_connect()

for (file_key in names(files)) {
  
  file_name <- files[[file_key]]
  
  source_file <- file.path(source_dir, file_name)
  dest_file <- file.path(dest_dir, file_name)
  
  system(paste("cp", source_file, dest_file))
  
  print(paste("Source file:", source_file))
  print(paste("Destination file:", dest_file))
  
  if (file.exists(dest_file)) {
    status <- 'done'
  } else {
    status <- 'error'
  }
  
  print(paste("File key:", file_key, "Status:", status))

  query <- paste0("UPDATE tasks SET status = '", status, "' WHERE task_name = 'fp_", file_key, "';")
  DBI::dbSendQuery(db, query)
}

DBI::dbDisconnect(db)