## Analyse Birdnet Output data and viz

library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(lubridate)
library(stringr)
library(gt)

# read BirdNet_output
BirdNet_output <- read_csv(file.choose())
glimpse(BirdNet_output)

######################################################################
# sort wav_file names and data types

# Seperate wav_file into three columns
BirdNet_output <- BirdNet_output %>%
  separate(wav_file, c("unit_prefix", "date", "time"), sep = "_", remove = FALSE)


# Change column types and format data
BirdNet_output$unit_prefix <- as.factor(BirdNet_output$unit_prefix)

BirdNet_output <- BirdNet_output %>% 
  mutate_at(c("start_s", "end_s", "confidence"), as.numeric)

BirdNet_output <- BirdNet_output %>%
  mutate(time = str_remove(time, ".wav")) 

BirdNet_output <- BirdNet_output %>%
  mutate(date = ymd(date)) %>% 
  mutate(time = parse_time(time, "%H%M%S"))
  

glimpse(BirdNet_output)



##### results  summary #############

# Get species list
unique(BirdNet_output$common_name)

# Species list ordered by max confidence
conf_list <- BirdNet_output %>% 
  group_by(common_name) %>%
  summarise(confidence = max(confidence)) %>% 
  arrange(desc(confidence))


# Number of calls per species
phrase_list <- BirdNet_output %>% 
  group_by(common_name) %>%
  tally()

# Combine lists
species_list <- left_join(conf_list, phrase_list)

# Create table showing max confidence and number of phrases per species
species_list <- species_list %>%
  rename(Common_Name = common_name,
         Max_Confidence = confidence,
         Number_Phrases = n) %>% 
  arrange(desc(Number_Phrases))

species_list$Max_Confidence <- round(species_list$Max_Confidence,2)

# Add percentage of calls column
species_list$percent <- round(100*
                                (species_list$Number_Phrases/
                                   (nrow(BirdNet_output))),2)

species_list  

gt(species_list)

# Create table of species by date, with max confidence
BirdNet_output %>% 
  select(common_name, date, confidence) %>% 
  pivot_wider(names_from = date, values_from = confidence, values_fn = max)

# Create table of species by recorder site
species_recorder <- BirdNet_output %>% 
  group_by(common_name, unit_prefix) %>%
  tally() %>% 
  arrange(desc(n))

species_by_location <-species_recorder %>%
  pivot_wider(names_from = unit_prefix, values_from = n)

gt(species_by_location)

# Plot species graph  
ggplot(BirdNet_output, aes(x=date, y=common_name)) +
  geom_bin_2d() +
  theme_bw() +
  facet_wrap(~unit_prefix)
