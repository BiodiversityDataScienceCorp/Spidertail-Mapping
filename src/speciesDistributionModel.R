## This code creates the species distribution model
# Thank you Jeff Oliver for your code 
# (https://github.com/jcoliver/biodiversity-sdm-lesson)

# This installs libraries, and downloads climate data from bioclim 
# (https://www.worldclim.org/data/bioclim.html)

source(file = "src/setup.R")

# spocc/gbif query then 
# creating a variable targeting the data set 

horsetail<-occ(query='Asclepias subverticillata', from="gbif", gbifopts = list(year="2020"))
horsetailData<-horsetail$gbif$data$Asclepias_subverticillata

# Saving this query to a csv

# ensure all data is character data
horsetailData <- apply(horsetailData,2,as.character)

# use write.csv to write the data frame to 'data' directory
write.csv(horsetailData, "data/horsetail.csv")

# the file src/horsetail-sdm-single.R contains the code that makes the actual
# map, view that code for an in depth look at how this takes place, and run this
# code to see the output
source(file = "src/horsetail-sdm-single.R")
