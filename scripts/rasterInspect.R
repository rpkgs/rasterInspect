#! /usr/bin/Rscript --no-init-file
# Dongdong Kong ----------------------------------------------------------------
# Copyright (c) 2021 Dongdong Kong. All rights reserved.

# library(sp)
# library(sf2)

# prj <- CRS(SRS_string = "EPSG:4326")
# prj_web <- CRS(SRS_string = "EPSG:3857")
# r <- get_grid(range = c(70, 140, 15, 55), cellsize = 1, prj = prj) %>% raster::raster()
# job::job(rasterInspect(r))
library(rasterInspect)

file = Ipaper::path.mnt("e:/MOD13A2_Henan_Pheno_Beck_2015_1.tif")
r = raster(file)
rasterInspect(r, port = 81)
