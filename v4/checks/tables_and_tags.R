library(dplyr)
library(demutils)

db <- pg_connect()

cb_section <- DBI::dbGetQuery(db, "SELECT * FROM cb_section;")
variables <- DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;")
codebook <- DBI::dbGetQuery(db, "SELECT * FROM codebook;")
methodology <- DBI::dbGetQuery(db, "SELECT * FROM methodology;")
datasets <- DBI::dbGetQuery(db, "SELECT * FROM datasets;") %>% filter(demscore_release != "0")

### ============================================================================
# This does a few checks on whether all pgAdmin tables are filled correctly and
# consistently in the most important columns.
### ============================================================================


# cb_section
stopifnot(!is.na(cb_section$cb_section_name))
stopifnot(!is.na(cb_section$cb_section_tag))

# codebook
stopifnot(!is.na(codebook$cb_entry))

# variables
stopifnot(!is.na(variables$name) | !is.na(variables$head_var))
stopifnot(!is.na(variables$cb_section) | !is.na(variables$head_var)) 
stopifnot(!is.na(variables$active))

# citations
stopifnot(!is.na(datasets$citation_id))
