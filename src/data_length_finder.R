## Author: Lucas Jeay-Bizot
## Created: 11/07/2020
## Last modified: 11/11/2020

# Function: This code will run multiple simulations and generate forecasts maps with varying simulation_duration
# It will then plot the distances between two maps (y-axis) against data_length (x-axis)
# This can enable the understanding of how much data is needed for forecasts to converge

#### TAKES A LOT LOT LOT OF TIME TO COMPLETE ####
#### TRY RUNNING WITH SMALL ITERATION VALUE ON YOUR PC ####

## Variables initiation -------------------------------------------------------------------------------------------------------

# set up variables from parameters data.frame

if (!exists("parameters")) {
  stop("Missing parameter dataframe: please run this script from Caller_Forecast to generate a parameter data.frame")
}

simulation_duration_initial <- parameters$simulation_duration # size of steps of data per iteration of the while loop (in seconds)

iterations <- readline(prompt = "Enter number of iterations desired here. For testing purposes small values (smaller than 5) are advised :") # counter of while loop run
distance_for_plotting <- numeric(iterations)                           # initial vector for plotting

if (parameters$numSubjects > 1) {
  stop("Sorry, this script is not yet ready to handly more than one subject")
}

## Start of computations ------------------------------------------------------------------------------------------------------ 

for (x in 1:iterations) {
  
  tic()
  
  # generate first forecast map
  
  source(paste(src_path, "EEG_simulator.R", sep = ""))
  source(paste(src_path, "modelB_generator.R", sep = ""))
  source(paste(src_path, "forecast_matrix.R", sep = ""))
  
  map_A <- forecast_subjects[1,,]
  
  # generate second forecast map for comparison
  
  source(paste(src_path, "EEG_simulator.R", sep = ""))
  source(paste(src_path, "modelB_generator.R", sep = ""))
  source(paste(src_path, "forecast_matrix.R", sep = ""))
  
  map_B <- forecast_subjects[1,,]
  
  dist_maps <- 0
  
  # calculate distance a sum of square roots of matrix elements difference
  
  for (i in 1:parameters$varBins) {
    for (j in 1:parameters$numFuture) {
      dist_maps <- dist_maps + (map_B[i,j] - map_A[i,j])^2
    }
  }
  
  # store distance in an ordered vector for plotting
  
  distance_for_plotting[x] <- dist_maps
  
  # increment the simulation duration for the next iteration
  
  parameters$simulation_duration = parameters$simulation_duration + simulation_duration_initial
  
  disp("this is iteration number",x,"yielding distance",dist_maps, "and it took:")
  toc()
}

## Finishing steps ------------------------------------------------------------------------------------------------------------ 

# clear the environment

rm(dist_maps, forecast_subjects, i, j, iterations, simulation_duration_initial, x, map_A, map_B)
gc()

# plot the distances between two maps (y-axis) against data_length (x-axis)

plot(distance_for_plotting)