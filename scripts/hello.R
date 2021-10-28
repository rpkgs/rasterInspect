# Project for leaflet
library(sp)
library(sf2)

prj <- CRS(SRS_string = "EPSG:4326")
# prj_web <- CRS(SRS_string = "EPSG:3857")
r <- get_grid(range = c(70, 140, 15, 55), cellsize = 1, prj = prj) %>% raster::raster()
# r <- brick(r, r)
rasterInspector(r)
