## PROJECT:  nooga
## PURPOSE:  munge and join gpx and activity summary data leading up to 2019 Ironman Chattanooga
## AUTHOR:   A.Chafetz
## LICENSE:  MIT
## DATE:     2021-03-27
## UPDATED:  2021-05-29
## NOTE:     influenced by and adapted from marcusvolz/strava 

#library
    library(tidyverse)
    library(lubridate)
    library(janitor)

#training/racing period
    date_start <- "2019-01-01"
    date_end <- "2019-10-01"
    
#import processed gpx data
    df_strava <- read_csv("data/strava_gxp_transformed.csv")
    
#filter to 2019 data
    df_strava <- df_strava%>% 
       filter(time >= date_start,
              time <= date_end) %>% 
        arrange(time)

#import list of activities by date and type
    df_summary <- read_csv("data/export_20247588/activities.csv") %>% 
        clean_names()

#filter to training period
    df_summary <- df_summary %>% 
        mutate(activity_date = mdy_hms(activity_date)) %>% 
        filter(activity_date >= date_start,
               activity_date <= date_end)  %>% 
        arrange(activity_date) 
    
#filter columns
    df_summary <- df_summary %>% 
        select(activity_id:activity_type, 
               activity_elapsed_time = elapsed_time,
               activity_relative_effort = relative_effort,
               activity_distance_m = distance_1) %>% 
        mutate(activity_date_short =  activity_date %>% str_sub(6,10) %>% str_replace("-", "\\."),
               activity_start = activity_date)
    
#convert distances to imperial
    df_summary <- df_summary %>% 
        mutate(activity_distance_mi = 0.0006213712 * activity_distance_m,
               activity_distance_mi = round(activity_distance_mi, 1),
               activity_distance_yd = 1.093613 * activity_distance_m,
               activity_distance_yd = round(activity_distance_yd/100)*100) 
    
#join information & fill down summary info
    df_join <- df_strava %>% 
        tidylog::full_join(df_summary, by = c("time" = "activity_date")) %>%
        fill(starts_with("activity")) %>% 
        arrange(time)
    
#adjust id (all 1 in df_strava since one file from process_data())
    df_join <- df_join %>% 
        mutate(id = activity_id)

#clean up activity type
    df_join <- df_join %>% 
        filter(!activity_type %in% c("Hike", "Workout")) %>% 
        mutate(activity_type = ifelse(activity_type == "Ride", "Bike", activity_type))
    
#export
    write_csv(df_join, "data/activity_log.csv", na = "")