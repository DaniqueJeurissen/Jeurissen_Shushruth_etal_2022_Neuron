function firstHighDoseDrugSession = getMyFirstSessionDate
% find the date of the very first session (muscimol experiment) or the
% first session with a high clozapine dose (dreadd experiment). 
% format: YYYYMMDD

firstHighDoseDrugSession = [ ...
    20180121; ... % Monkey 1, Napoleon, first muscimol session
    20190808; ... % Monkey 2, Damien, first muscimol session
    20200207; ... % Monkey 3, Yossarian, first muscimol session
    20180604];    % Monkey 4, Megatron, first high dose clozapine session
