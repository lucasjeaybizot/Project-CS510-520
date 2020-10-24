## Author: Lucas Jeay-Bizot
## Created: 22/10/2020
## Last modified: 24/10/2020
#
#### Function: This code will generate simulated baseline EEG data
#

## INPUT
#
# EEG_values.csv -> data file containing beta, mean and standard deviation for one subject/64 channels

## OUTPUT
#
# Simulated_data -> matrix (channel-by-sample) with simulated baseline EEG data


## DEPENDENCIES

#install.packages("pracma")
library("pracma")

# Load input data

EEG_values <- read.csv('EEG_values.csv',header = FALSE,sep = ",")

# Set up variables

numSubjects <- 1    # here for latter implementations 
numChannels <- nrow(EEG_values)
Srate <- 512    # in sample per second
simulation_duration <- 360    # in seconds (1h of data = 900MB matrix)

# Generate empty matrix to store output

Simulated_data <- matrix(,nrow=numChannels ,ncol = Srate*simulation_duration)

# For each channel generate a random white noise signal and adds the corresponding pink noise

for (j in 1:numChannels) {
  # Generate random signal of simulation_duration seconds
  
  Signal_raw <- rnorm(Srate*simulation_duration)
  
  # Change beta (1/f exponent) of Signal_raw (i.e. adds pink noise)
  
  beta <- EEG_values[j,1] 
  
  half_length <- floor(length(Signal_raw)/2)-1
  
  half_vector <- 2:(half_length+1)
  
  half_filer <- numeric(0)
  
  for (i in 1:half_length) {
    half_filer[i] <- 1/(half_vector[i]^(beta/2))
  }
  
  full_filter <- numeric(0)
  
  full_filter[1] <- 1
  
  for (i in 2:(half_length+1)) {
    full_filter[i] <- half_filer[i-1]
  }
  
  full_filter[half_length+2] <- 1/((half_length+2)^beta)
  
  for (i in (half_length+3):length(Signal_raw)) {
    full_filter[i] <- half_filer[2*half_length+3-i]
  }
  
  Signal_freq_domain <- fft(Signal_raw,inverse = FALSE)
  
  for (i in 1:length(Signal_freq_domain)) {
    Signal_freq_domain[i] <- Signal_freq_domain[i]*sqrt(full_filter[i]^2)
  }
  
  Signal_beta <- fft(Signal_freq_domain,inverse = TRUE)
  
  Signal_beta_real <- as.numeric(Signal_beta)  #FLAG: potential issue when discarding complex values at this step
  
  # Scale Signal_beta_real
  
  mean_EEG <- EEG_values[j,2] 
  std_EEG <- EEG_values[j,2]
  
  Signal_scaled <- ((Signal_beta_real-mean(Signal_beta_real))/std(Signal_beta_real))*std_EEG+mean_EEG
  
  # Store Signal_scaled
  Simulated_data[j,] <- Signal_scaled
}

## Clear the environment (NOTE: might be worthy to save some of this info as metadata for the matrix)

rm(EEG_values,beta,full_filter,half_filer,half_length,half_vector,i,j,mean_EEG,numChannels,numSubjects,Signal_beta,Signal_beta_real,Signal_freq_domain,Signal_raw,Signal_scaled,simulation_duration,Srate,std_EEG)

