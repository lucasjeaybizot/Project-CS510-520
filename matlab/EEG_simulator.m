function EEG_matrix = EEG_simulator(EEG_rest_path, info)
    %EEG_SIMULATOR This code will generate simulated baseline EEG data
    
    % get variables
    EEG_values = load(char(info.paths.data + EEG_rest_path));
    
    Srate = info.parameters.Srate;
    simulation_duration = info.parameters.simulation_duration;
    
    numChannels = length(EEG_values');
    
    EEG_matrix = zeros(numChannels, Srate * simulation_duration);
    
    % Induce pink noise on random data
    
    for k = 1:numChannels
        EEG_matrix(k,:) = change_beta(randn(Srate * simulation_duration, 1), EEG_values(k,1));
    end
    
end

