## Author: Lucas Jeay-Bizot
## Created: 22/10/2020
## Last modified: 24/10/2020
#
#### Function: This code will generate simulated EEG data with events distributed according to model A
#

## INPUT
#
# RP_data.csv -> data file containing RP values for one subject/64 channels
# Simulated_data -> matrix generated using EEG_simulator.R

## OUTPUT
#
# modelA_data -> matrix (channel/label-by-sample) with RP distributed according to model A

# Load input data

Simulated_RP <- as.matrix(read.csv("RP_data.csv",header = TRUE))

# Set up variables

numEvent_perMin <- 3
Srate <- 512
numChannels <- nrow(Simulated_data)
numSamples <- ncol(Simulated_data)
numEvents <- (numSamples/(Srate*60))*numEvent_perMin

# generate random position of events (spaced by at least 6 seconds)

event_spacing <- Srate*6

Event_ID <- sort(randcomb(1:((numSamples-event_spacing)/event_spacing))[1:numEvents])*event_spacing # TO BE FIXED: find alternative to space the events

# generate baseline matrix for storing results

modelA_data <- Simulated_data

# add the RP data to the baseline according to the events' postions (NOTE: need to verify if convolution is satisfactory)

multiplication <- FALSE
convolution <- TRUE

event_width <- ncol(Simulated_RP)

if (multiplication) {
  for (i in 1:numEvents) {
    modelA_data[1:numChannels,(Event_ID[i]):(Event_ID[i]+event_width)] <- modelA_data[1:numChannels,(Event_ID[i]):(Event_ID[i]+event_width)]*Simulated_RP[1:event_width]
  }
}

if (convolution) {
  for (i in 1:numEvents) {
    modelA_data[1:numChannels,(Event_ID[i]):(Event_ID[i]+event_width)] <- convolve(modelA_data[1:numChannels,(Event_ID[i]):(Event_ID[i]+event_width)],Simulated_RP[1:event_width])
  }  
}

# add the labels as 65th channel

labels <- numeric(numSamples)
labels[Event_ID+Srate*4] <- 1

modelA_data <- rbind(modelA_data,labels)

## Clear up the environment

rm(Simulated_RP,Simulated_data,Event_ID,event_spacing,event_width,i,labels,numChannels,numEvent_perMin,numEvents,numSamples,Srate,convolution,multiplication)