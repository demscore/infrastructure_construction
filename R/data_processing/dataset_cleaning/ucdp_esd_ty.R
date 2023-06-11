library(dplyr)
library(demutils)

db <- pg_connect()

ucdp_esd_ty <- read_datasets("ucdp_esd_ty", db, original = TRUE)

# Clean column names
names(ucdp_esd_ty) <- clean_column_names(names(ucdp_esd_ty))

#Identify unit columns
no_duplicates(ucdp_esd_ty, c("ext_id", "actor_id", "dyad_id", "year")) #TRUE


# Create unit identifiers
# triad-Year
ucdp_esd_ty$u_ucdp_triad_year_dyad_id <-
  ucdp_esd_ty$dyad_id

ucdp_esd_ty$u_ucdp_triad_year_dyad_name <-
  ucdp_esd_ty$dyad_name

ucdp_esd_ty$u_ucdp_triad_year_actor_id <-
  ucdp_esd_ty$actor_id

ucdp_esd_ty$u_ucdp_triad_year_actor_name <-
  ucdp_esd_ty$actor_name

ucdp_esd_ty$u_ucdp_triad_year_ext_id <-
  ucdp_esd_ty$ext_id

ucdp_esd_ty$u_ucdp_triad_year_ext_name <-
  ucdp_esd_ty$ext_name

ucdp_esd_ty$u_ucdp_triad_year_year <-
  ucdp_esd_ty$year

# Missing values in unit columns for ext_id
# Observations with missing data are left blank. The dataset only contains missing values on
# variables related to external support for observations in which no external support was
# provided. The variables ext_nonstate, ext_coalition, ext_coalition_name, ext_elements, and
# ext_bothsides are set to empty where no external support was provided.

ucdp_esd_ty$u_ucdp_triad_year_ext_id[is.na(ucdp_esd_ty$u_ucdp_triad_year_ext_id)] <- 99999

ucdp_esd_ty$u_ucdp_triad_year_ext_name[is.na(ucdp_esd_ty$u_ucdp_triad_year_ext_name)] <- "no external support provided"


#Final check for duplicates in column names
no_duplicate_names(ucdp_esd_ty)

write_dataset(ucdp_esd_ty,
              file.path(Sys.getenv("ROOT_DIR"),
                        "datasets/ucdp/cleaned_datasets/ucdp_esd_ty_cleaned.rds"),
              tag = "ucdp_esd_ty",
              overwrite = TRUE)