library(dplyr)
library(demutils)

db <- pg_connect()

complab_spin_cbd <- read_datasets("complab_spin_cbd", db)
complab_spin_outwb <- read_datasets("complab_spin_outwb", db)
complab_spin_plb <- read_datasets("complab_spin_plb", db)
complab_spin_samip <- read_datasets("complab_spin_samip", db)
complab_spin_scip <- read_datasets("complab_spin_scip", db)
complab_spin_sied <- read_datasets("complab_spin_sied", db)
complab_spin_ssfd <- read_datasets("complab_spin_ssfd", db)
complab_spin_hben <- read_datasets("complab_spin_hben", db)
complab_grace <- read_datasets("complab_grace", db)
complab_migpol_gc_cy <- read_datasets("complab_migpol_gc_cy", db)
complab_migpol_impic <- read_datasets("complab_migpol_impic", db)
complab_migpol_impic_pr <- read_datasets("complab_migpol_impic_pr", db)
complab_migpol_imisem <- read_datasets("complab_migpol_imisem", db)
complab_migpol_mipex <- read_datasets("complab_migpol_mipex", db)
complab_migpol_impic_antidisc <- read_datasets("complab_migpol_impic_antidisc", db)
complab_migpol_impic_antidisc_rd <- read_datasets("complab_migpol_impic_antidisc_rd", db)
complab_migpol_hip <- read_datasets("complab_migpol_hip", db)

# Create a named list
ds <- list(complab_spin_cbd = complab_spin_cbd,
           complab_spin_outwb = complab_spin_outwb, 
           complab_spin_plb = complab_spin_plb, 
           complab_spin_samip = complab_spin_samip,
           complab_spin_scip = complab_spin_scip,
           complab_spin_sied = complab_spin_sied,
           complab_spin_ssfd = complab_spin_ssfd,
           complab_spin_hben = complab_spin_hben,
           complab_grace = complab_grace, 
           complab_migpol_gc_cy = complab_migpol_gc_cy,
           complab_migpol_impic = complab_migpol_impic,
           complab_migpol_impic_pr = complab_migpol_impic_pr,
           complab_migpol_imisem = complab_migpol_imisem,
           complab_migpol_mipex = complab_migpol_mipex,
           complab_migpol_impic_antidisc = complab_migpol_impic_antidisc,
           complab_migpol_impic_antidisc_rd = complab_migpol_impic_antidisc_rd,
           complab_migpol_hip = complab_migpol_hip)


# Extract classes 
cl_year <- lapply(ds, function(c) class(c$u_complab_country_year_year))

cat("Dataset names and corresponding class for selected column: \n", paste(names(ds), "-", cl_year, "\n"))
stopifnot("Classes are not identical." = all(sapply(cl_year, identical, cl_year[[1]])))


# The SAMIP data has two entries for Italy and for Norway which adds a extra 0 at the 
# end of the country number OR _adjusted to the country_fname. Both options available in the 
# SAMIP cleaning script.
# For now we remove country_nr from the unit table and create the unit data with the unadjusted 
# country numbers. If the adjusted country number is to be used, an additional coulmn needs
# to be created in all complab cleaning scripts and added to the unit table script. 


# Create unit table by binding unit columns from datasets which have u_complab_country_year
# as a primary output unit.
u_complab_country_year <- 
  bind_rows(select(complab_spin_cbd, 
                   u_complab_country_year_country,
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code), 
            select(complab_spin_plb, 
                   u_complab_country_year_country,
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_spin_samip, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_spin_sied, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_spin_ssfd, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_spin_scip, 
                   u_complab_country_year_country,
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_spin_outwb, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_spin_hben, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_grace, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_migpol_mipex, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_migpol_gc_cy, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_migpol_imisem, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_migpol_impic, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_migpol_impic_pr, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_migpol_impic_antidisc, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_migpol_impic_antidisc_rd, 
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code),
            select(complab_migpol_hip,
                   u_complab_country_year_country, 
                   u_complab_country_year_year, 
                   u_complab_country_year_country_code)
  )%>%
  distinct(.) %>%
  filter(u_complab_country_year_country_code != "Korea") %>%
  filter(u_complab_country_year_country_code != "CSK") %>%
  arrange(u_complab_country_year_country, u_complab_country_year_year)

u_complab_country_year$u_complab_country_year_country <- 
  gsub("&amp;", "\\&", u_complab_country_year$u_complab_country_year_country)

stopifnot("There are missing values in the unit columns." = !any(is.na(u_complab_country_year)))

write_unit_table(u_complab_country_year, 
                 file.path(Sys.getenv("UNIT_TABLE_PATH"), "u_complab_country_year.rds"),
                 tag = "u_complab_country_year")