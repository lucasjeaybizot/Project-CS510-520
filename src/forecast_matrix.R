## Author: Lucas Jeay-Bizot
## Created: 10/24/2020
## Last modified: 11/11/2020
#
#### Function: This code will generate a forecast map of the probability of an event occuring in the future given channel activity
#

## INPUT -----------------------------------------------------------------------------------------------------------------------

# averaged_data_subjects -> 3D matrix (subjects-by-channel-by-sample) with simulated baseline EEG data with RP
# parameters -> a parameter file containing 8 parameters from the Caller_Forecast.R script

## OUTPUT ----------------------------------------------------------------------------------------------------------------------

# forecast_subjects -> 3D matrix of conditional probability of Event in the future for each subject given signal state

## Variables initiation --------------------------------------------------------------------------------------------------------

# check data

if (!exists("averaged_data_subjects")) {
  stop("Missing simulated EEG datacube: please run this script after either modelA or modelB generators")
}

# set up variables from parameters data.frame

if (!exists("parameters")) {
  stop("Missing parameter dataframe: please run this script from Caller_Forecast to generate a parameter data.frame")
}

Srate <- parameters$Srate                              # sampling rate
varBins <- parameters$varBins                          # number of different state the signal can be in
numFuture <- parameters$numFuture                      # number of future timepoints to be forecasted
timeBins_perSecond <- parameters$timeBins_perSecond    # resolution of timepoints (i.e. downsampling rate)

# set up additional parameters

numChannels <- nrow(averaged_data_subjects[1,,]) - 1             # number of EEG channels
numSamples <- ncol(averaged_data_subjects[1,,])                  # number of samples
numSubjects <- as.numeric(length(averaged_data_subjects[,1,1]))  # number of subjects
timeBins_width <- Srate / timeBins_perSecond                     # number of samples in one time bin
timeBins <- numSamples / timeBins_width                          # number of time bins in one timeseries

# create empty array to store the forecasts

forecast_subjects <- array(data = NA, dim = c(numSubjects, varBins, numFuture))

## Start of computations ------------------------------------------------------------------------------------------------------ 

for (l in 1:numSubjects) {
  
  averaged_data <- averaged_data_subjects[l,,]
  
  # resample to timeBins_width
  
  averaged_data_resampled <- matrix(data = NA, nrow = 2, ncol = timeBins)
  
  for (i in 0:(timeBins - 1)) {
    averaged_data_resampled[1, i + 1] <- mean(averaged_data[1, (i * timeBins_width):(i * timeBins_width + timeBins_width)])
    averaged_data_resampled[2, i + 1] <- max(averaged_data[2, (i * timeBins_width):(i * timeBins_width + timeBins_width)])
  }
  
  # generate empty forecast map
  
  forecast_map <- matrix(0, nrow = varBins, ncol = numFuture)
  
  # get varBins width and generate a varabin vector with varBins every quantiles values
  
  varBins_vector <- as.numeric(quantile(averaged_data[1,], probs = seq(0, 1, length.out = varBins)))
  
  # populate forecast map with count of times event happened for each varBin and numFuture combinations
  
  for (i in 1:(timeBins - numFuture)) {
    # first for() ensures no value is taken too close to the end of the vector
    for (j in 1:numFuture) {
      # below while() loop identifies for the ith point the varBin it belongs to (k-th bin)
      k <- varBins
      while (averaged_data_resampled[1,i] < varBins_vector[k]) {
        k <- k - 1
      }
      if (averaged_data_resampled[2,i + j - 1] == 1) {
        # this if() statement adds 1 to the forecast cell if an event occured in the data
        forecast_map[k,j] <- forecast_map[k,j] + 1 
      }
    }
  }
  
  # transform above forecast matrix into conditional probability matrix
  
  # store the total amount of time the data was in a certain state (binned according to varBin)
  ### WARNING ### NEEDS FIXING - missing final bin
  
  signal_histogram_vector = numeric(varBins)
  
  for (i in 1:(varBins - 1)) {
    signal_histogram_vector[i] <- length(which((averaged_data_resampled[1,] < varBins_vector[i + 1]) & (averaged_data_resampled[1,] >= varBins_vector[i])))
  }

  # divide the distribution in forecast_map by histogram_vector to generate conditional probabilities
  
  forecast_map_proba <- forecast_map
  
  for (i in 1:numFuture) {
    for (j in 1:varBins) {
      forecast_map_proba[j,i] <- forecast_map_proba[j,i] / signal_histogram_vector[j]
    }
  }
  
  rm(signal_histogram_vector)
  
  # delete NA values (resulted from possible division by 0 in the above step)
  
  forecast_map_proba[is.na(forecast_map_proba)] <- 0
  
  # normalize the forecast map
  
  ### QUESTION ### SHOULD I NORMALIZE IN NON-COMPARISON STEPS?
  
  # store the forecast map
  
  forecast_subjects[l,,] <- forecast_map_proba 
  
  # clear up the environment
  
  rm(averaged_data_resampled, i, j, k, forecast_map) # 'averaged_data, ' to be pasted back
}

## Finishing steps ------------------------------------------------------------------------------------------------------------ 

# clear up the environment

rm(averaged_data_subjects, l, forecast_map_proba, numChannels, numSamples, timeBins, timeBins_width, varBins_vector, numFuture, numSubjects, Srate, timeBins_perSecond, varBins)
gc()