# BirdNET-Analyzer Compile Output Script
# Carlos Abrahams"

# See GitHub page at https://github.com/kahst/BirdNET-Analyzer

# @article{kahl2021birdnet,
#  title={BirdNET: A deep learning solution for avian diversity monitoring},
#  author={Kahl, Stefan and Wood, Connor M and Eibl, Maximilian and Klinck, Holger},
#  journal={Ecological Informatics},
#  volume={61},
#  pages={101236},
#  year={2021},
#  publisher={Elsevier}
#}

######

######library(purrr)
library(dplyr)
library(stringr)
library(readr)
library(tidyr)
library(janitor)

# Provide folder path for BN_Output if needed
#out_path <- "/media/carlos/G-Drive/1632_MarchBaitings/Output"


# Create single spreadsheet of results
results_paths <- list.files(out_path, pattern = '.csv', 
                            full.names = TRUE, recursive = TRUE)

# How many wavs were included in dataset?
number_of_wavs <- length(results_paths)

# Create dataframe
BirdNet_output <- map_df(results_paths,
                         ~read_csv(.x, 
                              col_names = TRUE, 
                              skip_empty_rows = TRUE,
                              col_types = "ccccc") %>%
         mutate(file_path = str_remove_all(.x, ".BirdNET.results.csv")))

# Clean column names and check output
BirdNet_output <- clean_names(BirdNet_output, case = "screaming_snake")
glimpse(BirdNet_output)

# Remove excess file path after last / to keep filename only
BirdNet_output$IN_FILE <- sub(".*/", "", BirdNet_output$FILE_PATH)

# add ".wav to end of IN FILE filenames
# watch for differences in .wav and .WAV between audiomoth and SM filenames
BirdNet_output$IN_FILE <- paste(BirdNet_output$IN_FILE,".wav", sep="")

# Add blank manual ID column
BirdNet_output$MANUAL_ID <- NA

# Save birdnet combined dataframe as csv
write_csv(BirdNet_output, paste(out_path,"/BirdNet_output.csv", sep = ""))


