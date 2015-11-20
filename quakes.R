
# install and load htmlwidgets
install.packages("htmlwidgets")
library(htmlwidgets)

# install and load leaflet
install.packages("leaflet")
library(leaflet)

# install and load rgdal
install.packages("rgdal")
library(rgdal)

# load seismic risk shapefile
seismic_risk <- readOGR("seismic_risk_clip", "seismic_risk_clip")

# load quakes data from USGS earthquakes API
quakes <- read.csv("http://earthquake.usgs.gov/fdsnws/event/1/query?starttime=1965-01-01T00:00:00&minmagnitude=6&format=csv&latitude=39.828175&longitude=-98.5795&maxradiuskm=6000&orderby=magnitude")

# make leaflet map using seismic risk data
seismic_map <- leaflet(data=seismic_risk)

# set breaks for custom bins
breaks <- c(0,19,39,59,79,200)

# set palette
binpal <- colorBin("Reds", seismic_map$ACC_VAL, breaks)

# make multi-layered leaflet map with layer-switching control
# make choropleth map of seismic hazards
seismic <- seismic_map %>%
  setView(lng = -98.5795, lat = 39.828175, zoom = 4) %>%
  addProviderTiles("CartoDB.Positron", group = "CartoDB") %>% 
  addProviderTiles("Stamen.TonerLite", group = "Toner") %>%
  addPolygons(
    stroke = FALSE, fillOpacity = 0.7, 
    smoothFactor = 0.1,
    color = ~binpal(ACC_VAL)
  ) %>%
  # add historical quakes
  addCircles(
    data=quakes, 
    radius = sqrt(10^quakes$mag)*50, 
    weight = 0.2, 
    color = "#000000", 
    fillColor ="#ffffff",
    fillOpacity = 0.3,
    popup = paste0("<strong>Magnitude: </strong>", quakes$mag, "</br>",
                   "<strong>Date: </strong>", format(as.Date(quakes$time), "%b %d, %Y")),
    group = "Quakes"
  ) %>%
  # add legend
  addLegend(
    "bottomleft", pal = binpal, values = ~ACC_VAL,
    title = "Seismic risk",
    opacity = 0.7
  ) %>%
  # add layers control
  addLayersControl(
    baseGroups = c("CartoDB", "Toner"),
    overlayGroups = "Quakes",
    options = layersControlOptions(collapsed = FALSE)
  )

# draw the map
seismic

# save the map
saveWidget(seismic, "seismic.html", selfcontained = TRUE, libdir = NULL,
           background = "white")






