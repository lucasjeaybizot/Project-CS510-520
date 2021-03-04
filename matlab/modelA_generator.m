function EEG_matrix_A = modelA_generator(EEG_matrix, EEG_RP_path, info)

    %MODELA_GENERATOR This code will generate simulated EEG data with events distributed according to model A

    %   Detailed explanation goes here

    signal_RP = %load EEG_RP_path into matrix
    
    numEvent_perMin = info.parameters.numEvent_perMin     % desired ratio of events per min
    spacing = info.parameters.spacing                     % desired minimum spacing (in s) between any two events
    Srate = info.parameters.Srate                         % sampling rate
    coef_SNR = info.parameters.coef_SNR                   % coefficient of the signal to noise ratio of the added RP
    
    numChannels = %as.numeric(length(data_subjects[1,,1])) - 1         % number of EEG channels
    numSamples = %as.numeric(length(data_subjects[1,1,]))              % number of samples in one channels' timeseries
    numEvents = %floor((numSamples / (Srate * 60)) * numEvent_perMin)  % number of events
    numSubjects = %as.numeric(length(data_subjects[,1,1]))             % number of subjects
    event_width = %ncol(signal_RP)                                  % number of samples of the RP signal
    event_spacing = Srate * spacing                                   % minimal number of samples separating two events

    
    
end

