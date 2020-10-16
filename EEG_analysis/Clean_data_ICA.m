% This code will generate a fieldtrip structure with the data epoched based
% on events and cleaned from eyeblinks using ICA

% This code is inspired by code from Aaron Schurger and uses functions by
% Aaron Schurger

% Created by Lucas Jeay-Bizot
% Created on 16/10/2020

% DEPENDENCIES

    % Fieldtrip with modified functions (see the folder FielTrip_Modifications)
    % myft_apply_projection_matrix.m function (from Aaron Schurger)

% Clear up the workspace:

clc; clear all; close all;

% INPUT

filename = 'subject001.bdf';
load blink_proj_mat_subject001.mat;

%% Loading and epoching the data ([-4:1] windows around the event)

% Read the data into event-adjusted epoched
cfg = [];
cfg.dataset = filename;
cfg.trialdef.eventtype = 'STATUS';
cfg.trialdef.eventvalue = [8 16];                                          % 8 and 16 are event codes specific to our data
cfg.trialdef.prestim  = 4;
cfg.trialdef.poststim = 1;
cfg = ft_definetrial(cfg);
trl = cfg.trl; 
labels = trl(:,4);                                                         % will be used for labelling later (see Visual_rejection.m)

% Select our EEG channels and demean the data
cfg.channel = {'A*','B*'};  
cfg.demean = 'yes';
cfg.detrend = 'no';
data_epoched = ft_preprocessing(cfg);

% Replace channel labels (based on equipment)
load BIOSEMI_labels.mat
data_epoched.label = BIOSEMI_labels;

% Downsampling to 512 Hz
cfg = []; 
cfg.resamplefs = 512;
data_epoched = ft_resampledata(cfg,data_epoched);

% Re-referencing the data to common average (Cz)
cfg=[];
cfg.channel = {'all'};
cfg.reref = 'yes';
cfg.refchannel = {'all'};
cfg.implicitref = 'Cz';
data_epoched = ft_preprocessing(cfg,data_epoched);

%% Apply the ICA matrix computed with Generate_ICA.m

load blink_proj_mat_subject001 M;
data_epoched_cleanICA = myft_apply_projection_matrix(data_epoched,M);      % This calls a function from Aaron Schurger

%% Save the cleaned data

save data_epoched_cleanICA_subject001 data_epoched_cleanICA labels;
clear all;
disp("done");
