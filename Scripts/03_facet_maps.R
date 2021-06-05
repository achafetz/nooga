## PROJECT:  nooga
## PURPOSE:  plot workouts leading up to 2019 Ironman Chattanooga
## AUTHOR:   A.Chafetz
## LICENSE:  MIT
## DATE:     2021-03-27
## UPDATED:  2021-05-29
## NOTE:     influenced by and adapted from marcusvolz/strava 

#library
    library(tidyverse)
    library(lubridate)
    library(glue)
    library(extrafont)
    library(ggtext)
    library(emojifont)
    library(fontawesome)
    # library(svglite)

#read in munged data
    df_viz <- read_csv("data/activity_log.csv")
    
#replace missing coordinates w/ centroid pt (indoor activities)
    df_viz <- df_viz %>% 
        mutate(is_indoor = is.na(lat),
               lat = ifelse(is.na(lat), 38.895, lat),
               lon = ifelse(is.na(lon), -77.03667, lon))

#limit large activities (issues in Illustrator)
    df_viz <- df_viz %>%  
        group_by(activity_id) %>% 
        mutate(n = n(),
               row = row_number()) %>% 
        ungroup() %>%
        mutate(keep = ifelse(n > 10000 & (row %% 3 != 0), FALSE, TRUE)) %>% 
        filter(keep == TRUE) %>% 
        select(-keep)
    
#colors
    df_viz <- df_viz %>% 
        mutate(nooga_pal = case_when(activity_type == "Swim" ~ "#588AA4",
                                    activity_type == "Bike" ~ "#086864",
                                    activity_type == "Run" ~ "#202020",
                                    TRUE ~ "red"))
    
#title
    df_viz <- df_viz %>% 
        mutate(activity_distance_display = ifelse(activity_type == "Swim", glue("{activity_distance_yd}yd"), glue("{activity_distance_mi}mi")),
               facet_title = glue("<span style = 'font-size:7pt; font-family:Lato; font-face:Bold; color:{nooga_pal}'>{activity_distance_display}</span><br>
                                  <span style = 'font-size:5pt; font-family:Lato; font-face:Light; color:{nooga_pal}'>{activity_date_short} {activity_type}</span>"))
    
    viz <- df_viz %>% 
        ggplot(aes(lon, lat, color = nooga_pal, group = activity_id)) +
        geom_path(size = 0.35, lineend = "round", na.rm = TRUE) +
        facet_wrap(~fct_reorder(facet_title, activity_start, min), scales = "free", strip.position = "bottom") +
        scale_color_identity() +
        theme_void() +
        theme(panel.spacing = unit(.5, "lines"),
              strip.background = element_blank(),
              legend.position = "none",
              strip.text = element_markdown(),
              plot.margin = unit(rep(1, 4), "cm"))
    
    ggsave("Images/activities_facet.png", viz, dpi = 330,
           width = 8.5, height = 14, units = "in")
    
    ggsave("Graphics/activities_facet.svg", viz, dpi = 330,
           width = 8.5, height = 14, units = "in")
    
