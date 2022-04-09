# Spidertail
# This code creates a future species distribution model
# It runs the code in setup.R and horsetail-future-sdm-single.R
# to help with the process

# A lot of this code was written by Jeff Oliver
# Thank you Jeff Oliver for your code 
# (https://github.com/jcoliver/biodiversity-sdm-lesson)

# This installs libraries, and downloads climate data from 
# bioclim (https://www.worldclim.org/data/bioclim.html)

source(file = "src/setup.R")

# query the horsetail data
horsetail<-occ(query='Asclepias subverticillata', from="gbif", gbifopts = list(year="2020"))

#navigate to the object
horsetailData<-horsetail$gbif$data$Asclepias_subverticillata

# make sure everything is character data
horsetailData <- apply(horsetailData,2,as.character)

# write the data into a csv
write.csv(horsetailData, "data/horsetail.csv")

# run the code in horsetail-future-sdm-single.R to 
# create the map, it will be saved in the output folder
source("src/horsetail-future-sdm-single.R")