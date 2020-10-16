% This code will prompt a fieldtrip GUI to visually assess each trial for
% msucles.

% This code is inspired by code from Aaron Schurger

% Created by Lucas Jeay-Bizot
% Created on 16/10/2020

% DEPENDENCIES

    % Fieldtrip with modified functions (see the folder FielTrip_Modifications)

% Clear up the workspace:

clc; clear all; close all;

% INPUT

load data_epoched_cleanICA_subject001.mat

%% Prompts GUI for visual rejection

cfg=[];
cfg.method = 'trial';
[data_fullclean,trlsel,chansel] = ft_rejectvisual(cfg,data_epoched_cleanICA);
labels = labels(trlsel);

save data_fullclean_subject001 data_fullclean trlsel chansel labels;

clear all;

disp("done");