# Project-CS510-520
Repository for the project in CS510 and CS520

Welcome to this repository

# What you will find in this repository

Here you will find a script that simulates EEG data, adds simulated neural events (called RP) according to two-different models (model A and model B). The script then uses these simulations to generate forecasting maps of the probability of an event occuring in the future given the neural system's current state.
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

# Want to know more

The role of each script individually is described in Code Description.docx in the docs folder. The original proposal can also be found there (although not updated). An example output saved in csv format can be found in the examples folder.

*By Lucas Jeay-Bizot*
