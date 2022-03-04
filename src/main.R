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
library("dplyr")
library("tidyr")

##### Code for the creation of our species occurence map #####

### THIS SECTION IS WHERE DATA IS PULLED AND CLEANED
# note, the inat data does not have the same column names as gbif, and
# cannot be cleaned using the same steps

# First pull and view of the data
horsetail <- occ(query='Asclepias subverticillata', from=c('gbif','inat'), limit=5000)
horsetail
horsetailDataG = horsetail$gbif$data$Asclepias_subverticillata
horsetailDataI = horsetail$inat$data$Asclepias_subverticillata

# Filtering out of entries where occurrenceStatus=="Absent"
unique(horsetailDataG$occurrenceStatus)
absent <- subset(x=horsetailDataG, occurrenceStatus !="PRESENT")
absent

# note anti_join is in the tidyverse, it was not originally called
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


### THIS SECTION IS WHERE DATA IS PREPARED TO MAP AND MAPPED

# Reduction of data columns and saving as CSV
#here I list the columns I think we should keep, and create a reduced data set
reducedhorsetailData<-select(horsetailDataG, c(name, longitude, latitude, stateProvince, year, month, day, eventDate, individualCount))

#now make a csv file. 
write_csv(reducedhorsetailData, "reducedhorsetail.csv")

# Data read from CSV
horsetailFromCSV = read_csv("reducedhorsetail.csv")
horsetailFromCSV

# combine the gbif and inat data into one data frame with just lat and 
# long to plot
df1 <- select(horsetailDataG,c("longitude", "latitude"))
df2 <- select(horsetailDataI, "location")

# split into lat and long
df2 <- df2 %>%
  separate(location, c("latitude", "longitude"), ",")

# make numerical
df2$longitude = as.numeric(df2$longitude)
df2$latitude = as.numeric(df2$latitude)

# now combine the data frames
horsetailData <- rbind(df1, df2)

# now that we have the inat data, we will use that instead of the csv data

# find the boundaries for latitude and longitude
max.lat <- ceiling(max(horsetailData$latitude))
min.lat <- floor(min(horsetailData$latitude))

# run same calculations for longitude
max.lon <- ceiling(max(horsetailData$longitude))
min.lon <- floor(min(horsetailData$longitude))

# Creation of the actual map
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

## THIS SECTION IS WHERE OUR SPECIES DISTRIBUTION MODEL IS CREATED

# Your Turn!!!
# Thank you Jeff Oliver for your code (https://github.com/jcoliver/biodiversity-sdm-lesson)

########################### 1. Run the setup code below ####################################
# This installs libraries, and downloads climate data from bioclim (https://www.worldclim.org/data/bioclim.html)

source(file = "src/setup.R")

############### 2. In the "src" directory, copy the contents of "run-sdm-single.R" ##############
# into a new file (still in 'src') called <species>-sdm-single.R (Rename <species> to your milkweed)

# 3. In this new file, edit lines 14 & 15, changing MY_SPECIES to your milkwood species.

# 4. Below, write your spocc/gbif query, 
# and then use the "$" notation to create a variable targeting the data set. 

horsetail<-occ(query='Asclepias subverticillata', from="gbif", gbifopts = list(year="2020"))
horsetailData<-horsetail$gbif$data$Asclepias_subverticillata

################ 5. Save to CSV #####################

# first, ensure all data is character data
#df <- apply(df,2,as.character)

horsetailData <- apply(horsetailData,2,as.character)

# use write.csv to write the data frame to 'data' directory
# make sure the file name matches what you indicated in step 3 on line 14

write.csv(horsetailData, "data/Horsetail.csv")

# 6. Use the source() command to run the file you created in step 2 ############

source("src/horsetail-sdm-single.R")