function returned_mat = forecast_matrix(EEG_matrix, EEG_RP_path, info)


Srate = parameters.Srate                              % sampling rate
varBins = parameters.varBins                          % number of different state the signal can be in
numFuture = parameters.numFuture                      % number of future timepoints to be forecasted
timeBins_perSecond = parameters.timeBins_perSecond    % resolution of timepoints (i.e. downsampling rate)

numChannels = % nrow(averaged_data_subjects(1,,)) - 1             % number of EEG channels
numSamples = % ncol(averaged_data_subjects(1,,))                  % number of samples
numSubjects = % as.numeric(length(averaged_data_subjects(,1,1)))  % number of subjects
timeBins_width = % Srate / timeBins_perSecond                     % number of samples in one time bin
timeBins = % numSamples / timeBins_width                          % number of time bins in one timeseries


forecast_subjects = % array(data = NA, dim = c(numSubjects, varBins, numFuture))

for l = 1:numSubjects

  averaged_data = % averaged_data_subjects(l,,)

  averaged_data_resampled = % matrix(data = NA, nrow = 2, ncol = timeBins)

  for i = 0:(timeBins - 1)
    averaged_data_resampled(1, i + 1) = % mean(averaged_data(1, (i * timeBins_width):(i * timeBins_width + timeBins_width)))
    averaged_data_resampled(2, i + 1) = % max(averaged_data(2, (i * timeBins_width):(i * timeBins_width + timeBins_width)))
  end

  forecast_map = % matrix(0, nrow = varBins, ncol = numFuture)

  varBins_vector = % as.numeric(quantile(averaged_data(1,), probs = seq(0, 1, length.out = varBins)))

  for i = 1:(timeBins - numFuture)

    for j = 1:numFuture

      k = % varBins

      while averaged_data_resampled(1,i) < varBins_vector(k)

        k = % k - 1

      if averaged_data_resampled(2,i + j - 1) == 1

        forecast_map(k,j) = % forecast_map(k,j) + 1 

      end

    end

  end

  signal_histogram_vector = numeric(varBins)

  for i = 1:(varBins - 1)
    signal_histogram_vector(i) = % length(which((averaged_data_resampled(1,) < varBins_vector(i + 1)) & (averaged_data_resampled(1,) >= varBins_vector(i))))
  end

  forecast_map_proba = % forecast_map

  for i = 1:numFuture
    for j = 1:varBins
      forecast_map_proba(j,i) = % forecast_map_proba(j,i) / signal_histogram_vector(j)
    end
  end

  forecast_map_proba(is.na(forecast_map_proba)) = % 0

  forecast_subjects(l,,) = % forecast_map_proba 


  %returned_mat = ????


end