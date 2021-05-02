# load library ------------------------------------------------------------

library(leaflet)
library(tidyverse)
library(dplyr)


# make leaflet plot -------------------------------------------------------

map <- leaflet(second_medarea_rgdal) %>%
  addTiles() %>%
  setView(lng=139.6,lat=35.6,zoom=10) %>%
  # add total population mesh by red
  addRectangles(lng1 = df_popmesh$lng1,
                lat1 = df_popmesh$lat1,
                lng2 = df_popmesh$lng2,
                lat2 = df_popmesh$lat2,
                stroke = FALSE,
                color = '#F00',
                fillOpacity = df_popmesh$total_pop_opacity,
                group = 'total population') %>%
  # add age 16~64 population mesh by green
  addRectangles(lng1 = df_popmesh$lng1,
                lat1 = df_popmesh$lat1,
                lng2 = df_popmesh$lng2,
                lat2 = df_popmesh$lat2,
                stroke = FALSE,
                color = '#0F0',
                fillOpacity = df_popmesh$B_pop_opacity,
                group = '16~64 population') %>%
  # add age 65~ population mesh by green
  addRectangles(lng1 = df_popmesh$lng1,
                lat1 = df_popmesh$lat1,
                lng2 = df_popmesh$lng2,
                lat2 = df_popmesh$lat2,
                stroke = FALSE,
                color = '#00F',
                fillOpacity = df_popmesh$C_pop_opacity,
                group = '65~ population') %>%
  # add secondary medical area polygons
  addPolygons(stroke = TRUE,
              fill = TRUE,
              fillOpacity = 0.1,
              smoothFactor = 0.3,
              label = iconv(second_medarea_rgdal$A38b_004, from='utf8',to='cp932'),
              group = 'secondary medical area') %>%
  # add DPC hospital markers
  addCircleMarkers(lng = df_hosp$longitude,
                   lat = df_hosp$latitude,
                   label = df_hosp$name,
                   radius = df_hosp$num_DPC_bed/max(df_hosp$num_DPC_bed)*10)

# add hospital density
# http://blog.isharadata.com/2017/03/adding-multiple-polygons-via-loop-in-r.html
for (i in seq(length(lines))){
  map <- map %>% addPolygons(lng=lines[[i]]$x,
                             lat=lines[[i]]$y,
                             fillColor = "red",
                             stroke = FALSE,
                             fillOpacity = 0.2,
                             group = 'HospitalDensity')
}

# add layer control panel
map <- map %>% addLayersControl(overlayGroups = c('total population',
                                                  '16~64 population',
                                                  '65~ population',
                                                  'secondary medical area',
                                                  'HospitalDensity')) %>%
  # set hiding layer as default
  # https://rstudio.github.io/leaflet/showhide.html
  hideGroup(c('16~64 population',
              '65~ population',
              'HospitalDensity'))


# show map ----------------------------------------------------------------

map
