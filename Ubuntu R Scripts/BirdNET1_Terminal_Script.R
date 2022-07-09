# BirdNET-Analyzer Terminal Script
# Carlos Abrahams
###
# Analyse audio data using BirdNET Analyzer from Cornell

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
library(stringr)
###########################################################

# Provide coordinates for site
lat_co <- 53.5998  # Add lat coords or provide -1 if no coords
lon_co <- -1.9301  # Add long coords or provide -1 if no coords

# Marsden = 53.5998° N, 1.9301° W

# Provide input and output folder paths
in_path <- "/media/carlos/G-Drive/1632_MarchBaitings/Data"
out_path <- "/media/carlos/G-Drive/1632_MarchBaitings/Output"
#out_path <- "/media/carlos/G-Drive/ReNature/BN_Output"
#in_path <- "/media/carlos/G-Drive/ReNature/Audio_Data"

############################################################
# Create command line string
command_string <- str_c("python3 ~/BirdNET-Analyzer/analyze.py ",
                        " --i ", in_path,
                        " --o ", out_path,
                        " --lat ", lat_co,
                        " --lon ", lon_co,
                        " --slist ~/BirdNET-Analyzer/British_species_list/ ",
                        " --min_conf 0.75 ",
                        " --threads 4 ",
                        " --rtype csv")

system(command_string)

###########################################################
# Run segments line if species phrase segments are required

segments_string <- str_c("python3 ~/BirdNET-Analyzer/segments.py ", 
                         " --audio ", in_path,
                         " --results ", out_path,  
                         " --o ", out_path, 
                         " --max_segments 10 --threads 4")

system(segments_string)

############################################################
