% This code will generate an ICA matrix for eye blinks (upon user's visual
% identification of eye blink components)

% This code is inspired by code from Aaron Schurger and uses functions by
% Aaron Schurger

% Created by Lucas Jeay-Bizot
% Created on 16/10/2020

% DEPENDENCIES

    % Fieldtrip with modified functions (see the folder FielTrip_Modifications)
    % MATLAB's signal processing toolbox
    % myft_reject_components_EEG.m function (from Aaron Schurger)
    % myft_computeprojmatrix_EEG.m function (from Aaron Schurger)

% Clear up the workspace:

clc; clear all; close all;

% INPUT

fieldtrip_path = 'C:\Users\lucas\Desktop\Matlab_Extras\FieldTrip\fieldtrip-20200607\fieldtrip-20200607';

filename = 'subject001.bdf';

%% Setting up the fieldtrip path

addpath(fieldtrip_path);
ft_defaults;
clear fieldtrip_path;

%% Splitting the entire participant's data into 2 seconds epochs

subject = ft_read_header(filename);
SamplesPerWindow = 2 * subject.Fs; 
nSamps = subject.nSamples - SamplesPerWindow;
trial = [[SamplesPerWindow/2+1:SamplesPerWindow:nSamps]'-SamplesPerWindow/2 [SamplesPerWindow/2+1:SamplesPerWindow:nSamps]'+SamplesPerWindow/2 [SamplesPerWindow/2+1:SamplesPerWindow:nSamps]'*0-SamplesPerWindow/2];

%% Loading the epoched data into fieldtrip format

cfg = [];
cfg.trl = trial;
cfg.dataset = filename;
cfg.detrend = 'no';
cfg.continuous = 'yes';
cfg.blc = 'yes';                                                           % Performs baseline correction
cfg.channel = {'A*','B*'};                                                 % A and B channels are EEG channels
data_for_ICA = ft_preprocessing(cfg);

%% Downsample the data (from 2048 Hz to 512 Hz) in order to reduce memory costs

cfg = []; 
cfg.resamplefs = 512;
data_for_ICA = ft_resampledata(cfg,data_for_ICA);

%% Add correct labelling (matching the equipment) to the data

load BIOSEMI_labels.mat
data_for_ICA.label = BIOSEMI_labels;

%% Re-reference the data to common average (Cz)

cfg=[];
cfg.channel = [1:64];   %  
cfg.reref = 'yes';
cfg.refchannel = {'all'};
cfg.implicitref = 'Cz';
data_for_ICA = ft_preprocessing(cfg,data_for_ICA);

%% Run ICA from a function by Aaron Schurger

[M,P,comp] = myft_reject_components_EEG(data_for_ICA,'runica');

save blink_proj_mat_subject001 M P comp;                                   % Ideally I find a workaround latter to loop over participants and store filename in a structure
clear all;

disp("done");
