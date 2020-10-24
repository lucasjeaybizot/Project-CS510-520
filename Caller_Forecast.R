# NON-FUNCTIONAL: Please run each script independently [IN DEVELOPMENT]

## Author: Lucas Jeay-Bizot
## Created: 24/10/2020
## Last modified: 24/10/2020
#
#### Function: This code will call generation of different datasets and analyse them to construct a forecast map
#
# NOTE 1: please see project.pdf and README files for further information
# NOTE 2: This code is still in development. Only model A (with convolution) and basic forecast_matrix.R functional

#### #### ####
#### INPUT ####
#
## model A
# 
# EEG_values.csv <- a csv file with subject-specific EEG parameters 
# RP_data.csv <- a csv file with grand average RP
#
## model B [IN DEVELOPMENT]
#
# EEG_values.csv <- a csv file with subject-specific EEG parameters
#
## EEG data [IN DEVELOPMENT]
#
# datafile.* <- 

#### OUTPUT ####
#
# forecast_map_proba -> matrix of probability of Event in the future
#
##### ##### #####


#### #### ####
## Set variables [IN DEVELOPMENT]
#
#
#### #### ####

#### #### ####

## Data modes:
model_A <- TRUE
model_B <- FALSE
EEG_data <- FALSE

## Analysis mode:
forecast_generation <- TRUE

#### #### ####

## Call baseline generator

if (model_A|model_B) {
  source("EEG_simulator.R",local = TRUE)
}

# [TO BE DEVELOPED]
if (EEG_data) {
  data_file <- datafile.bdf
}

## Simulate or preprocess data

if (model_A) {
  source("modelA_generator.R",local = TRUE)
}

# [TO BE DEVELOPED]
if (model_B) {
  source("modelB_generator.R")
}

# [TO BE DEVELOPED]
if (EEG_data) {
  source("analyse_EEG.R") 
}

## Generate forecast

if (forecast_generation) {
  source("forecast_matrix.R",local = TRUE)
}
