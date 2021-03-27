## PROJECT:  nooga
## PURPOSE:  plot workouts leading up to 2019 Ironman Chattanooga
## AUTHOR:   A.Chafetz
## LICENSE:  MIT
## DATE:     2021-03-27
## NOTE:     influenced by and adapted from marcusvolz/strava 

#library
    library(tidyverse)
    library(lubridate)
    library(strava)
    library(janitor)
    library(glue)
    library(extrafont)
    library(ggtext)
    library(svglite)

#process all data from Strava bulk export
    df_strava<- process_data("data/gpx") %>% 
        as_tibble()
    
#filter to 2019 data
    df_strava<- df_strava%>% 
       filter(time >= "2019-01-01",
              time <= "2019-10-01") %>% 
        arrange(time)

#import list of activities by date and type
    df_summary <- read_csv("data/export_20247588/activities.csv") %>% 
        clean_names()

#filter to 2019 data
    df_summary <- df_summary %>% 
        mutate(activity_date = mdy_hms(activity_date)) %>% 
        filter(activity_date >= "2019-01-01",
               activity_date <= "2019-10-01")  %>% 
        arrange(activity_date) 
    
#filter columns
    df_summary <- df_summary %>% 
        select(activity_id:activity_type, 
               activity_elapsed_time = elapsed_time,
               activity_relative_effort = relative_effort,
               activity_distance_m = distance_1) %>% 
        mutate(activity_date_short =  activity_date %>% str_sub(6,10) %>% str_replace("-", "\\."),
               activity_start = activity_date)
    
#convert to imperial
    df_summary <- df_summary %>% 
        mutate(activity_distance_mi = 0.0006213712 * activity_distance_m,
               activity_distance_mi = round(activity_distance_mi, 1),
               activity_distance_yd = 1.093613 * activity_distance_m,
               activity_distance_yd = round(activity_distance_yd/100)*100
               ) 
    
#join information & fill down summary info
    df_join <- df_strava %>% 
        tidylog::full_join(df_summary, by = c("time" = "activity_date")) %>%
        fill(starts_with("activity")) %>% 
        arrange(time)
    
#adjust id (all 1 since one file from process_data())
    df_join <- df_join %>% 
        mutate(id = activity_id)

#clean up activity type
    df_join <- df_join %>% 
        filter(!activity_type %in% c("Hike", "Workout")) %>% 
        mutate(activity_type = ifelse(activity_type == "Ride", "Bike", activity_type))
    
#export
    write_csv(df_join, "data/activity_log.csv", na = "")
    
    
#replace missing coordinates w/ centroid pt (indoor activities)
    df_viz <- df_join %>% 
        mutate(is_indoor = is.na(lat),
               lat = ifelse(is.na(lat), 38.895, lat),
               lon = ifelse(is.na(lon), -77.03667, lon))
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
    
    ggsave("Images/activities_facet.svg", viz, dpi = 330,
           width = 8.5, height = 14, units = "in")
    
