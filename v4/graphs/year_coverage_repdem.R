library(ggplot2)
library(dplyr)
library(demutils)

db <- pg_connect()

DEMSCORE_RELEASE = Sys.getenv("DEMSCORE_RELEASE")

year_coverage_repdem <- function(p) {
  
  df <- DBI::dbGetQuery(db, "SELECT * FROM datasets;")
  # Get year coverage from datasets table
  df %<>% select(tag, name, year_coverage, demscore_release) %>%
    filter(demscore_release == DEMSCORE_RELEASE) %>%
    arrange(tag)

    # sep min and max years
    df <- df %>% filter(!is.na(tag)) %>%
      filter(!is.na(year_coverage)) %>%
      tidyr::separate(year_coverage, c("min_year","max_year"), sep = "-") %>%
      mutate(max_year = coalesce(max_year, min_year)) %>%
      rename(dataset_tag = tag)
    
    df$min_year <- as.numeric(df$min_year)
    df$max_year <- as.numeric(df$max_year)
    
    # Merge in projects
    df <- add_proj(df)

    # Filter for project
    df <- df %>% filter(project == "repdem")

    # Dumbbell
    plot <- ggplot(df, aes(y = reorder(name, min_year), x = min_year, xend = max_year)) +
      ggalt::geom_dumbbell(size = 3, color = "#CDC9C9",
                    colour_x = "#FCE1B5", 
                    colour_xend = "#F8C982") +
      labs(x = "Year", 
           y = "Dataset", 
           title = "Year coverage per dataset", 
           subtitle = "REPDEM") +
      theme_minimal() +
      theme(panel.grid.major.x = element_line(size=0.05)) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      scale_x_continuous(breaks = seq(1940, 2025, 5),
                     limits=c(1940, 2025)) 

      return(plot)
}

plot <- year_coverage_repdem("repdem")
plot

ggsave(file.path(Sys.getenv("ROOT_DIR"), "figures/ds_year_coverage/repdem.jpg"), width = 14, height = 6)
