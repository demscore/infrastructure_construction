
THEME <- "gender"
OUTPUT_UNIT <- "u_demscore_country_year"

suppressMessages(library(dplyr))
suppressMessages(library(demutils))

DIR <- file.path(Sys.getenv("ROOT_DIR"), paste0("unit_data/", OUTPUT_UNIT))
OUT_DIR <- file.path(Sys.getenv("ROOT_DIR"), "themes")
FILES <- list.files(DIR) %>%
  tools::file_path_sans_ext(.)

db <- pg_connect()
variables <- tbl(db, "variables") %>% collect(n = Inf)
thematic_datasets <- tbl(db, "thematic_datasets") %>% collect(n = Inf)
thematic_datasets_variables <- tbl(db, "thematic_datasets_variables") %>% collect(n = Inf)

# Filter variables
thematic_datasets %<>% dplyr::filter(tag == THEME)
thematic_datasets_variables %<>% 
	dplyr::filter(thematic_dataset_id %in% 
				  thematic_datasets$thematic_dataset_id)
variables %<>% 
	dplyr::filter(tag_long %in% 
		thematic_datasets_variables$tag_long) %>%
  filter(tag_long %in% FILES)



# Parse docopt string arguments and options
args <- list(help = FALSE,
			 include_unit_cols = TRUE, 
			 file_format = "R", 
			 output_unit_tag = OUTPUT_UNIT,
			 outfile = file.path(OUT_DIR, paste0(THEME, "_dataset.rds")),
			 variables = variables$tag_long)

# Functions
generate_data(args, POSTGRES_TABLES_DIR, UNIT_DATA_DIR, LOCAL,
	UNIT_TABLE_DIR, prep = TRUE)


df <- read_file(file.path(OUT_DIR, paste0(THEME, "_dataset.rds")))

write_file(df, file.path(OUT_DIR, paste0(THEME, "_dataset.csv")))

write_file(df, file.path(OUT_DIR, paste0(THEME, "_dataset.dta")))
# We can create a codebook like this, but it is better to use generate.R because 
# that downloads the newest versions of the postgres tables
# This function uses the tables in REFS_STATIC_DIR and POSTGRES_TABLES_DIR. 
# If you create codebooks here instead of using ./generate.R, make sure that the files are up to date

args$thematic <- THEME
args$outfile <- file.path(OUT_DIR, paste0(THEME, "_codebook.pdf"))
create_codebook(args, REF_STATIC_DIR, POSTGRES_TABLES_DIR, 
                LOCAL, prep = TRUE)
