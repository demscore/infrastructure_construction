suppressMessages(library(dplyr))
suppressMessages(library(dbplyr))
suppressMessages(library(demutils))
library(parallel)
db <- pg_connect() %>% quiet 

DEMSCORE_VERSION <- Sys.getenv("DEMSCORE_RELEASE")

# Dataset Numbers

datasets <- DBI::dbGetQuery(db, paste0("SELECT * FROM datasets WHERE demscore_release ~ '", DEMSCORE_VERSION, "';"))
cat("Number of Datasets \n")
cat(nrow(datasets), "\n")

datasets <- DBI::dbGetQuery(db, paste0("SELECT * FROM datasets WHERE demscore_release ~ '", DEMSCORE_VERSION, "';"))
datasets %<>% filter(project_short == "qog")
cat("QoG datasets \n")
cat(nrow(datasets), "\n")

datasets <- DBI::dbGetQuery(db, paste0("SELECT * FROM datasets WHERE demscore_release ~ '", DEMSCORE_VERSION, "';"))
datasets %<>% filter(project_short == "vdem")
cat("V-Dem datasets \n")
cat(nrow(datasets), "\n")

datasets <- DBI::dbGetQuery(db, paste0("SELECT * FROM datasets WHERE demscore_release ~ '", DEMSCORE_VERSION, "';"))
datasets %<>% filter(project_short == "hdata")
cat("H-DATA datasets \n")
cat(nrow(datasets), "\n")

datasets <- DBI::dbGetQuery(db, paste0("SELECT * FROM datasets WHERE demscore_release ~ '", DEMSCORE_VERSION, "';"))
datasets %<>% filter(project_short == "complab")
cat("Complab datasets \n")
cat(nrow(datasets), "\n")

datasets <- DBI::dbGetQuery(db, paste0("SELECT * FROM datasets WHERE demscore_release ~ '", DEMSCORE_VERSION, "';"))
datasets %<>% filter(project_short == "repdem")
cat("Repdem datasets \n")
cat(nrow(datasets), "\n")

datasets <- DBI::dbGetQuery(db, paste0("SELECT * FROM datasets WHERE demscore_release ~ '", DEMSCORE_VERSION, "';"))
datasets %<>% filter(project_short == "ucdp")
cat("UCDP datasets \n")
cat(nrow(datasets), "\n")

datasets <- DBI::dbGetQuery(db, paste0("SELECT * FROM datasets WHERE demscore_release ~ '", DEMSCORE_VERSION, "';"))
datasets %<>% filter(project_short == "views")
cat("UCDP\\VIEWS datasets \n")
cat(nrow(datasets), "\n")

# Units Numbers

units <- DBI::dbGetQuery(db, "SELECT * FROM units WHERE active IS TRUE;") 
cat("Number of Output Units \n")
cat(nrow(units), "\n")

units <- DBI::dbGetQuery(db, "SELECT * FROM units WHERE active IS TRUE;") 
units %<>% filter(grepl("^u_qog", unit_tag))
cat("QoG units \n")
cat(nrow(units), "\n")

units <- DBI::dbGetQuery(db, "SELECT * FROM units WHERE active IS TRUE;") 
units %<>% filter(grepl("^u_vdem", unit_tag))
cat("V-Dem units \n")
cat(nrow(units), "\n")

units <- DBI::dbGetQuery(db, "SELECT * FROM units WHERE active IS TRUE;") 
units %<>% filter(grepl("^u_ucdp", unit_tag))
cat("UCDP units \n")
cat(nrow(units), "\n")

units <- DBI::dbGetQuery(db, "SELECT * FROM units WHERE active IS TRUE;")
units %<>% filter(grepl("^u_views", unit_tag))
cat("VIEWS units \n")
cat(nrow(units), "\n")

units <- DBI::dbGetQuery(db, "SELECT * FROM units WHERE active IS TRUE;") 
units %<>% filter(grepl("^u_repdem", unit_tag))
cat("REPDEM units \n")
cat(nrow(units), "\n")

units <- DBI::dbGetQuery(db, "SELECT * FROM units WHERE active IS TRUE;") 
units %<>% filter(grepl("^u_complab", unit_tag))
cat("COMPLAB units \n")
cat(nrow(units), "\n")

# Variables Numbers

variabes <- DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE;")
cat("Number of datasets:\n")
cat(nrow(datasets), "\n")
cat("Number of unique variables:\n")
cat(nrow(variabes), "\n")


variabes <- DBI::dbGetQuery(db, "SELECT * FROM variables WHERE active IS TRUE and graphable IS TRUE;")
cat("Number of graphable variables:\n")
cat(nrow(variabes), "\n")

vars <- list.files(file.path(Sys.getenv("ROOT_DIR"), "unit_data"), 
                   recursive = TRUE, full.names = TRUE) %>%
  length
cat("Number of variables accessible through Output Units \n")
cat("(so far): ", vars %>% format(., big.mark = ","))

obs <- read_file(file.path(Sys.getenv("ROOT_DIR"), "checks/tables/observation_counts.rds"),
                 msg = FALSE)
obs %<>% select(-variable)

cat("Number of non-missing observations \n",
    "accessible through Output Units: \n")
cat(sum(obs, na.rm = TRUE) %>% format(., big.mark = ","))

cat("Infrastructure Construction R-code:\n")
system("cd ~/proj/demscore/; find . -name '*.R' | xargs grep . | wc -l | tail -n1", intern = T) %>% cat(., sep = "\n")
cat("R-package utilities for Infrastructure Construction:\n")
system("cd ~/proj/demutils/R/; find . -name '*.R' | xargs grep . | wc -l | tail -n1", intern = T) %>% cat(., sep = "\n")

# Methodology Numbers

methodology <- DBI::dbGetQuery(db, "SELECT * FROM methodology WHERE show IS TRUE;")
cat("Number of available dataset to Output Unit combinations \n")
cat(nrow(methodology), "\n")

unit_trans <- DBI::dbGetQuery(db, "SELECT * FROM unit_trans;")
cat("Number of Output Unit to Output Unit combinations \n")
cat(nrow(unit_trans), "\n")

unit_trans <- DBI::dbGetQuery(db, "SELECT * FROM unit_trans WHERE direct IS TRUE and active IS TRUE;")
cat("Number of direct Output Unit to Output Unit combinations \n")
cat(nrow(unit_trans), "\n")

unit_trans <- DBI::dbGetQuery(db, "SELECT * FROM unit_trans WHERE direct IS FALSE and active IS TRUE;")
cat("Number of indirect Output Unit to Output Unit combinations \n")
cat(nrow(unit_trans), "\n")


# Count data_points per project

# Number of non-missing observations per module
datasets <- tbl(db, "datasets") %>% collect(n = Inf) %>% filter(grepl("^views_", tag))
datasets %<>% filter(grepl("3.0", demscore_release))

# Filter for datasets that should be added
project = "ucdp"
stopifnot(is.character(project) & length(project) == 1L)

# Exclude datasets that have similar observations
#gedevents <- grep("^ucdp_gedevent", datasets$tag, value = TRUE)
#qog_eqi_ind <- grep("^qog_eqi_ind", datasets$tag, value = TRUE)
#views_cm <- grep("^views_cm", datasets$tag, value = TRUE)

#exclude <- c("qog_oecd_cs", "qog_std_cs", "qog_eureg_wide1", "qog_eureg_wide2",
#             "repdem_paged_paco", gedevents, qog_eqi_ind, views_cm, "vdem_cd", "vdem_vp_coder_level",
#             "vdem_coder_level")

datasets %<>% 
 filter(project_short == project) 

# Create vector with all dataset tags  
tags <- c(datasets$tag)

ds <- list()


for (i in seq_along(tags)) {
  ds[[i]] <- read_datasets(tags[i], db)
}

ll <- list()



for(i in 1:nrow(datasets)){
  
  obs <- sum(!is.na(ds[[i]]))
  
  obs
  
  obs <- data.frame(
    project = datasets$tag[i],
    obs = obs
  )
  
  ll[[i]] <- obs
  
}

outdf <- bind_rows(ll) %>%
  summarize(data_points = sum(obs))


cat(paste0("Number of non-missing observations in ", project, ":\n"))
cat(sum(outdf$data_points, na.rm = TRUE) %>% format(., big.mark = ","))

# Observation counts

#--------------------------------------------------------------------------------------------------
# Functions to get dataframe with number of observations per variable by output unit.
# Can read the file here instead of re-generating every time.
#observation_counts <- readRDS(file.path(Sys.getenv("ROOT_DIR"), "checks/tables/observation_counts.rds"))

# Generate observation_counts
# Count observations (or nas if ! is removed before the is.na function)
count_obs <- function(z) {
  
  # Print progress while looping
  print(z)
  
  # Get variables
  files <- list.files(path = paste0("~/data/demscore_next_release/unit_data/", z), pattern="*.rds", full.names=TRUE, recursive=FALSE)
  
  # Function within function, loops over each variable and counts observations per output unit.
  obs <- lapply(files, function(x) {
    
    # Read file
    y <- readRDS(x)
    
    # Filter out NA, -11111, and "-11111" values
    y_filtered <- y[!is.na(y) & y != -11111]
    
    # Get clean variable name, and count observations.
    count <- data.frame(
      variable = x %>% basename %>% tools::file_path_sans_ext(.),
      content = sum(!is.na(y_filtered))  # Count non-NA and non -11111 values
    )
    names(count) <- c("variable", z) 
    
    return(count)
    
  }) %>% bind_rows
  
  return(obs)
}

# Get output units
units <- list.files(path = "~/data/demscore_next_release/unit_data/")

# Join function for next step
fu <- function(x, y) {
  
  full_join(x,y, by = "variable")
  
}

# Loop function and output list
ll <- lapply(units, count_obs)

# Join list into df
observation_counts <- Reduce(fu, ll)

saveRDS(observation_counts, file.path(Sys.getenv("ROOT_DIR"), "checks/tables/observation_counts.rds"))
