# Script to convert transect GPX track to CSV - to combine with bird IDs

# library packages
library(sf)
library(dplyr)
library(ggplot2)
library(readr)

##### Import gpx file ####
# Provide filename
filename <- "Morning_Run.gpx"

# Check layers
st_layers(filename)

# Import track_points
track_points <- st_read(filename, layer = "track_points")

# Select useful columns
track_points_2 <- select(track_points, track_seg_point_id, time, geometry)

#Convert single geometry column to separate lat and long columns
lat_long <- as_tibble(st_coordinates(track_points_2))

#Add together
track_points_2 <- bind_cols(track_points_2, lat_long)
#Ditch unneeded columns
track_points_2 <- select(track_points_2, time, X, Y)

#Check GPX data by plot
ggplot(track_points_2, aes(x=X, y=Y, colour=time)) +
  geom_point()

####### Import csv with Bird IDs and date/time
Bird_ID <- read_csv("Bird_Test_Data.csv", 
                           col_types = cols(DATE = col_date(format = "%d/%m/%Y"), 
                                            TIME = col_time(format = "%H:%M:%S")))

# Create datetime column
Bird_ID$datetime <- as.POSIXct(stringr::str_c(Bird_ID$DATE, " ", Bird_ID$TIME))

# Combine Bird_IDs with lat_long data
Bird_ID <- left_join(Bird_ID, track_points_2, by = c("datetime" = "time"))

###### Combine with BTO codes ######
#Import bto codes
BTOcodes <- read_csv("BTOcodes.csv")

# Combine Bird_ID with BTO codes
Bird_ID <- left_join(Bird_ID, BTOcodes)

# Check data by plot
ggplot() +
  geom_point(data = track_points_2, aes(x=X, y=Y, colour = time), size= 0.5, alpha = 0.1) +
  geom_text(data=Bird_ID, aes(x=X, y=Y, label=bto_code), fontface = "bold") +
  theme_bw()


