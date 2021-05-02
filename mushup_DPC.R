# load library ------------------------------------------------------------

library(tidyverse)
library(dplyr)
library(KernSmooth)
library(leafletR)
library(jsonlite)
library(geojsonio)
library(rgdal)


# create hospital data ----------------------------------------------------

latlon_hosp <- scan('R/dpc_map/DPChospital_tokyo.csv', # please change fitting for your environment
                    what = character(),
                    sep = "\n",
                    blank.lines.skip = F,
                    quote = "\"'",
                    encoding = 'UTF-8') %>%
  lapply(function(x){
    splitted <- strsplit(x, ',')
    return(data.frame(name=splitted[[1]][1],
                      longitude=as.numeric(splitted[[1]][4]),
                      latitude=as.numeric(splitted[[1]][5])))
  }) %>%
  bind_rows()

num_bed_hosp <- read.csv('R/dpc_map/num_bed.csv',encoding = 'UTF-8') # please change fitting for your environment
df_hosp <- merge(latlon_hosp, num_bed_hosp)


# create contour, i.e. hispital density -----------------------------------

# make contour
# http://technocyclist.blogspot.com/2014/10/plot-contour-polygons-in-leaflet-using-r.html
# https://www.rdocumentation.org/packages/KernSmooth/versions/2.23-18/topics/bkde2D
# https://rpubs.com/freakonometrics/69270

d2d <- bkde2D(cbind(df_hosp$longitude,df_hosp$latitude),bandwidth=c(0.0225,0.0225))
contour(d2d$x1,d2d$x2,d2d$fhat)
lines <- contourLines(x=d2d$x1, y=d2d$x2, z=d2d$fhat,nlevels = 16)


# create population mesh data ---------------------------------------------

popmesh <- fromJSON('R/dpc_map/1km_mesh_2018_13.geojson')   # please change fitting for your environment

# coordinate to dataframe
df_coordinate <- lapply(popmesh$features$geometry$coordinates, function(x){
  return(data.frame(lng1 =x [1],
                    lat1 =x [6],
                    lng2 =x [3],
                    lat2 =x [8]))
}) %>% bind_rows()

df_popmesh <- data.frame(mesh_id = popmesh$features$properties$MESH_ID,
                         total_pop = popmesh$features$properties$PTN_2020,
                         A_pop = popmesh$features$properties$PTA_2020,
                         B_pop = popmesh$features$properties$PTB_2020,
                         C_pop = popmesh$features$properties$PTC_2020,
                         df_coordinate)
df_popmesh$total_pop_opacity <- df_popmesh$total_pop/max(df_popmesh$total_pop)
df_popmesh$B_pop_opacity <- df_popmesh$B_pop/max(df_popmesh$B_pop)
df_popmesh$C_pop_opacity <- df_popmesh$C_pop/max(df_popmesh$C_pop)


# create secondary medical area polygion data -----------------------------

second_medarea_rgdal <- readOGR('R/dpc_map/A38-14_13_2_reduce.json', encoding = "UTF8") # please change fitting for your environment
