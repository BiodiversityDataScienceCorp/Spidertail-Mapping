# Project Description:
### This project aims to support Monarch butterfly conservation by modeling a species of milkweed in the southwest of North America. Using publicly available occurence data of the horsetail milkweed species (*Asclepius subverticillata*) from GBIF and iNaturalist, as well as current and future climate data, we forecast current and future distribution of the horsetail milkweed.
# Scripts Used:
### occurenceData.R contains the code that will create an occurence map using GBIF and iNaturalist data; run this script itself
### horsetail-sdm-single.R contains the code that creates a current species distribution model map; to execute, run FILE NAME
### horsetail-future-sdm-single.R contains the code that creates a future species distribution model map using projected climate data; to execute, run FILE NAME
### sdm-functions.R contains code that produces the species distribution models themselves; both horsetail-sdm-single.R and horsetail-future-sdm-single.R call on this file, no need to run on its own
# Folders/Github organization:
### src folder contains all of the scripts/code necessary to create deliverables
### data folder contains all of the data pulled from GBIF and iNat
### output folder contains final deliverables
# Packages Used:
### spocc, sp, raster, maptools, rgdal, dismo, sf, tidyverse
