## Author: Lucas Jeay-Bizot
## Created: 11/06/2020
## Last modified: 11/10/2020

#### Function: This code will generate simulated EEG data with events distributed according to model B

## INPUT -----------------------------------------------------------------------------------------------------------------------

# data_subjects -> 3D matrix (subjects-by-channel-by-sample) with simulated baseline EEG data
# parameters -> a parameter file containing 8 parameters from the Caller_Forecast.R script

## OUTPUT ----------------------------------------------------------------------------------------------------------------------

# averaged_data_subjects -> 3D matrix (subjects-by-channel-by-sample) with simulated baseline EEG data with RP distributed according to model B

## DEPENDENCIES ----------------------------------------------------------------------------------------------------------------

# install.packages("pracma")
library("pracma")

## Variables initiation --------------------------------------------------------------------------------------------------------

# check data

if (!exists("data_subjects")) {
  stop("Missing simulated EEG datacube: please run this script after EEG_simulator.R")
}

# set up variables from parameters data.frame

if (!exists("parameters")) {
  stop("Missing parameter dataframe: please run this script from Caller_Forecast to generate a parameter data.frame")
}

numEvent_perMin <- parameters$numEvent_perMin     # desired ratio of events per min
Srate <- parameters$Srate                         # sampling rate
spacing <- parameters$spacing                     # desired minimum spacing (in s) between any two events

# set up additional parameters

numChannels <- as.numeric(length(data_subjects[1,,1])) - 1                                             # number of EEG channels
numSamples <- as.numeric(length(data_subjects[1,1,]))                                                  # number of samples
numEvents <- floor((numSamples / (Srate * 60)) * numEvent_perMin)                                      # number of events
numSubjects <- as.numeric(length(data_subjects[,1,1]))                                                 # number of subjects
event_width <- ncol(as.matrix(read.csv(paste(data_path, "RP_data.csv", sep = ""), header = TRUE)))     # number of samples in the RP signal (used here for length of return to baseline)
event_spacing <- Srate * spacing                                                                       # minimal number of samples separating two events

# create empty array to store the simulations

averaged_data_subjects <- array(data = NA, dim = c(numSubjects, 2, numSamples))

## Start of computations ------------------------------------------------------------------------------------------------------ 

for (k in 1:numSubjects) {
  
  
  # collapses all activity to average activity (NOTE: later developments will explore different channel combinations/weightings)
  
  averaged_data <- matrix(, nrow = 2, ncol = numSamples)
  
  for (i in 1:numSamples) {
    averaged_data[1,i] <- mean(data_subjects[k,1:numChannels, i])
    averaged_data[2,i] <- 0
  }
  
  # generate temp of smoothed signal (of 1/10th of a second)
  
  signal_filtered <- filter(averaged_data[1,], rep(1 / floor(Srate / 10), floor(Srate / 10)), sides = 2)
  
  # get slope of smoothed signal
  ### WARNING ### not same length as averaged_data[1,] - NEEDS FIXING
  
  slope_signal <- diff(signal_filtered, lag = 1) 
  
  rm(signal_filtered)
  
  # index the smoothed signal
  
  slope_signal <- rbind(slope_signal, 1:length(slope_signal))
  
  # order and remove datapoints with decreasing signal (i.e. negative slope) from temp
  
  slope_signal <- slope_signal[, order(slope_signal[1,], decreasing = T)]
  slope_signal <- slope_signal[, 1:(min(which(slope_signal[1,] <= 0)) - 1)]
  
  # create temp (signal_incr) of signal positive slope amplitude values for ordering
  
  signal_incr <- rbind(averaged_data[k, slope_signal[2,]], slope_signal[2,])
  
  rm(slope_signal)
  
  # order signal amplitudes of positive going slopes datapoints
  
  signal_incr <- signal_incr[, order(signal_incr[1,], decreasing = T)]
  
  # generate a vector with indices of datapoints that satisfy: positive going slope and sufficient event spacing, such that there exists only numEvents of such datapoints. 
  
  event_ID <- signal_incr[2,1]
  
  for (i in 2:numEvents) {
    # take the ith element of signal_incr (i.e. highest positive going amplitude of averaged_data after i terms)
    position <- i
    while (length(event_ID) == (i - 1)) {
      condition <- TRUE
      # for-if ensures there is sufficient spacing between any two events
      for (j in 1:length(event_ID)) {
       if (abs(signal_incr[2,position] - event_ID[j]) <= event_spacing) {
         condition <- FALSE
         }
      }
      # if ensures that the event is not placed too close to the end of the timeseries
      if (condition & (signal_incr[2,position] + event_spacing < numSamples)) {
        event_ID[i] <- signal_incr[2,position]
      }
      # if the ith element (or previous (i+n)th element) did not meet the above criteria then take next highest amplitude position
      position <- position + 1
    }
  }
  
  rm(signal_incr, position, condition, j)
  
  # Add the return to baseline as a linear function returning to mean signal amplitude after event
  ### WARNING ### needs further refining - output looks too smooth
  
  # get the baseline return vector
  
  baseline_return <- seq(mean(averaged_data[1,event_ID]), mean(averaged_data[1,]), length.out = event_width)
  
  # add the return to baseline according to the events' postions 
  
  to_be_added <- array(data = 0, dim = c(numSamples))
  
  for (i in 1:numEvents) {
    to_be_added[event_ID[i]:(event_ID[i] + event_width - 1)] <- baseline_return    
  }
  
  # convolve simulated data with the return to baseline
  ### WARNING ### sometimes return mismatch in length below
  
  averaged_data[1,] <- averaged_data[1,] + to_be_added
  
  rm(to_be_added, baseline_return)

  # add binary labels of event
  
  labels <- numeric(numSamples)
  labels[event_ID] <- 1
  averaged_data[2,] <- labels
  rm(labels, event_ID)
  
  # Save the participant's data
  averaged_data_subjects[k,,] <- averaged_data
  rm(averaged_data)
}

## Finishing steps ------------------------------------------------------------------------------------------------------------ 

# clear the environment

rm(event_spacing, event_width, i, k, numChannels, numEvents, numSamples, numEvent_perMin, numSubjects, spacing, Srate, data_subjects)
gc()