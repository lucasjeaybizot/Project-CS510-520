# This file will test running the project under different conditions
# HOW TO RUN THE TEST: from the test directory, enter "source("test.R")" in the command line
# Running time can be a few seconds
# EXPECTED OUTPUT: 1 data file "parameters" containing 8 parameter columns, 1 value file "forecast_subjects" containing a 1-by-30-by-40 3D matrix structure

# check libraries

dependencies <- c("signal", "abind", "pracma")
to_be_installed <- dependencies[!(dependencies %in% installed.packages()[,"Package"])]
if (length(to_be_installed) > 0) {
  install.packages(to_be_installed)
}
library("abind")
library("pracma")
library("signal")

# get directories information

project_path <- getwd()

src_path <- paste(project_path, "/src/", sep = "")

data_path <- paste(project_path, "/data/", sep = "")

# for default values, generate forecast map using model B

# initialize empty parameters data.frame

parameters <- c(0, 0, 0, 0, 0, 0, 0, 0, 0)
names(parameters) <- c("Srate", "numSubjects", "varBins", "numFuture", "simulation_duration", "numEvent_perMin", "spacing", "timeBins_perSecond", "coef_SNR")
parameters <- as.data.frame(t(parameters))

# set default parameters

parameters$Srate <- 512                  # sampling rate
parameters$numSubjects <- 1              # number of subjects
parameters$varBins <- 30                 # number of possible variable states (for forecast)
parameters$numFuture <- 60               # number of future time points to be forecasted
parameters$simulation_duration <- 360    # duration of the simulated data (for each subject) in seconds
parameters$numEvent_perMin <- 3          # desired number of events per minute
parameters$spacing <- 6                  # desired minimal spacing between each event
parameters$timeBins_perSecond <- 20      # desired size of the timepoints in the forecast map
parameters$coef_SNR <- 1                 # signal to noise ratio of the RP signal in model A

# run sequentially the scripts for simulated EEG, model B implementation and forecast map generation

to_be_tested <- readline(prompt = "Which model would you like to be tested (A/B)?")

source(paste(src_path, "EEG_simulator.R", sep = ""))
switch(to_be_tested,
       "A" = source(paste(src_path, "modelA_generator.R", sep = "")),
       "B" = source(paste(src_path, "modelB_generator.R", sep = ""))
       )
source(paste(src_path, "forecast_matrix.R", sep = ""))

if (exists("forecast_subjects")) {
  disp("Model", to_be_tested, "passed the test")
}

# clear the environment

rm(data_path, project_path, src_path, parameters, dependencies, forecast_subjects, to_be_installed, to_be_tested)