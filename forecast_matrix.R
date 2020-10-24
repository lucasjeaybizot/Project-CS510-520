## Author: Lucas Jeay-Bizot
## Created: 24/10/2020
## Last modified: 24/10/2020
#
#### Function: This code will generate a forecast map of the probability of an event occuring in the future given channel activity
#

## INPUT
#
# modelA_data <- matrix with simulated RP EEG data according to model A

## OUTPUT
#
# forecast_map_proba -> matrix of probability of Event in the future

# Set up variables

numChannels <- nrow(modelA_data)-1
numSamples <- ncol(modelA_data)
Srate <- 512
timeBins_perSecond <- 5
timeBins_width <- Srate/timeBins_perSecond
timeBins <- numSamples/timeBins_width
varBins <- 30
numFuture <- 200

# Collapses all activity to average activity (NOTE: later developments will explore different channel combinations/weightings)

averaged_data <- matrix(,nrow = 2,ncol = numSamples)

for (i in 1:numSamples) {
  averaged_data[1,i] <- mean(modelA_data[1:numChannels,i])
  averaged_data[2,i] <- modelA_data[65,i]
}

# Downsamples to timeBins_width

averaged_data_resampled <- matrix(,nrow = 2,ncol = timeBins)

for (i in 0:(timeBins-1)) {
  averaged_data_resampled[1,i+1] <- mean(averaged_data[1,(i*timeBins_width):(i*timeBins_width+timeBins_width)])
  averaged_data_resampled[2,i+1] <- max(averaged_data[2,(i*timeBins_width):(i*timeBins_width+timeBins_width)])
}

# Generate empty forecast map

forecast_map <- matrix(0,nrow = varBins,ncol = numFuture)

# Get varBins width

varBins_width <- (max(averaged_data[1,])-min(averaged_data[1,]))/10
varBins_vector <- seq(min(averaged_data[1,]),by=varBins_width,length.out=varBins)

# Populate forecast map

for (i in 1:(timeBins-numFuture)) {
  for (j in 1:numFuture) {
    k <- varBins
    while (averaged_data_resampled[1,i]<varBins_vector[k]) {
      k <- k-1
    }
    if (averaged_data_resampled[2,i+j-1]==1) {
      forecast_map[k,j] <- forecast_map[k,j] + 1 
    }
  }
}

# Transform histogram matrix into probability matrix

# Store the total amount of time the data was in a certain state (binned according to varBin)
histogram_vector = numeric(varBins) ### RETHINK NAME OF THAT VAR

for (i in 1:timeBins) {
  for (j in 1:varBins) {
    if (averaged_data_resampled[1,i]>varBins_vector[j]) {
      histogram_vector[j] <- histogram_vector[j]+1
    }
  }
}

for (i in 1:(varBins-1)) {
  histogram_vector[i] <- histogram_vector[i]-histogram_vector[i+1]
}

# Divides the distribution in forecast_map by histogram_vector to generate probabilities
forecast_map_proba <- forecast_map

for (i in 1:numFuture) {
  for (j in 1:varBins) {
    forecast_map_proba[j,i] <- forecast_map_proba[j,i]/histogram_vector[j]
  }
}

# Delete NA values (resulted from possible division by 0)
forecast_map_proba[is.na(forecast_map_proba)] <- 0

## Clear up the environment

rm(averaged_data,averaged_data_resampled,histogram_vector,i,j,k,modelA_data,numChannels,numFuture,numSamples,Srate,timeBins,timeBins_perSecond,timeBins_width,varBins,varBins_vector,varBins_width,forecast_map)