function monkey_data = loadInactivationData(monkey)
% monkey (input) is a string, can be upper or lower case or combination and
% only the first 4 letters need to match, so short names such as Yossi and
% Mega also work. 
% monkey 1: Napoleon (dots, muscimol)
% monkey 2: Damien (dots, muscimol)
% monkey 3: Yossarian (async, muscimol)
% monkey 4: Megatron (async, dreadds)

%% get directory
% get the directory with data 
serDir = './Data'; 

%% define filename based on monkey name
if strncmpi(monkey, 'Napoleon',4)
    fileName = 'napoleon_data.mat';
elseif strncmpi(monkey, 'Damien',4)
	fileName = 'damien_data.mat';
elseif strncmpi(monkey, 'Yossarian',4)
    fileName = 'yossarian_data.mat';
elseif strncmpi(monkey, 'Megatron',4)
	fileName = 'megatron_data.mat';
else
    warning('Check spelling of monkey name and choose from: Napoleon, Damien, Yossarian, or Megatron')
end

%% define data file name by taking away the '.mat' extension
fileNameNoExt = fileName(1:end-4);

%% Load the data
loadedData = load([serDir '/' fileName]);
disp(['Loading ' fileName])
% loadedData is a structure, make it a matrix named 'monkey_data'
monkey_data = loadedData.(fileNameNoExt); 

