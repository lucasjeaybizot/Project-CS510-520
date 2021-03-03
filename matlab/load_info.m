%% set working directory and paths ---------------------------------------------------------------------------------------------

paths.project = 0;
paths.src = 0;
paths.data = 0;
paths.result =0; 

parameters.Srate = 512                  ;% sampling rate
parameters.numSubjects = 1              ;% number of subjects
parameters.varBins = 30                 ;% number of possible variable states (for forecast)
parameters.numFuture = 60               ;% number of future time points to be forecasted
parameters.simulation_duration = 360    ;% duration of the simulated data (for each subject) in seconds
parameters.numEvent_perMin = 3          ;% desired number of events per minute
parameters.spacing = 6                  ;% desired minimal spacing between each event
parameters.timeBins_perSecond = 20      ;% desired size of the timepoints in the forecast map
parameters.coef_SNR = 1                 ;% signal to noise ratio of the RP signal in model A
