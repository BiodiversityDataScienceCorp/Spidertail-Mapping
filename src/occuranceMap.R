# Spidertail Occurrence map
# This code creates the occurrence map of the horsetail milkweed

# Load needed packages

library("spocc")
library("sp")
library("raster")
library("maptools")
library("rgdal")
library("dismo")
library("sf")
library("tidyverse")
library("dplyr")
library("tidyr")


### Pull and clean data

# note, the inaturalist data does not have the same column 
# names as gbif, and cannot be cleaned using the same steps

# First pull and view of the data
horsetail <- occ(query='Asclepias subverticillata', from=c('gbif','inat'), limit=5000)
horsetail
horsetailDataG = horsetail$gbif$data$Asclepias_subverticillata
horsetailDataI = horsetail$inat$data$Asclepias_subverticillata

# Filtering out of entries where occurrenceStatus=="Absent"
unique(horsetailDataG$occurrenceStatus)
absent <- subset(x=horsetailDataG, occurrenceStatus !="PRESENT")
absent

# edit the dataframe to not have absent data
horsetailDataG <- anti_join(horsetailDataG, absent)
horsetailDataG

# Filtering out entries where individualCount==0 or NA
unique(horsetailDataG$individualCount)
zeroHorsetail<-subset(horsetailDataG, individualCount==0)
horsetailDataG<-anti_join(horsetailDataG, zeroHorsetail)

NAHorsetail<-subset(horsetailDataG, is.na(individualCount))
horsetailDataG<-anti_join(horsetailDataG, NAHorsetail)

# Filtering out entries where latitude/longitude are NA
# (where latitude==NA, longitude==NA so I only used latitude)
NALat<-subset(horsetailDataG, is.na(latitude))
horsetailDataG<-anti_join(horsetailDataG, NALat)
horsetailDataG

NALat<-subset(horsetailDataI, is.na(location))
horsetailDataI<-anti_join(horsetailDataI, NALat)
horsetailDataI

# plot data to see if anything seemed off
wm <- borders("world", colour="gray50", fill="gray50")
ggplot()+ coord_fixed()+ wm +
  geom_point(data = horsetailDataG, aes(x = longitude, y = latitude),
             colour = "darkred", size = 1.0)+
  theme_bw()
# Nothing seemed out of reasonable range, though not all data lied within AZ


### Prepare the data to be mapped and  map the data

# Reduction of data columns and saving as CSV
# create a reduced data set of the most important columns
reducedhorsetailData<-select(horsetailDataG, c(name, longitude, latitude, stateProvince, year, month, day, eventDate, individualCount))

#now make a csv file. 
write_csv(reducedhorsetailData, "data/reducedhorsetail.csv")

# Data read from CSV
horsetailFromCSV = read_csv("data/reducedhorsetail.csv")
horsetailFromCSV

# combine the gbif and inat data into one data frame 
# the columns shared are latitude and longitude 
# so the data sets will be combined on those columns
# and then plotted
tempGbif <- select(horsetailDataG,c("longitude", "latitude"))
tempInat <- select(horsetailDataI, "location")

# the inat data puts lat and long into one column so
# split into separate lat and long columns
tempInat <- tempInat %>%
  separate(location, c("latitude", "longitude"), ",")

# make numerical
tempInat$longitude = as.numeric(tempInat$longitude)
tempInat$latitude = as.numeric(tempInat$latitude)

# now combine the data frames
horsetailData <- rbind(tempGbif, tempInat)

# remove duplicate rows
horsetailData <- distinct(horsetailData)

# create a csv of the combined data
write_csv(horsetailData, "data/combinedHorsetailData.csv")

# This section creates the map

# find the boundaries for latitude and longitude
max.lat <- ceiling(max(horsetailData$latitude))
min.lat <- floor(min(horsetailData$latitude))

# run same calculations for longitude
max.lon <- ceiling(max(horsetailData$longitude))
min.lon <- floor(min(horsetailData$longitude))

# Creation of the actual map
jpeg(file="output/OccuranceMap.jpg")
# loads spatial polygons
data(wrld_simpl)
# Plot the base map
plot(wrld_simpl, 
     xlim = c(min.lon, max.lon), # sets upper/lower x
     ylim = c(min.lat, max.lat), # sets upper/lower y
     axes = TRUE, 
     col = "grey95",
     main="Horsetail Milkweed Occurances",  # a title
     sub="Where are the Horsetail Milkweed" # a caption
)
# Add the points for individual observation
points(x = horsetailData$longitude, 
       y = horsetailData$latitude, 
       col = "lightpink3", 
       pch = 20, 
       cex = 0.75)
# And draw a little box around the graph
box()
# indicates I'm done with plotting and saving to jpg
dev.off()