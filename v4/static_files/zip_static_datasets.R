#!/usr/bin/env Rscript

# This script creates zip files for all static datasets and reference documents.
# One zip file is created per dataset and file format. Each zip file contains 
# the dataset in the specified format plus the codebook.
library(utils)
library(dplyr)
library(demutils)

db <- pg_connect()
VERSION_NR <- Sys.getenv("DEMSCORE_RELEASE")
STATIC <- "static_datasets"

datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;") %>%
  filter(demscore_release == VERSION_NR)

project <- c(unique(datasets$project_short), "views")
tags <- datasets$tag

ROOT_DIR <- path.expand(Sys.getenv("ROOT_DIR"))

# Debugging: Print the ROOT_DIR
cat("ROOT_DIR:", ROOT_DIR, "\n")

suppressWarnings(dir.create(file.path(
  path.expand("~/data/demscore_next_release/zip/static_datasets/complab/")), recursive = TRUE))
suppressWarnings(dir.create(file.path(
  path.expand("~/data/demscore_next_release/zip/static_datasets/hdata/")), recursive = TRUE))
suppressWarnings(dir.create(file.path(
  path.expand("~/data/demscore_next_release/zip/static_datasets/qog/")), recursive = TRUE))
suppressWarnings(dir.create(file.path(
  path.expand("~/data/demscore_next_release/zip/static_datasets/repdem/")), recursive = TRUE))
suppressWarnings(dir.create(file.path(
  path.expand("~/data/demscore_next_release/zip/static_datasets/ucdp/")), recursive = TRUE))
suppressWarnings(dir.create(file.path(
  path.expand("~/data/demscore_next_release/zip/static_datasets/vdem/")), recursive = TRUE))
suppressWarnings(dir.create(file.path(
  path.expand("~/data/demscore_next_release/zip/static_datasets/views/")), recursive = TRUE))


CODEBOOK_DIR <- file.path(ROOT_DIR, "zip/dataset_codebooks/")
OUTPUT_DIR <- file.path(ROOT_DIR, "zip/static_datasets/", project)

cat("CODEBOOK_DIR:", CODEBOOK_DIR, "\n")
cat("OUTPUT_DIR:", OUTPUT_DIR, "\n")

# CSV ZIP
for (proj in project) {
  
  if(proj == "views") {
    
    CLEANED_CSV_DIR <- file.path(ROOT_DIR, "datasets", "ucdp", "cleaned_datasets_csv/")
    OUTPUT_DIR <- file.path(ROOT_DIR, "zip/static_datasets/views/")
    
  } else {
    
    CLEANED_CSV_DIR <- file.path(ROOT_DIR, "datasets", proj, "cleaned_datasets_csv/")
    OUTPUT_DIR <- file.path(ROOT_DIR, "zip/static_datasets", proj, "/")
    
  }
  
  cat("CLEANED_CSV_DIR for project", proj, ":", CLEANED_CSV_DIR, "\n")
  cat("OUTPUT_DIR for project", proj, ":", OUTPUT_DIR, "\n")
  
  for (tag in tags) {
    if (grepl(proj, tag)) {
      pdf <- paste0(tag, "_codebook.pdf")
      csv <- paste0(tag, "_cleaned.csv")
      
      zip_file <- file.path(OUTPUT_DIR, paste0(tag, "_csv.zip"))
      
      pdf_file <- file.path(CODEBOOK_DIR, pdf)
      csv_file <- file.path(CLEANED_CSV_DIR, csv)
      
      cat("CSV File Path:", csv_file, "\n")
      cat("PDF File Path:", pdf_file, "\n")
      cat("ZIP File Path:", zip_file, "\n")
      
      # Check if files exist
      if (file.exists(csv_file) && file.exists(pdf_file)) {
        zip(zip_file, 
            files = c(csv_file, pdf_file), 
            flags = "-j")
      } else {
        cat("Warning: One or both files do not exist. Skipping zip creation.\n")
        if (!file.exists(csv_file)) {
          cat("Missing CSV File:", csv_file, "\n")
        }
        if (!file.exists(pdf_file)) {
          cat("Missing PDF File:", pdf_file, "\n")
        }
      }
    }
  }
}


# DTA
for (proj in project) {
  
  if(proj == "views") {
    
    CLEANED_DTA_DIR <- file.path(ROOT_DIR, "datasets", "ucdp", "cleaned_datasets_dta/")
    OUTPUT_DIR <- file.path(ROOT_DIR, "zip/static_datasets/views/")
    
  } else {
    
    CLEANED_DTA_DIR <- file.path(ROOT_DIR, "datasets", proj, "cleaned_datasets_dta/")
    OUTPUT_DIR <- file.path(ROOT_DIR, "zip/static_datasets", proj, "/")
    
  }
  
  cat("CLEANED_DTA_DIR for project", proj, ":", CLEANED_DTA_DIR, "\n")
  cat("OUTPUT_DIR for project", proj, ":", OUTPUT_DIR, "\n")
  
  for (tag in tags) {
    if (grepl(proj, tag)) {
      
      pdf <- paste0(tag, "_codebook.pdf")
      dta <- paste0(tag, "_cleaned.dta")
      
      zip_file <- file.path(OUTPUT_DIR, paste0(tag, "_dta.zip"))
      
      pdf_file <- file.path(CODEBOOK_DIR, pdf)
      dta_file <- file.path(CLEANED_DTA_DIR, dta)

      cat("DTA File Path:", dta_file, "\n")
      cat("PDF File Path:", pdf_file, "\n")
      cat("ZIP File Path:", zip_file, "\n")
      
      if (file.exists(dta_file) && file.exists(pdf_file)) {
        zip(zip_file, 
            files = c(dta_file, pdf_file), 
            flags = "-j")
      } else {
        cat("Warning: One or both files do not exist. Skipping zip creation.\n")
        if (!file.exists(dta_file)) {
          cat("Missing DTA File:", dta_file, "\n")
        }
        if (!file.exists(pdf_file)) {
          cat("Missing PDF File:", pdf_file, "\n")
        }
      }
    }
  }
}


# RDS ZIP  
for (proj in project) {
  
  if(proj == "views") {
    
    CLEANED_RDS_DIR <- file.path(ROOT_DIR, "datasets", "ucdp", "cleaned_datasets/")
    OUTPUT_DIR <- file.path(ROOT_DIR, "zip/static_datasets/views/")
    
  } else {
    
    CLEANED_RDS_DIR <- file.path(ROOT_DIR, "datasets", proj, "cleaned_datasets/")
    OUTPUT_DIR <- file.path(ROOT_DIR, "zip/static_datasets", proj, "/")
    
  }
  
  cat("CLEANED_RDS_DIR for project", proj, ":", CLEANED_RDS_DIR, "\n")
  cat("OUTPUT_DIR for project", proj, ":", OUTPUT_DIR, "\n")
  
  for (tag in tags) {
    if (grepl(proj, tag)) {
      
      pdf <- paste0(tag, "_codebook.pdf")
      rds <- paste0(tag, "_cleaned.rds")
      
      zip_file <- file.path(OUTPUT_DIR, paste0(tag, "_rds.zip"))
      
      pdf_file <- file.path(CODEBOOK_DIR, pdf)
      rds_file <- file.path(CLEANED_RDS_DIR, rds)
      
      cat("RDS File Path:", rds_file, "\n")
      cat("PDF File Path:", pdf_file, "\n")
      cat("ZIP File Path:", zip_file, "\n")
      
      if (file.exists(rds_file) && file.exists(pdf_file)) {
        zip(zip_file, 
            files = c(rds_file, pdf_file), 
            flags = "-j")
      } else {
        cat("Warning: One or both files do not exist. Skipping zip creation.\n")
        if (!file.exists(rds_file)) {
          cat("Missing RDS File:", rds_file, "\n")
        }
        if (!file.exists(pdf_file)) {
          cat("Missing PDF File:", pdf_file, "\n")
        }
      }
    }
  }
}

# Delete the separate codebook pdfs to not clutter the directory. All codebooks 
# exist in the zipped files.

#dir_to_delete <- "~/data/demscore_next_release/zip/dataset_codebooks"
#system(paste("rm -rf", dir_to_delete))
