library(utils)
library(dplyr)
library(demutils)

db <- pg_connect()

thematic_datasets <- DBI::dbGetQuery(db, "SELECT * FROM thematic_datasets;")

VERSION_NR <- Sys.getenv("DEMSCORE_RELEASE")
ROOT_DIR <- Sys.getenv("ROOT_DIR")
THEMATIC_DIR <- file.path(ROOT_DIR, "themes", VERSION_NR)
OUTPUT_DIR <- file.path(ROOT_DIR, "zip", "thematic_datasets")
THEMES <- unique(thematic_datasets$tag)

# CSV ZIP
for (t in THEMES) {
  
  theme_output_dir <- file.path(OUTPUT_DIR, t)
  pdf_file <- file.path(THEMATIC_DIR, paste0(t, "_codebook.pdf"))
  csv_file <- file.path(THEMATIC_DIR, paste0(t, "_dataset.csv"))
  
  cat("PDF file path:", pdf_file, "\n")
  cat("CSV file path:", csv_file, "\n")
  

  if (file.exists(pdf_file) && file.exists(csv_file)) {
    
    zip_file <- file.path(theme_output_dir, paste0(t, "_csv.zip"))
    
    dir.create(theme_output_dir, recursive = TRUE, showWarnings = FALSE)
    
    zip_output <- system(paste("zip -j", zip_file, csv_file, pdf_file), intern = TRUE)
    
    cat("Zip command output:\n", zip_output, "\n")
  } else {
    warning(paste("Files not found for theme:", t))
  }
}

# DTA ZIP
for (t in THEMES) {
  
  theme_output_dir <- file.path(OUTPUT_DIR, t)
  pdf_file <- file.path(THEMATIC_DIR, paste0(t, "_codebook.pdf"))
  dta_file <- file.path(THEMATIC_DIR, paste0(t, "_dataset.dta"))
  
  cat("PDF file path:", pdf_file, "\n")
  cat("DTA file path:", dta_file, "\n")
  
  
  if (file.exists(pdf_file) && file.exists(dta_file)) {
    
    zip_file <- file.path(theme_output_dir, paste0(t, "_dta.zip"))
    
    dir.create(theme_output_dir, recursive = TRUE, showWarnings = FALSE)
    
    zip_output <- system(paste("zip -j", zip_file, dta_file, pdf_file), intern = TRUE)
    
    cat("Zip command output:\n", zip_output, "\n")
  } else {
    warning(paste("Files not found for theme:", t))
  }
}


# RDS ZIP  
for (t in THEMES) {
  
  theme_output_dir <- file.path(OUTPUT_DIR, t)
  pdf_file <- file.path(THEMATIC_DIR, paste0(t, "_codebook.pdf"))
  rds_file <- file.path(THEMATIC_DIR, paste0(t, "_dataset.rds"))
  
  cat("PDF file path:", pdf_file, "\n")
  cat("RDS file path:", rds_file, "\n")
  
  
  if (file.exists(pdf_file) && file.exists(rds_file)) {
    
    zip_file <- file.path(theme_output_dir, paste0(t, "_rds.zip"))
    
    dir.create(theme_output_dir, recursive = TRUE, showWarnings = FALSE)
    
    zip_output <- system(paste("zip -j", zip_file, rds_file, pdf_file), intern = TRUE)
    
    cat("Zip command output:\n", zip_output, "\n")
  } else {
    warning(paste("Files not found for theme:", t))
  }
}