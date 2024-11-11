#!/usr/bin/env Rscript

# This script creates zip files for all static datasets and reference documents.
# One zip file is created per dataset and file format. Each zip file contains 
# the dataset in the specified format plus the codebook.

library(utils)
library(dplyr)
library(demutils)

db <- pg_connect()

VERSION_NR <- Sys.getenv("DEMSCORE_RELEASE")

datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;") %>%
  filter(demscore_release == VERSION_NR)

project <- c(unique(datasets$project_short), "views")
tags <- datasets$tag

suppressWarnings(dir.create(file.path("~/data/demscore_next_release/zip/", 
                                      VERSION_NR, "complab//"), recursive = TRUE))
suppressWarnings(dir.create(file.path("~/data/demscore_next_release/zip/", 
                                      VERSION_NR, "hdata//"), recursive = TRUE))
suppressWarnings(dir.create(file.path("~/data/demscore_next_release/zip/", 
                                      VERSION_NR, "qog//"), recursive = TRUE))
suppressWarnings(dir.create(file.path("~/data/demscore_next_release/zip/", 
                                      VERSION_NR, "repdem//"), recursive = TRUE))
suppressWarnings(dir.create(file.path("~/data/demscore_next_release/zip/", 
                                      VERSION_NR, "ucdp//"), recursive = TRUE))
suppressWarnings(dir.create(file.path("~/data/demscore_next_release/zip/", 
                                      VERSION_NR, "vdem//"), recursive = TRUE))
suppressWarnings(dir.create(file.path("~/data/demscore_next_release/zip/", 
                                      VERSION_NR, "views//"), recursive = TRUE))

# Define the directories and tags
ROOT_DIR <- "/home/tortoise/data/demscore_next_release"
CODEBOOK_DIR <- file.path(ROOT_DIR, "zip/codebooks/")
OUTPUT_DIR <- file.path(ROOT_DIR, "zip", VERSION_NR, project, "/")

# CSV ZIP
for (proj in project) {
  
  if(proj == "views") {
    
    CLEANED_CSV_DIR <- file.path(ROOT_DIR, "datasets", "ucdp", "cleaned_datasets_csv/")
    OUTPUT_DIR <- file.path(ROOT_DIR, "zip", VERSION_NR, "views", "/")
    
  } else {
    
    CLEANED_CSV_DIR <- file.path(ROOT_DIR, "datasets", proj, "cleaned_datasets_csv/")
    OUTPUT_DIR <- file.path(ROOT_DIR, "zip", VERSION_NR, proj, "/")
    
  }
  

  for (tag in tags) {
    if (grepl(proj, tag)) {
      # File names
      pdf <- paste0(tag, "_codebook.pdf")
      csv <- paste0(tag, "_cleaned.csv")
      
      # Create a zip file name
      zip_file <- paste0(OUTPUT_DIR, tag, "_csv.zip")
      
      # Create a vector of file paths
      pdf_file <- paste0(CODEBOOK_DIR, pdf)
      csv_file <- paste0(CLEANED_CSV_DIR, csv)
      
      # Use zip function to create a zip file
      zip(zip_file, 
          files = c(csv_file, pdf_file), 
          flags = "-j")
    }
  }
}

# DTA ZIP
for (proj in project) {
  
  
  if(proj == "views") {
    
    CLEANED_DTA_DIR <- file.path(ROOT_DIR, "datasets", "ucdp", "cleaned_datasets_dta/")
    OUTPUT_DIR <- file.path(ROOT_DIR, "zip", VERSION_NR, "views", "/")
    
  } else {
    
    CLEANED_DTA_DIR <- file.path(ROOT_DIR, "datasets", proj, "cleaned_datasets_dta/")
    OUTPUT_DIR <- file.path(ROOT_DIR, "zip", VERSION_NR, proj, "/")
    
  }
  
  for (tag in tags) {
    if (grepl(proj, tag)) {
      # File names
      pdf <- paste0(tag, "_codebook.pdf")
      dta <- paste0(tag, "_cleaned.dta")
      
      # Create a zip file name
      zip_file <- paste0(OUTPUT_DIR, tag, "_dta.zip")
      
      # Create a vector of file paths
      pdf_file <- paste0(CODEBOOK_DIR, pdf)
      dta_file <- paste0(CLEANED_DTA_DIR, dta)
      
      # Use zip function to create a zip file
      zip(zip_file, 
          files = c(dta_file, pdf_file), 
          flags = "-j")
    }
  }
}


# RDS ZIP  
for (proj in project) {
  
  if(proj == "views") {
    
    CLEANED_RDS_DIR <- file.path(ROOT_DIR, "datasets", "ucdp", "cleaned_datasets/")
    OUTPUT_DIR <- file.path(ROOT_DIR, "zip", VERSION_NR, "views", "/")
    
  } else {
    
    CLEANED_RDS_DIR <- file.path(ROOT_DIR, "datasets", proj, "cleaned_datasets/")
    OUTPUT_DIR <- file.path(ROOT_DIR, "zip", VERSION_NR, proj, "/")
    
  }
  
  for (tag in tags) {
    if (grepl(proj, tag)) {
      
      # File names
      pdf <- paste0(tag, "_codebook.pdf")
      rds <- paste0(tag, "_cleaned.rds")
      
      # Create a zip file name
      zip_file <- paste0(OUTPUT_DIR, tag, "_rds.zip")
      
      # Create a vector of file paths
      pdf_file <- paste0(CODEBOOK_DIR, pdf)
      rds_file <- paste0(CLEANED_RDS_DIR, rds)
      
      # Use zip function to create a zip file
      zip(zip_file, 
          files = c(rds_file, pdf_file), 
          flags = "-j")
    }
  }
}
