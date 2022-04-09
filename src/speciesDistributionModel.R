# Spidertail
# This code creates a species distribution model
# It runs the code in setup.R and horsetail-sdm-single.R
# to help with the process

# Alot of this code is written by Jeff Oliver
# Thank you Jeff Oliver for your code 
# (https://github.com/jcoliver/biodiversity-sdm-lesson)

# This link is used to installs libraries, and 
# it downloads climate data from bioclim 
# (https://www.worldclim.org/data/bioclim.html)

# This installs libraries, and downloads climate 
# data from bioclim 
# (https://www.worldclim.org/data/bioclim.html)

source(file = "src/setup.R")

# query the horsetail data to plot
horsetail<-occ(query='Asclepias subverticillata', from="gbif", gbifopts = list(year="2020"))

#navigate to the object
horsetailData<-horsetail$gbif$data$Asclepias_subverticillata

# create a csv
horsetailData <- apply(horsetailData,2,as.character)

# write the data to the csv and save it to the data folder
write.csv(horsetailData, "data/horsetail.csv")

# run the code in horsetail-sdm-single.R 
# the map will now be created and saved in the output folder
source("src/horsetail-sdm-single.R")