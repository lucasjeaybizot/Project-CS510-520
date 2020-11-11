# Project-CS510-520
Repository for the project in CS510 and CS520

Welcome to this repository

# What you will find in this repository

Here you will find a script that simulates EEG brain data, adds simulated neural events (called RP) according to two-different models (model A and model B). The script then uses these simulations to generate forecasting maps of the probability of an event occuring in the future given the neural system's current state.
Additionally, you can plot the distance between two simulated maps as a function of the length of the simulation (i.e. of how much data has been generated)

# How to run it

Pull this repository and then run the Caller_Forecast.R script. You will then be presented with a set of options in the command prompt. If in doubt, a set of default values is already hardscripted and can be selected from the start

# Step-by-step use of this repository

Step 1: set your working directory to be the same as the one 'Caller_Forecast.R' is in

Step 2: run the following command "source("Caller_Forecast.R")"

Step 3: choose parameters (either manually or by defaults using the "y" key)

Step 4: choose your analysis mode: F for generating forecast maps or DLF for generating a plot of forecast map convergence against data simulation length

Step 5a: for F choose your model: A or B

Step 5b: for DLF choose your iterations (length of x-axis) [careful here as this can get quite time-demanding even for small iteration values]

Step 6: admire the results

For the F analysis, the result will be a 3D value variable in the Rstudio environment. The first dimension corresponds to a participant, the second to current amplitude of the signal and the third to a number of time points in the future. Each value in this 3D cube represents, for each subjects, the conditional probability that an event occurs at a certain timepoint in the future given the system's current amplitude.

For the DLF analysis, the result will be a 2D plot, with the distance between two forecast maps generated on two different simulated datasets of equal length (using model B) on the y-axis and the length of the simulated datasets on the x-axis. 

*Note: There is no storing of outputs, the outputs will only appear in the environment

# Want to know more

The role of each script individually is described in Code Description.docx in the docs folder. The original proposal can also be found there (although not updated). An example output saved in csv format can be found in the examples folder.


*By Lucas Jeay-Bizot*
