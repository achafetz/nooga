## PROJECT:  nooga
## PURPOSE:  process gpx file
## AUTHOR:   A.Chafetz
## LICENSE:  MIT
## DATE:     2021-03-27
## NOTE:     influenced by and adapted from marcusvolz/strava 

#library
library(tidyverse)
library(strava)

#process all data from Strava bulk export
    df_strava <- process_data("data/gpx") %>% 
        as_tibble()

#store as a csv
    write_csv(df_strava, "data/strava_gxp_transformed.csv", na = "")
    