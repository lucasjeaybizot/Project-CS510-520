## Author: Lucas Jeay-Bizot
## Created: 10/24/2020
## Last modified: 11/11/2020

#### Function: This code will call generation of different datasets and analyse them to construct a forecast maps. 
# Another feature of this script is the data_length_finder feature that generates a graph of convergence of forecast maps 
# based on the length (amount) of the simulated data. 

# NOTE: please see docs folder and README files for further information

#### INPUT #### ----------------------------------------------------------------------------------------------------------------
# Inputs will depend on the mode selected. Some inputs are user prompted

# EEG_values.csv -> a csv file with subject-specific EEG parameters 
# RP_data.csv -> a csv file with grand average RP
# parameters -> a parameter file containing 8 parameters
# DEPENDENCIES -> "pracma", "abind"
# scripts -> "EEG_simulator.R", "modelA_generator.R", "modelB_generator.R", "forecast_matrix.R", "data_length_finder.R", "change_beta.R"

#### OUTPUT #### ---------------------------------------------------------------------------------------------------------------
# Outputs will depend on the mode selected

# forecast_generation mode -> forecast maps as 3D value arrays
# data_length_finder mode -> a plot of the converging distances between two maps (y-axis) against data_length (x-axis)

##### ##### ##### --------------------------------------------------------------------------------------------------------------

## set working directory and paths ---------------------------------------------------------------------------------------------

project_path <- getwd()

src_path <- paste(project_path, "/src/", sep = "")

data_path <- paste(project_path, "/data/", sep = "")

## Install packages if missing -------------------------------------------------------------------------------------------------

dependencies <- c("pracma", "abind", "signal")
to_be_installed <- dependencies[!(dependencies %in% installed.packages()[,"Package"])]
if (length(to_be_installed) > 0) {
  install.packages(to_be_installed)
  }

## Variables initiation --------------------------------------------------------------------------------------------------------

# initialize empty parameters data.frame

parameters <- c(0, 0, 0, 0, 0, 0, 0, 0, 0)
names(parameters) <- c("Srate", "numSubjects", "varBins", "numFuture", "simulation_duration", "numEvent_perMin", "spacing", "timeBins_perSecond", "coef_SNR")
parameters <- as.data.frame(t(parameters))

# set default parameters

parameters$Srate <- 512                  # sampling rate
parameters$numSubjects <- 1              # number of subjects
parameters$varBins <- 10                 # number of possible variable states (for forecast)
parameters$numFuture <- 60               # number of future time points to be forecasted
parameters$simulation_duration <- 360    # duration of the simulated data (for each subject) in seconds
parameters$numEvent_perMin <- 3          # desired number of events per minute
parameters$spacing <- 6                  # desired minimal spacing between each event
parameters$timeBins_perSecond <- 20      # desired size of the timepoints in the forecast map
parameters$coef_SNR <- 1                 # signal to noise ratio of the RP signal in model A

#source(paste(src_path, "coef_finder.R", sep = ""))
# prompt non-default inputs for parameters

user_input <- readline(prompt = "Would you like to use default parameters (y/n)?")

if (user_input=="n") {
  parameters$numSubjects <- as.numeric(readline(prompt = "Please enter a number of subjects (numeric value): "))
  parameters$simulation_duration <- as.numeric(readline(prompt = "Please enter the duration on the simulation in seconds (numeric value): "))
  parameters$numEvent_perMin <- as.numeric(readline(prompt = "Please enter the desired number of events per minutes (numeric value): "))
  parameters$spacing <- as.numeric(readline(prompt = "Please enter the desired spacing in seconds between any two events (numeric value): "))
  parameters$varBins <- as.numeric(readline(prompt = "Please enter the number of different variable bins desired in the forecast maps (numeric value): "))
  parameters$numFuture <- as.numeric(readline(prompt = "Please enter the number of future timepoints to be forecasted in the forecast maps (numeric value): "))
  parameters$timeBins_perSecond <- as.numeric(readline(prompt = "Please enter the desired number of time bins per seconds in the forecast maps (numeric value): "))
  parameters$coef_SNR <- as.numeric(readline(prompt = "Please enter the desired signal to noise ratio for model A (numeric value): "))
}

if (60 / parameters$numEvent_perMin < parameters$spacing) {
  stop("Please enter non-contradictory spacing and number of events per minutes values (e.g. if the minimal spacing is of 29 seconds, there cannot be more than 2 events per minutes)")
}

if (parameters$spacing < 5) {
  stop("Please input a value for spacing higher than 5 (as the RP signal associated with the event lasts 5 seconds")
}

## Prompt mode selection ------------------------------------------------------------------------------------------------------

# analysis mode selection:

forecast_generation <- FALSE
data_length_finder <- FALSE

if (readline(prompt = "Which analysis mode would you like to use forecasting (F) or data length finder (DLF): ") == "F") {
  forecast_generation <- TRUE
} else {
  data_length_finder <- TRUE
}

# simulation mode selection for forecast_generation:

model_A <- FALSE
model_B <- FALSE

if (forecast_generation) {
  if (readline(prompt = "Which model would you like to use (A/B): ") == "A") {
    model_A <- TRUE
  } else {
    model_B <- TRUE
  }
}

## Run scripts --------------------------------------------------------------------------------------------------------------

# call baseline generator - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if (model_A|model_B) {
  source(paste(src_path, "EEG_simulator.R", sep = ""))
}

# simulate or preprocess data - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if (model_A) {
  source(paste(src_path, "modelA_generator.R", sep = ""))
}

rm(model_A)

if (model_B) {
  source(paste(src_path, "modelB_generator.R", sep = ""))
}

rm(model_B)

# run analysis  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

if (forecast_generation) {
  source(paste(src_path, "forecast_matrix.R", sep = ""))
}

if (data_length_finder) {
  source(paste(src_path, "data_length_finder.R", sep = ""))
}

# run visuals - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

#heatmap(forecast_subjects[1,,], Rowv = NA, Colv = NA, scale = "none") # for later implementation

## Finishing steps ------------------------------------------------------------------------------------------------------------

# Clear environment

rm(forecast_generation, data_length_finder, user_input, project_path, src_path, data_path, dependencies, to_be_installed)
gc()
