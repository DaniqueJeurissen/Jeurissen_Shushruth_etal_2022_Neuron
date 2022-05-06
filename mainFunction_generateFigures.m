function mainFunction_generateFigures()
%% This functions generates plots from Jeurissen, Shushruth et al. 2022 (Neuron).
% The data files are located in the \Data folder.
% Supporting functions are located in the \Modules folder.
% The data is also available on Mendeley Data. 
% Please add the folders \Data and \Modules to the path before running this
% function. 

%% Preliminaries and set up
windowLength = 100; % number of trials included in window

%% Figure 3: Ipsilateral choice bias in Session 1
choiceFirstSession(3, windowLength); % input: figure number, window

%% Figure 4 A-D: Time course of compensation 
% One row per monkey
% left: showing how b0 changes across sessions 
% right: showing how b0 changes within sessions
compensationTimeCourses(4, windowLength); % input: figure number, window
