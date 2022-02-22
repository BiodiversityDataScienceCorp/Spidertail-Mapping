# "Comment the bejesus out of this file" - Jeremy, 2/22/22

# This document is for migrating code over and commenting/sectioning through

### THIS SECTION IS FOR LOADING NECESSARY PACKAGES

library("spocc")
library("sp")
library("raster")
library("maptools")
library("rgdal")
library("dismo")
library("sf")
library("tidyverse")

##### Code for the creation of our species occurence map #####

### THIS SECTION IS WHERE DATA IS PULLED AND CLEANED

# First pull and view of the data
horsetail <- occ(query='Asclepias subverticillata', from='gbif', limit=1000)
horsetail
horsetailData = horsetail$gbif$data$Asclepias_subverticillata
horsetailData

# Filtering out of entries where occurrenceStatus=="Absent"
unique(horsetailData$occurrenceStatus)
absent <- subset(x=horsetailData, occurrenceStatus !="PRESENT")
absent
# note anti_join is in the tidyverse, it was not originally called
horsetailData <- anti_join(horsetailData, absent)
horsetailData

# Filtering out of entries where individualCount==0 or NA
unique(horsetailData$individualCount)
zeroHorsetail<-subset(horsetailData, individualCount==0)
horsetailData<-anti_join(horsetailData, zeroHorsetail)
NAHorsetail<-subset(horsetailData, is.na(individualCount))
horsetailData<-anti_join(horsetailData, NAHorsetail)
horsetailData

# Filtering out of entries where latitude/longitude are NA
# (where latitude==NA, longitude==NA so I only used latitude)
NALat<-subset(horsetailData, is.na(latitude))
horsetailData<-anti_join(horsetailData, NALat)
horsetailData
# plot data to see if anything seemed off
wm <- borders("world", colour="gray50", fill="gray50")
ggplot()+ coord_fixed()+ wm +
  geom_point(data = horsetailData, aes(x = longitude, y = latitude),
             colour = "darkred", size = 1.0)+
  theme_bw()
# Nothing seemed out of reasonable range, though not all data lied within AZ

### THIS SECTION IS WHERE DATA IS PREPARED TO MAP AND MAPPED

# Reduction of data columns and saving as CSV
#here I list the columns I think we should keep, and create a reduced data set
reducedhorsetailData<-select(horsetailData, c(name, longitude, latitude, stateProvince, year, month, day, eventDate, individualCount))
reducedhorsetailData
#now I make a csv file. Sammy hasn't yet cleaned out the NA lat/long rows, so I won't do it yet. Here's the code we'll use
write_csv(reducedhorsetailData, "reducedhorsetail.csv")

# Data read from CSV and lat/long set
horsetailFromCSV = read_csv("reducedhorsetail.csv")
horsetailFromCSV
# find the boundaries for latitude and longitude
max.lat <- ceiling(max(horsetailFromCSV$latitude))
min.lat <- floor(min(horsetailFromCSV$latitude))
# run same calculations for longitude
max.lon <- ceiling(max(horsetailFromCSV$longitude))
min.lon <- floor(min(horsetailFromCSV$longitude))

# Creation of the actual map
# now make the actual map
jpeg(file="map.jpg")
# loads spatial polygons
data(wrld_simpl)
# Plot the base map
plot(wrld_simpl, 
     xlim = c(min.lon, max.lon), # sets upper/lower x
     ylim = c(min.lat, max.lat), # sets upper/lower y
     axes = TRUE, 
     col = "grey95",
     main="Horsetail Milkweek Occurances",  # a title
     sub="an informative caption" # a caption
)
# Add the points for individual observation
points(x = horsetailFromCSV$longitude, 
       y = horsetailFromCSV$latitude, 
       col = "lightpink3", 
       pch = 20, 
       cex = 0.75)
# And draw a little box around the graph
box()
# indicates I'm done with plotting and saving to jpg
dev.off()