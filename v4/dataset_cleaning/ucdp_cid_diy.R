library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_cid_diy <- read_datasets("ucdp_cid_diy", db, original = TRUE)

# Clean column names
names(ucdp_cid_diy) <- clean_column_names(names(ucdp_cid_diy))

#dups <- duplicates(ucdp_cid_diy, c("dyad_id", "year", "issue_text", "tier4")) %>% arrange(year, dyad_id, issue_text)

#write_file(dups, file.path(Sys.getenv("ROOT_DIR"), "refs", "ucdp", "metadata", "dups_diy_v2.csv"))

# Create unit columns
seq_along(nrow(ucdp_cid_diy))
ucdp_cid_diy %<>% rename(u_ucdp_dyad_issue_year_id = v1)

ucdp_cid_diy$u_ucdp_dyad_issue_year_dyad_id <- 
  as.character(ucdp_cid_diy$dyad_id)

ucdp_cid_diy$u_ucdp_dyad_issue_year_year <- 
  ucdp_cid_diy$year

ucdp_cid_diy$u_ucdp_dyad_issue_year_issue <- 
  ucdp_cid_diy$issue_text


# Check for duplicates in column names
no_duplicate_names(ucdp_cid_diy)


write_dataset(ucdp_cid_diy, 
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_cid_diy_cleaned.rds"),
              tag = "ucdp_cid_diy",
              overwrite = TRUE)
