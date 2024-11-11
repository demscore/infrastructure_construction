library(ggplot2)
library(dplyr)
library(demutils)

db <- pg_connect()

DEMSCORE_RELEASE = Sys.getenv("DEMSCORE_RELEASE")
UCDP_VERSION <- "24.1"

year_coverage_ucdp <- function(p) {

  df <- DBI::dbGetQuery(db, "SELECT * FROM datasets;")
  # Get year coverage from datasets table
  df %<>% select(tag, name, year_coverage, demscore_release) %>%
    filter(demscore_release == DEMSCORE_RELEASE) %>%
    arrange(tag) %>%
    filter(!grepl("^ucdp_gedevent", tag)) %>%
    filter(!grepl("^ucdp_eosv", tag)) %>%
    mutate(name = case_when(
      name == "UCDP External Support Dataset - Triad Year" ~ "UCDP External Support Dataset (AY, DY, TY)",
      name == "UCDP External Support Dataset - Dyad Year" ~ "UCDP External Support Dataset (AY, DY, TY)",
      name == "UCDP External Support Dataset - Actor Year" ~ "UCDP External Support Dataset (AY, DY, TY)",
      TRUE ~ as.character(name)
    )) %>%
    mutate(name = case_when(
      name == "UCDP Conflict Termination Dataset, Dyadic Level Version 3-2021" ~ "UCDP Conflict Termination Dataset, Dyadic and Conflilct Level",
      name == "UCDP Conflict Termination Dataset, Conflict Level Version 3-2021" ~ "UCDP Conflict Termination Dataset, Dyadic and Conflilct Level v.3-2021",
      TRUE ~ as.character(name)
    )) %>%
    #mutate(name = case_when(
      #name == "UCDP Intrastate Conflict Level Onset Dataset (Version 1)" ~ "UCDP Intrastate Conflict Level Onset Dataset (V1, V2 and Multiple)",
      #name == "UCDP Interstate Conflict Level Onset Dataset Version 1" ~ "UCDP Intrastate Conflict Level Onset Dataset (V1, V2 and Multiple)",
      #name == "UCDP Intrastate Conflict Level Onset Dataset (Version 2)" ~ "UCDP Intrastate Conflict Level Onset Dataset (V1, V2 and Multiple)",
      #name == "UCDP Interstate Conflict Level Onset Dataset Version 2" ~ "UCDP Intrastate Conflict Level Onset Dataset (V1, V2 and Multiple)",
      #name == "UCDP Intrastate Country Level Multiple Onset Dataset" ~ "UCDP Intrastate Conflict Level Onset Dataset (V1, V2 and Multiple)",
      #name == "UCDP Interstate Conflict Level Multiple Onset Dataset" ~ "UCDP Intrastate Conflict Level Onset Dataset (V1, V2 and Multiple)",
      #TRUE ~ as.character(name)
    #)) %>%
    mutate(name = case_when(
      name == paste("UCDP Battle-Related Deaths Dataset, Dyadic Level Version", UCDP_VERSION) ~ paste("UCDP Battle-Related Deaths Dataset, Dyadic and Conflilct Level", UCDP_VERSION),
      name == paste("UCDP Battle-Related Deaths Dataset, Conflict Level Version", UCDP_VERSION) ~ paste("UCDP Battle-Related Deaths Dataset, Dyadic and Conflilct Level", UCDP_VERSION),
      TRUE ~ as.character(name)
    )) %>%
    mutate(name = case_when(
      name == "UCDP Conflict Issues Dataset Version 23.2 (Dyad-Year)" ~ "UCDP Conflict Issues Dataset Version 23.2 (Dyad-Year, Dyad-Issue-Year)",
      name == "UCDP Conflict Issues Dataset Version 23.2 (Dyad-Issue-Year)" ~ "UCDP Conflict Issues Dataset Version 23.2 (Dyad-Year, Dyad-Issue-Year)",
      TRUE ~ as.character(name)
    )) %>%
    distinct(name, .keep_all = TRUE) %>%
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
    df <- df %>% filter(project == "ucdp")

    # Dumbbell
    plot <- ggplot(df, aes(y = reorder(name, min_year), x = min_year, xend = max_year)) +
      ggalt::geom_dumbbell(size = 2, color = "#CDC9C9",
                    colour_x = "#E4B4A2", 
                    colour_xend = "#C67858") +
      labs(x = "Year", 
           y = "Dataset", 
           title = "Year coverage per dataset",
           subtitle = "UCDP") +
      theme_minimal() +
      theme(panel.grid.major.x = element_line(size=0.05)) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      scale_x_continuous(breaks = seq(1940, 2025, 5),
                     limits=c(1940, 2025)) 

      return(plot)

}

plot <- year_coverage_ucdp("ucdp")
plot

ggsave(file.path(Sys.getenv("ROOT_DIR"), "figures/ds_year_coverage/ucdp.jpg"), width = 14, height = 8)
