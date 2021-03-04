function EEG_matrix_A = modelA_generator(EEG_matrix, EEG_RP_path, info)

  %MODELA_GENERATOR This code will generate simulated EEG data with events distributed according to model A

  %   Detailed explanation goes here

  signal_RP = %load EEG_RP_path into matrix

  numEvent_perMin = info.parameters.numEvent_perMin     % desired ratio of events per min
  spacing = info.parameters.spacing                     % desired minimum spacing (in s) between any two events
  Srate = info.parameters.Srate                         % sampling rate
  coef_SNR = info.parameters.coef_SNR                   % coefficient of the signal to noise ratio of the added RP

  numChannels = %as.numeric(length(data_subjects(1,,1))) - 1         % number of EEG channels
  numSamples = %as.numeric(length(data_subjects(1,1,)))              % number of samples in one channels' timeseries
  numEvents = %floor((numSamples / (Srate * 60)) * numEvent_perMin)  % number of events
  numSubjects = %as.numeric(length(data_subjects(,1,1)))             % number of subjects
  event_width = %ncol(signal_RP)                                  % number of samples of the RP signal
  event_spacing = Srate * spacing                                   % minimal number of samples separating two events


  event_ID = %= % sort(randcomb(1:((numSamples - event_spacing) / event_spacing))(1:numEvents)) * event_spacing 

  to_be_added = %= % array(data = 0, dim = c(numChannels, numSamples))

  for i = 1:numEvents
    to_be_added(1:numChannels, event_ID(i):(event_ID(i) + event_width - 1)) = % signal_RP(1:numChannels,)    
  end

  data_subjects(k,1:numChannels) = %= % data_subjects(k,1:numChannels,)*coef_SNR + to_be_added

  labels = %= % numeric(numSamples)
  labels(event_ID + Srate * 4) =  1
  data_subjects(k,65) =  labels


  averaged_data_subjects = %= % array(data = NA, dim = c(numSubjects, 2, numSamples))


  modelA_data = data_subjects(l)

  chanWeigths = % numeric(numChannels)

  for chan = 1:numChannels
    chanWeigths(chan) = % mean(signal_RP(chan, (Srate * 3):(Srate * (3 / 2))]) - mean(signal_RP(chan,(Srate * (3/2)):(Srate * 4)])
  end

  chanWeigths = chanWeigths / sqrt(sum(chanWeigths ^ 2))

  averaged_data = % matrix(data = NA, nrow = 2, ncol = numSamples)

  for i = 1:numSamples
    averaged_data(1,i) = % t(chanWeigths)%*%modelA_data(1:numChannels,i]
    averaged_data(2,i) =  modelA_data(65,i)
  end

  butter_filt = % butter(3, 0.1)

  averaged_data(1) = % filtfilt(butter_filt, averaged_data(1))

  % ### WARNING ### quickfixed pasted a 0 to get equal length vectors

  averaged_data(1) = % c(diff(averaged_data(1,), lag = 1),0)

  averaged_data_subjects(l) = averaged_data

  %EEG_matrix_A = averaged_data_subjects?
  

end

