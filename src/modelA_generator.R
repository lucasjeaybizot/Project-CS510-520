## Author: Lucas Jeay-Bizot
## Created: 10/22/2020
## Last modified: 11/10/2020

#### Function: This code will generate simulated EEG data with events distributed according to model A


## INPUT -----------------------------------------------------------------------------------------------------------------------

# RP_data.csv -> data file containing RP values for one subject/64 channels
# data_subjects -> 3D matrix (subjects-by-channel-by-sample) with simulated baseline EEG data
# parameters -> a parameter file containing 8 parameters from the Caller_Forecast.R script

## OUTPUT ----------------------------------------------------------------------------------------------------------------------

# averaged_data_subjects -> 3D matrix (subjects-by-channel-by-sample) with simulated baseline EEG data with RP distributed according to model A

## Variables initiation --------------------------------------------------------------------------------------------------------

# check data

if (!exists("data_subjects")) {
  stop("Missing simulated EEG datacube: please run this script after EEG_simulator.R")
}

# load input data

simulated_RP <- as.matrix(read.csv(paste(data_path, "RP_data.csv", sep = ""),header = TRUE))

# set up variables from parameters data.frame

if (!exists("parameters")) {
  stop("Missing parameter dataframe: please run this script from Caller_Forecast to generate a parameter data.frame")
}

numEvent_perMin <- parameters$numEvent_perMin     # desired ratio of events per min
spacing <- parameters$spacing                     # desired minimum spacing (in s) between any two events
Srate <- parameters$Srate                         # sampling rate
coef_SNR <- parameters$coef_SNR                   # coefficient of the signal to noise ratio of the added RP

# set up additional parameters

numChannels <- as.numeric(length(data_subjects[1,,1])) - 1         # number of EEG channels
numSamples <- as.numeric(length(data_subjects[1,1,]))              # number of samples in one channels' timeseries
numEvents <- floor((numSamples / (Srate * 60)) * numEvent_perMin)  # number of events
numSubjects <- as.numeric(length(data_subjects[,1,1]))             # number of subjects
event_width <- ncol(simulated_RP)                                  # number of samples of the RP signal
event_spacing <- Srate * spacing                                   # minimal number of samples separating two events

## Start of computations ------------------------------------------------------------------------------------------------------ 

# this first section will add random RP-events to the simulation

for (k in 1:numSubjects) {
  
  # generate random positions for each event (with minimum spacing as specified in the spacing variable)
  ### WARNING ### for small simulation_duration this is barely random - a better randomisation process needs to be implemented here
  
  event_ID <- sort(randcomb(1:((numSamples - event_spacing) / event_spacing))[1:numEvents]) * event_spacing 
  
  # add the RP data to the baseline according to the events' postions 
  
  to_be_convolved <- array(data = 0, dim = c(numChannels, numSamples))
  
  for (i in 1:numEvents) {
    to_be_convolved[1:numChannels, event_ID[i]:(event_ID[i] + event_width - 1)] <- simulated_RP[1:numChannels,]    
  }
  
  to_be_convolved <- to_be_convolved*coef_SNR

  data_subjects[k,1:numChannels,] <- convolve(data_subjects[k,1:numChannels,], to_be_convolved)
  
  rm(to_be_convolved)
  
  # add the binary event labels in an extra channel
  
  labels <- numeric(numSamples)
  labels[event_ID + Srate * 4] <- 1
  data_subjects[k,65,] <- labels
  rm(labels, event_ID)
}

# this second section below collapses all channels into one signal (by averaging)

averaged_data_subjects <- array(data = NA, dim = c(numSubjects, 2, numSamples))

for (l in 1:numSubjects) {
  
  # extract data
  
  modelA_data <- data_subjects[l,,]
  
  # collapses all activity to average activity (NOTE: later developments will explore different channel combinations/weightings)
  
  averaged_data <- matrix(data = NA, nrow = 2, ncol = numSamples)
  
  for (i in 1:numSamples) {
    averaged_data[1,i] <- mean(modelA_data[1:numChannels,i])
    averaged_data[2,i] <- modelA_data[65,i]
  }
  
  averaged_data_subjects[l,,] <- averaged_data
  rm(averaged_data, modelA_data)
}

## Finishing steps ------------------------------------------------------------------------------------------------------------ 

# clear the environment

rm(l, simulated_RP, event_spacing, event_width, i, k, numChannels, numEvents, numSamples, numSubjects, data_subjects,numEvent_perMin, spacing, Srate)
gc()