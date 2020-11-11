## Author: Lucas Jeay-Bizot
## Created: 10/22/2020
## Last modified: 11/10/2020

#### Function: This code will generate simulated baseline EEG data


## INPUT -----------------------------------------------------------------------------------------------------------------------

# EEG_values.csv -> data file containing beta, mean and standard deviation for one subject/64 channels
# parameters -> a parameter file containing 8 parameters from the Caller_Forecast.R script

## OUTPUT ----------------------------------------------------------------------------------------------------------------------

# data_subjects -> 3D matrix (subjects-by-channel-by-sample) with simulated baseline EEG data

## DEPENDENCIES ----------------------------------------------------------------------------------------------------------------

#install.packages("pracma")
library("pracma")

#install.packages("abind")
library("abind")

source(paste(src_path, "change_beta.R", sep = ""))

## Variables initiation -------------------------------------------------------------------------------------------------------

# load input data

EEG_values <- read.csv(paste(data_path, "EEG_values.csv", sep = ""), header = FALSE, sep = ",")

# set up variables from parameters data.frame

if (!exists("parameters")) {
  stop("Missing parameter dataframe: please run this script from Caller_Forecast to generate a parameter data.frame")
}

numSubjects <- parameters$numSubjects                  # number of subjects
Srate <- parameters$Srate                              # sampling rate
simulation_duration <- parameters$simulation_duration  # duration (in seconds) of the simulated data

# set up additional parameters

numChannels <- nrow(EEG_values)                        # number of EEG channels

# create empty array to store the simulations

data_subjects <- array(data = NA, dim = c(numSubjects, numChannels, Srate*simulation_duration))

## Start of computations ------------------------------------------------------------------------------------------------------ 

# loop over subjects the generation of simulated data

for (k in 1:numSubjects) {
  simulated_data <- matrix(data = NA, nrow = numChannels , ncol = Srate*simulation_duration)

  # For each channel generate a random white noise signal and adds the corresponding pink noise
  # change beta (1/f exponent) (i.e. adds pink noise) of a randomly generated signal with rnorm() 

  for (j in 1:numChannels) {
    simulated_data[j,] <- change_beta(rnorm(Srate*simulation_duration), EEG_values[j,1])
  }
  
  # store the simulation
  
  data_subjects[k,,] <- simulated_data
  
  # clear the environment
  
  rm(simulated_data)
}

# add an empty channel in the data cube to store later store event positions

empty_array <- array(data = NA, dim = c(numSubjects, 1, Srate*simulation_duration))
data_subjects <- abind(data_subjects, empty_array, along = 2)

## Finishing steps ------------------------------------------------------------------------------------------------------------ 

# clear the environment

rm(EEG_values, numChannels, j, k, change_beta, empty_array, Srate, numSubjects, simulation_duration)
gc()