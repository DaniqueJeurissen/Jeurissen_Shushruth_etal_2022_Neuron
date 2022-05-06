function choiceFirstSession(fignr, windowLength)
% Plots psychometric function for each monkey:
% One line for session 1 - pre drug
% One line for session 1 - post drug
% One line for control sessions. 
%
% inputs
%   fignr: figure number 
%   windowLength: number of trials used to compute b0, default: 100 trials
%
% monkey 1: Napoleon (dots, muscimol)
% monkey 2: Damien (dots, muscimol)
% monkey 3: Yossarian (async, muscimol)
% monkey 4: Megatron (async, dreadds)

%% default inputs
if nargin == 1
    windowLength = 100; % default number of trials in pre, post, and control
elseif nargin == 0
    fignr = 3;
    windowLength = 100;
end

%% get dates of first (high dose) sessions
firstHighDoseDrugSession = getMyFirstSessionDate;
nAnimals = size(firstHighDoseDrugSession,1);

%% figure info
nRows = 1; % number of rows in figure
nCols = nAnimals; % number of columns in figure

figure(fignr), clf

%% settings
C = columnCodesInactivation;
[myBlack, myWhite, myGray] = getMyColorBWGRGBCMY;

%% loop across animals to get one subplot per monkey
for i = 1 : nAnimals
    % plot data from each animal into a subplot
    figure(fignr), subplot(nRows, nCols, i), hold on
    
    % get a monkey name
    monkey = getMyMonkey(i);
    
    % load data, remove incomplete trials
    data = loadInactivationData(monkey);
    data = discardAbortedTrials(data);
    
    % limit data set to first session with muscimol / high dose clozapine
    relevantTrials_sess1 = data(:,C.date) == firstHighDoseDrugSession(i);
    data_sess1 = data(relevantTrials_sess1,:);
    % limit the other data set to control sessions
    relevantTrials_contr = data(:,C.drug_type_session) < 1;
    data_contr = data(relevantTrials_contr,:);
    
    % number of trials
    ntr_sess1 = size(data_sess1,1);
    ntr_contr = size(data_contr,1);
    
    % find trial number where post starts for the first session
    firstTrPost = find( diff( data_sess1(:,C.pre0_post1) == 1) == 1, 1) + 1;
    % select last 'windowLength' trials for Pre
    selectPreLast   = false(ntr_sess1, 1); selectPreLast(firstTrPost - windowLength : firstTrPost - 1) = true;
    % select first 'windowLength' trials for Post
    selectPostFirst = false(ntr_sess1, 1); selectPostFirst(firstTrPost : firstTrPost + windowLength - 1) = true;
    
    % find where all posts starts in controls
    firstTrlsPostContr = find( diff( data_contr(:,C.pre0_post1) == 1) == 1) + 1;
    % select first 'windowLength' trials for all control sessions
    selectPostFirstContr = false(ntr_contr, 1);
    for j = 1 : size(firstTrlsPostContr,1)
        selectPostFirstContr(firstTrlsPostContr(j) : firstTrlsPostContr(j) + windowLength - 1) = true;
    end
    % make sure only 'post' trials are selected, also if we have less than
    % 'windowLength' trials in post (adding windowlength to first trial may
    % lead to selection of pre trials in next session when window is large)
    selectPostFirstContr(data_contr(:,C.pre0_post1) == 0) = false;
    
    % plot control in gray
    [~, xvals, yfit, ~] = myGlmFit(data_contr(selectPostFirstContr, C.signedContraCoherence), data_contr(selectPostFirstContr,C.contraChoice));
    lgnd_contr = plot(xvals, yfit, 'color', myGray, 'LineStyle', '-', 'LineWidth', 1);
    
    % plot pre in black 
    [~, xvals, yfit, ~] = myGlmFit(data_sess1(selectPreLast, C.signedContraCoherence), data_sess1(selectPreLast,C.contraChoice));
    lgnd_pre = plot(xvals, yfit, 'color', myBlack, 'LineStyle', '--', 'LineWidth', 2);
    
    % plot post  in black 
    [~, xvals, yfit, ~] = myGlmFit(data_sess1(selectPostFirst, C.signedContraCoherence), data_sess1(selectPostFirst,C.contraChoice));
    lgnd_post = plot(xvals, yfit, 'color', myBlack, 'LineStyle', '-', 'LineWidth', 2);
    
    
    % scatter choice onto the glm fits with local function
    plotChoice(data_contr, selectPostFirstContr, myWhite, myGray,  50, '^', fignr, nRows, nCols, i, C)
    plotChoice(data_sess1, selectPreLast,        myWhite, myBlack, 50, 'o', fignr, nRows, nCols, i, C)
    plotChoice(data_sess1, selectPostFirst,      myBlack, myBlack, 50, 'o', fignr, nRows, nCols, i, C)
    
    % add a legend to the first plot
    if i == 1 || i == 3
        lgnd = legend([lgnd_contr, lgnd_pre, lgnd_post], ...
            'Control', 'Pre', 'Post', ...
            'Location', 'NorthWest');
        lgnd.AutoUpdate = 'off';
    end
    
    % clear monkey/session specific variables
    clear data* select* xvals yfit relevantTr* ntr* firstTrPostControl monkey
end

%% make figure presentable
prettifyPsychometricFunction(fignr, nRows, nCols)

end % END MAIN FUNCTION

%% define a local function to plot the data
% function plotChoice(dataset, relevantTrials, myFillColor, myEdgeColor, markerSize, markerType, fignr, nRows, nCols, subplotIx, plotRT, C)
function plotChoice(dataset, relevantTrials, myFillColor, myEdgeColor, markerSize, markerType, fignr, nRows, nCols, subplotIx, C)

% define unique values in coherence list
cohList = unique(dataset(relevantTrials,C.signedContraCoherence));

% preallocate a variable that will keep track of proportion contralateral
% choices
propContraChoice = nan(length(cohList),1);

% compute mean contralateral choices for each signed coherence
for j = 1 : length(cohList)
    
    % in the relevant dataset, find the releavant trials of this coherence
    ix = dataset(:,C.signedContraCoherence) == cohList(j) & relevantTrials;
    
    % compute the mean proportion of contralateral choices 
    propContraChoice(j) = mean(dataset(ix,C.contraChoice));
end

% get the figure and subplot
figure(fignr), subplot(nRows, nCols, subplotIx), hold on

% scatter mean proportion contralateral choices
scatter(cohList, propContraChoice, markerSize, markerType, 'MarkerFaceColor', myFillColor, 'MarkerEdgeColor', myEdgeColor)

end % END SUBFUNCTION 
