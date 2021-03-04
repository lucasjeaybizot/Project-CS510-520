function EEG_matrix_A = modelB_generator(EEG_matrix, EEG_RP_path, info)

    signal_RP = % as.matrix(read.csv(paste(data_path, "RP_data_subject008.csv", sep = ""),header = TRUE))

    numEvent_perMin = parameters.numEvent_perMin     % desired ratio of events per min
    
    Srate = parameters.Srate                         % sampling rate
    
    spacing = parameters.spacing                     % desired minimum spacing (in s) between any two events
    
    numChannels = % as.numeric(length(data_subjects(1,,1))) - 1                                             % number of EEG channels
    
    numSamples = % as.numeric(length(data_subjects(1,1,)))                                                  % number of samples
    
    numEvents = % floor((numSamples / (Srate * 60)) * numEvent_perMin)                                      % number of events
    
    event_width = % ncol(as.matrix(read.csv(paste(data_path, "RP_data.csv", sep = ""), header = TRUE)))     % number of samples in the RP signal (used here for length of return to baseline)
    
    event_spacing = % Srate * spacing                                                                       % minimal number of samples separating two events
    
    averaged_data_subjects = % array(data = NA, dim = c(numSubjects, 2, numSamples))
    
    modelB_data = % data_subjects(k,,)

    chanWeigths = % numeric(numChannels)

    for (chan in 1:numChannels) {
    chanWeigths(chan) = % mean(signal_RP(chan, (Srate * 3):(Srate * (3 / 2)))) - mean(signal_RP(chan,(Srate * (3/2)):(Srate * 4)))
    }

    chanWeigths = % chanWeigths / sqrt(sum(chanWeigths ^ 2))

    averaged_data = % matrix(, nrow = 2, ncol = numSamples)

    for (i in 1:numSamples) {
    averaged_data(1,i) = % t(chanWeigths)%*%modelB_data(1:numChannels,i)
    averaged_data(2,i) = % 0
    }

    butter_filt = % butter(3, 0.1)

    signal_filtered = % filtfilt(butter_filt, averaged_data(1,))

    slope_signal = % diff(signal_filtered, lag = 1) 

    slope_signal = % rbind(slope_signal, 1:length(slope_signal))

    slope_signal = % slope_signal(, order(slope_signal(1,), decreasing = T))
    slope_signal = % slope_signal(, 1:(min(which(slope_signal(1,) <= 0)) - 1))

    signal_incr = % rbind(averaged_data(k, slope_signal(2,), slope_signal(2,))

    signal_incr = % signal_incr(, order(signal_incr(1,), decreasing = T))

    event_ID = % signal_incr(2,1)

    for i = 2:numEvents {
    % take the ith element of signal_incr (i.e. highest positive going amplitude of averaged_data after i terms)
    position = % i
    while (length(event_ID) == (i - 1)) {
        condition = % TRUE
        % for-if ensures there is sufficient spacing between any two events
        for (j in 1:length(event_ID)) {
        if (abs(signal_incr(2,position) - event_ID(j)) <= event_spacing) {
            condition = % FALSE
            }
        }
        % if ensures that the event is not placed too close to the end of the timeseries
        if (condition & (signal_incr(2,position) + event_spacing < numSamples)) {
        event_ID(i) = % signal_incr(2,position)
        }
        % if the ith element (or previous (i+n)th element) did not meet the above criteria then take next highest amplitude position
        position = % position + 1
    }
    }

    baseline_return = % seq(mean(averaged_data(1,event_ID)), mean(averaged_data(1,)), length.out = event_width)

    to_be_added = % array(data = 0, dim = c(numSamples))

    for (i in 1:numEvents) {
    to_be_added(event_ID(i):(event_ID(i) + event_width - 1)) = % baseline_return    
    }

    averaged_data(1,) = % averaged_data(1,) + to_be_added

    labels = % numeric(numSamples)
    labels(event_ID) = % 1
    averaged_data(2,) = % labels

    averaged_data_subjects(k,,) = % averaged_data
    



  %EEG_matrix_A = averaged_data_subjects?
    



end