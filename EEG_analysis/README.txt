The EEG pre-processing takes multiple steps:

Step 1: Generate a matrix to remove eye artifacts from the data (Generate_ICA.m)
Step 2: Epoch the EEG data based on events and clean it with the ICA matrix (Clean_data_ICA.m)
Step 3: Visually reject (trial per trial) other invalid trials (e.g. muscle artifacts)

