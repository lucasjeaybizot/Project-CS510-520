function exit_status = main(analysis_mode, model, show_plot, save_filename)  
    %% Variables initiation -----------------------------------------------
    load_info

    if analysis_mode == 'DLF'
        disp('analysis mode DLF')
        data_length_finder
        return

        
    %% Run scripts --------------------------------------------------------
    disp('analysis mode F')
    EEG_simulator

    if model == 'A'
        modelA_generator
    else
        modelB_generator
        
    forecast_matrix

    % run visuals - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    if show_plot
        % idk wtf this is. how to pplot in matlab?
        % heatmap(forecast_subjects[1,,], Rowv = NA, Colv = NA, scale = "none", ylab = "Signal Amplitude", xlab = "Time in the Future")
        % also where tf did forecast_subjects come from??????


    % storage - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    if save_filename
        % save forecast matrix
        save(forecast_matrix_res, save_filename)




    


end