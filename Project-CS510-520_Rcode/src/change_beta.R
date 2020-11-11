change_beta <- function(signal, beta) {
  # Changes the 1/f exponent of signal given a specific beta value
  # This code is adapted from a similar MATLAB function by Dr. Aaron Schurger
  
  # Generate a Beta filter
  
  half_length <- floor(length(signal) / 2) - 1
  
  half_vector <- 2:(half_length + 1)
  
  half_filter <- numeric(0)
  
  half_filter[1:half_length] <- 1 / (half_vector[1:half_length] ^ (beta / 2))
  
  full_filter <- numeric(0)
  
  full_filter[1] <- 1
  
  full_filter[2:(half_length + 1)] <- half_filter[1:(half_length)]
  
  full_filter[half_length + 2] <- 1 / ((half_length + 2) ^ beta)
  
  full_filter[(half_length + 3):length(signal)] <- half_filter[2 * half_length + 3 - (half_length + 3):length(signal)]
  
  # Bring the signal into the frequency domain
  
  signal_freq_domain <- fft(signal, inverse = FALSE)
  
  # Filter the data in the frequency domain
  
  signal_freq_domain[1:length(signal_freq_domain)] <- signal_freq_domain[1:length(signal_freq_domain)] * sqrt(full_filter[1:length(signal_freq_domain)] ^ 2)
  
  # Bring the signal back to the time domain
  
  signal_beta <- fft(signal_freq_domain, inverse = TRUE)
  
  # Remove warnings caused by complex values
  
  default_warn <- getOption("warn")
  options(warn = -1)
  
  signal_beta_real <- as.numeric(signal_beta)  ### WARNING: potential issue when discarding complex values at this step ###
  
  options(warn=default_warn)
  
  # Scale Signal_beta_real to the EEG mean and standard deviation
  
  mean_EEG <- EEG_values[j, 2] 
  std_EEG <- EEG_values[j, 2]
  
  signal_scaled <- ((signal_beta_real - mean(signal_beta_real)) / std(signal_beta_real)) * std_EEG + mean_EEG
  
  return(signal_scaled)
}