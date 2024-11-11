library(dplyr)
library(demutils)

db <- pg_connect()

views_pgm_01_22 <- read_datasets("views_pgm_01_22", db)
views_pgm_02_22 <- read_datasets("views_pgm_02_22", db)
views_pgm_03_22 <- read_datasets("views_pgm_03_22", db)
views_pgm_04_22 <- read_datasets("views_pgm_04_22", db)
views_pgm_05_22 <- read_datasets("views_pgm_05_22", db)
views_pgm_06_22 <- read_datasets("views_pgm_06_22", db)
views_pgm_07_22 <- read_datasets("views_pgm_07_22", db)
views_pgm_08_22 <- read_datasets("views_pgm_08_22", db)
views_pgm_09_22 <- read_datasets("views_pgm_09_22", db)
views_pgm_10_22 <- read_datasets("views_pgm_10_22", db)
views_pgm_11_22 <- read_datasets("views_pgm_11_22", db)
views_pgm_12_22 <- read_datasets("views_pgm_12_22", db)
views_pgm_01_23 <- read_datasets("views_pgm_01_23", db)
views_pgm_02_23 <- read_datasets("views_pgm_02_23", db)
views_pgm_03_23 <- read_datasets("views_pgm_03_23", db)
views_pgm_04_23 <- read_datasets("views_pgm_04_23", db)
views_pgm_05_23 <- read_datasets("views_pgm_05_23", db)
views_pgm_06_23 <- read_datasets("views_pgm_06_23", db)
views_pgm_07_23 <- read_datasets("views_pgm_07_23", db)
views_pgm_08_23 <- read_datasets("views_pgm_08_23", db)
views_pgm_09_23 <- read_datasets("views_pgm_09_23", db)
views_pgm_10_23 <- read_datasets("views_pgm_10_23", db)
views_pgm_11_23 <- read_datasets("views_pgm_11_23", db)
views_pgm_12_23 <- read_datasets("views_pgm_12_23", db)
views_pgm_01_24 <- read_datasets("views_pgm_01_24", db)

# Select unit columns for unit table
u_views_pg_month <- 
  bind_rows(
    select(views_pgm_01_22, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_02_22, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_03_22, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_04_22, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_05_22, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_06_22, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_07_22, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_08_22, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_09_22, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_10_22, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_11_22, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_12_22, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_01_23, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_02_23, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_03_23, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_04_23, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_05_23, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_06_23, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_07_23, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_08_23, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_09_23, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_10_23, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_11_23, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_12_23, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id),
    select(views_pgm_01_24, 
           u_views_pg_month_pg_id,
           u_views_pg_month_month_id)
    ) %>%
  distinct(.) %>%
  arrange(u_views_pg_month_month_id,
          u_views_pg_month_pg_id)


stopifnot("There are missing values in the unit columns." = !any(is.na(u_views_pg_month)))

# Save unit table
write_unit_table(u_views_pg_month, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_views_pg_month.rds"),
                 tag = "u_views_pg_month")
