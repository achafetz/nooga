# nooga
map all 2019 workouts/races leading up to Ironman Chattanooga

**Steps**
- [Bulk export activities from Strava account](https://support.strava.com/hc/en-us/articles/216918437-Exporting-your-Data-and-Bulk-Export) and store in `data/`
- Unzip bulk export file - `data/export_*`
- Each `fit` file (in `data/export_*/activities/`) is compressed; unzip each 
- Download [GPSBabel](http://www.gpsbabel.org/download.html) to convert all fit files to gpx format
- Within GPSBabel, choose the input format - "Flexible and Interoperable Data Transfer (FIT) Activity file" and select all fit files in `data/export_*/activities/`
- Next within GPSBabel, change the output format to `GPX XML` and create save as `data/gpx/all_strava_fit.gpx/`
- Import data using [`strava` package](https://github.com/marcusvolz/strava)
