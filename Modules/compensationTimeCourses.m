function compensationTimeCourses(fignr, windowLength)
% Plots b0 for each monkey
% Left panels: showing how b0 changes across sessions 
% Right panels: showing how b0 changes within sessions
%
% inputs
%   fignr: figure number 
%   windowLength: number of trials used to compute b0, default: 100 trials
%
% monkey 1: Napoleon (dots, muscimol)
% monkey 2: Damien (dots, muscimol)
% monkey 3: Yossarian (async, muscimol)
% monkey 4: Megatron (async, dreadds)

%% default inputs and outputs
if nargin == 1
    windowLength = 100; 
elseif nargin == 0
    fignr = 4;
    windowLength = 100;
end

%% info
nAnimals = 4;
% Power exponent for the two RDM monkeys
pow_rdm = getPowerExponent;

%% figure info
nRows = nAnimals; % number of rows in figure
nCols = 2;        % number of columns in figure

figure(fignr);
set(gcf,'position',[100 150 1200 1150])
clf % clear figure

%% manually set y limits for dots task and async task so that they match between left and right panels
ylim_dots =  [-1.55 1.55];
ylim_async = [-2.75 2.75];

%% settings and colors
C = columnCodesInactivation;
postTrls = 500; % number of post-trials to consider per session
myBlack = getMyColorBWGRGBCMY;
myLigthGray = [.7 .7 .7];

%% check that window length for 'early' is shorter than post trial window
if windowLength >= postTrls
    disp('windowLength is too long')
    return
end

%% preallocate vars to save across animals and across individual sessions
% Cell arrays are used to save the beta values of the glm for each
% session. Each row will be an animal, each column a beta value (b1 or b2).
% Similar cell arrays are used to keep track of dose and the SE of b.
% Each entry is a session.
% Drug and control sessions are separate cell arrays.
drug_dose = cell(nAnimals,1); % dose
drug_b    = cell(nAnimals,2); % b0, b1
drug_b_late = cell(nAnimals,2); % b0, b1
npt       = cell(nAnimals,1); % number of trials post in drug sessions
cntr_b    = cell(nAnimals,2); % b0, b1
drug_b_p  = cell(nAnimals,1); % b0 p
cntr_b_p  = cell(nAnimals,1); % b0 p
drug_b_se = cell(nAnimals,2); % b0 se, b1 se
cntr_b_se = cell(nAnimals,2); % b0 se, b1 se

% variables to concatenate the first 100 trials post of each session
dataPostDrug_wL = cell(nAnimals,1); % only first 100 trials (windowLength, wL)
dataPostDrug_pT = cell(nAnimals,1); % up to first 500 trials (postTrls, pT)

%% one subplot per monkey
for m = 1 : nAnimals
    
    % get a monkey name
    monkey = getMyMonkey(m);
    
    % load data, remove incomplete trials
    data = loadInactivationData(monkey);
    data = discardAbortedTrials(data);
    
    % run a glm for each session
    for s = unique(data(:,C.sessionNumber))'
        
        % get the relevant post trials in this session
        s_ix = data(:,C.sessionNumber) == s & ...
               data(:,C.pre0_post1) == 1;
        sessionData = data(s_ix,:);
        
        % original trialNumber in data matrix also counts the (not included) aborted
        % trials, replace trialNumber in data matrix with 1:ntrials for the glm
        sessionData(:,C.trialNumber) = 1 : size(sessionData,1);
        
        % run glm for each individual session using the first 100 trials
        % first, generate a predictor matrix
        if m < 3 % use information about dot coherence and dot duration for monkeys 1 and 2
            sessionData_pred = ( sessionData(1 : windowLength, C.signedContraCoherence)  .* ...
                               ( sessionData(1 : windowLength, C.dot_duration) ).^pow_rdm(m));
        else % only use information about asynchrony for monkeys 3 and 4
            sessionData_pred = sessionData(1 : windowLength, C.signedContraCoherence);
        end
        % then, run the glm
        [b, ~, bstats] = glmfit(sessionData_pred, ...
                                sessionData(1 : windowLength, C.contraChoice), ...
                                'binomial');
                            
        % Next, we will want to use trial 401-500, let's see if we have that
        % many trials, if not, we'll use the last 100 instead
        if size(sessionData,1) < postTrls
            n_postTrls = size(sessionData,1);
            % if this is a drug session, it will be plotted in the right
            % panels, and we will want to know if there are not enough late
            % trials, so we will print a message
            if sessionData(1,C.drug_dose_session) > 0
                disp(['Monkey ' monkey ' only has ' num2str(n_postTrls) ' available for analysis in post inactivation block in session ' num2str(s)])
            end
        else
            n_postTrls = postTrls;
        end
        
        % run glm for each individual session using trials 401 - 500
        if m < 3
            sessionData_late_pred = ( sessionData(n_postTrls - windowLength + 1 : n_postTrls, C.signedContraCoherence) .* ... 
                                    ( sessionData(n_postTrls - windowLength + 1 : n_postTrls, C.dot_duration) ).^pow_rdm(m));
        else
            sessionData_late_pred = sessionData(n_postTrls - windowLength + 1 : n_postTrls, C.signedContraCoherence);
        end
        [b_late, ~, ~] = glmfit(sessionData_late_pred, ...
                                sessionData(n_postTrls - windowLength + 1 : n_postTrls, C.contraChoice), ...
                                'binomial');
                
        % We save the beta values in different places: we split by control
        % (drug_dose_session<=0) and drug (drug_dose_session>0)
        if sessionData(1,C.drug_dose_session) <= 0 % sham (-1) or saline (0)
            cntr_b{m,1}       = [cntr_b{m,1}    b(1)];
            cntr_b{m,2}       = [cntr_b{m,2}    b(2)];
            cntr_b_se{m,1}    = [cntr_b_se{m,1} bstats.se(1)];
            cntr_b_se{m,2}    = [cntr_b_se{m,2} bstats.se(2)];
            cntr_b_p{m,1}     = [cntr_b_p{m,1}  bstats.p(1)]; 
            
        elseif sessionData(1,C.drug_dose_session) > 0 % muscimol (.5 or 1), or clozapine dose (.125, .150, .200, .225, .300 mg/kg)
            
            drug_b{m,1}       = [drug_b{m,1}      b(1)];
            drug_b{m,2}       = [drug_b{m,2}      b(2)];
            drug_b_late{m,1}  = [drug_b_late{m,1} b_late(1)];
            drug_b_late{m,2}  = [drug_b_late{m,2} b_late(2)];
            npt{m,1}          = [npt{m,1} n_postTrls];
            drug_b_se{m,1}    = [drug_b_se{m,1}   bstats.se(1)];
            drug_b_se{m,2}    = [drug_b_se{m,2}   bstats.se(2)];
            drug_dose{m,1}    = [drug_dose{m,1}   sessionData(1,C.drug_dose_session)];
            drug_b_p{m,1}     = [drug_b_p{m,1}    bstats.p(1)];             
            dataPostDrug_wL{m,1} = [dataPostDrug_wL{m,1}; sessionData(1 : windowLength, :)];
            dataPostDrug_pT{m,1} = [dataPostDrug_pT{m,1}; sessionData(1 : n_postTrls, :)];
        end
        
    end % end of loop across sessions
    
    %% plot stats from individual sessions
    % Left graphs, one subplot for each monkey:
    % b0 for individual session GLMs        
    subplot(nRows, nCols, nCols * (m - 1) + 1)

    % find the low drug dose session for monkey 1, it will be a gray point
    if m == 1
        lowDose = drug_dose{m,1} < 1;
    end    
    
    hold all
    
    % Extend x-axis by this factor
    extAxis = .1;
    
    % how many drug sessions for this animal?
    nSess = size(drug_b{m,1},2);
    
    % draw horizontal line at b0 = 0 that is behind data points
    if m < 4
        line([-1 nSess+1], [0 0], 'color', 'k')
    elseif m == 4
        % stretch the line a bit for monkey 4 (clozapine) and determine 
        % where controls will be plotted 
        drug_range = max(drug_dose{4,1}) - min(drug_dose{4,1});
        drug_shift_point = drug_range * .25;
        line([min(drug_dose{4,1})-1 max(drug_dose{4,1})+drug_shift_point+1], [0 0 ], 'color', 'k')
    end
    
    % generate list of drug session number
    sessNumber = 1 : nSess;
    
    % which drug sessions have a significantly positive b0-value?
    signB0 = drug_b_p{m,1} < .05;
    
    
    % for monkey 4, we do NOT want to sort by session number, but, instead,
    % by dose. Let's resort the dosages in descending order (high to low)
    if m == 4
        [~, reshuffleDoseIndex] = sort(drug_dose{4,1},'descend'); 
        signB0 = signB0(reshuffleDoseIndex);
        drug_b{m,1} = drug_b{m,1}(reshuffleDoseIndex);
        drug_b_late{m,1} = drug_b_late{m,1}(reshuffleDoseIndex);
        drug_dose{m,1} = drug_dose{m,1}(reshuffleDoseIndex);
        npt{m,1} = npt{m,1}(reshuffleDoseIndex);
    end
    
    % plot b0 in first 100 trials in drug data per session
    if m < 4
        % black scatter points on top of errorbars
        errorbar(sessNumber, drug_b{m,1}, drug_b_se{m,1}, ...
            'color', myBlack, 'linestyle', 'none', 'linewidth', 2)
        scatter(sessNumber, drug_b{m,1}, 100, ...
            'markerfacecolor', myBlack, 'markeredgecolor', myBlack)

        % superimpose a gray point for the low dose session for monkey 1
        if m == 1
            errorbar(sessNumber(lowDose), drug_b{m,1}(lowDose), drug_b_se{m,1}(lowDose), ...
                'color', myLigthGray, 'linestyle', 'none', 'linewidth', 2)
            scatter(sessNumber(lowDose), drug_b{m,1}(lowDose), 100, ...
                'markerfacecolor', myLigthGray, 'markeredgecolor', myLigthGray)
        end
        
    elseif m == 4
        % black scatter points on top of errorbars
        errorbar(drug_dose{4,1}, drug_b{m,1}, drug_b_se{m,1}, ...
            'color', myBlack, 'linestyle', 'none', 'linewidth', 2)
        scatter(drug_dose{4,1}, drug_b{m,1}, 100, ...
            'markerfacecolor', myBlack, 'markeredgecolor', myBlack)

        set(gca, 'xdir', 'reverse')
    end
    
    if m < 4
        % plot control data as black triangular scatter points at 0
        scatter(zeros(1,size(cntr_b{m,1},2)), cntr_b{m,1}, 100, ...
            '^', 'markeredgecolor', myBlack)
    elseif m == 4
        % plot control data at a location shifted to the left
        scatter(ones(1,size(cntr_b{m,1},2))*max(drug_dose{4,1})+drug_shift_point, cntr_b{m,1}, 100, ...
            '^', 'markeredgecolor', myBlack)
    end
    
    % make labels pretty
    axis tight; set(gca,'TickDir','out','FontSize',18,'Box','off');
    ylabel(['\beta_0 (Trial 1' char(8211) num2str(windowLength) ')'], 'color', myBlack)
    if m < 4
        xticks(0 : nSess)
    end
    
    % make axis pretty
    if m == 1 || m == 2
        set(gca, 'ylim', ylim_dots) 
    elseif m == 3 || m ==4
        set(gca, 'ylim', ylim_async) 
    end
    % x axis is set according to drug session or drug dose
    if m < 4
        set(gca, 'xlim', [-(nSess * extAxis) (nSess + (nSess * extAxis))])
    elseif m == 4
        set(gca, 'xlim', [(min(drug_dose{4,1}) - (drug_range * extAxis * 1.2)) (max(drug_dose{4,1}) + drug_shift_point + (drug_range * extAxis * 1.2))])
    end

    % for sessions with significant bias, add astrisk above data point
    valBelowTopY = .9 * max(ylim);

    if m < 4
        scatter(sessNumber(signB0), ones(1,sum(signB0==1))*valBelowTopY, 50,  '*', ...
            'markeredgecolor', myBlack)
    elseif m == 4
        scatter(drug_dose{4,1}(signB0), ones(1,sum(signB0==1))*valBelowTopY, 50,  '*', ...
            'markeredgecolor', myBlack)
    end

    % label control sessions with c on x-axis
    if m < 4
        ax = gca;
        xticklabels = get(ax, 'XTickLabel');
        xticklabels{1} = 'c';
        xlabel('Muscimol session number')
    elseif m == 4
        ax = gca;
        ax.XTick = [fliplr(drug_dose{4,1}) ...
            max(drug_dose{4,1}) + drug_shift_point];
        xticklabels = get(ax, 'XTickLabel');
        xticklabels{end} = 'c';
        xticklabels{1} = num2str(drug_dose{4,1}(5), '%.3f');
        xticklabels{2} = ' ';
        xticklabels{3} = num2str(drug_dose{4,1}(3), '%.3f');
        xticklabels{4} = ' ';
        xticklabels{5} = num2str(drug_dose{4,1}(1), '%.3f');
        xlabel('Clozapine dose (mg/kg)')
    end

    set(ax, 'XTickLabel', xticklabels);

    % add monkey number as text
    if m < 4
        text(min(xlim), max(ylim) + max(ylim)*.2, ['Monkey ' num2str(m)], 'FontSize', 18, 'fontweight','bold')
    elseif m == 4 % correct for flipped x-axis
        text(max(xlim), max(ylim) + max(ylim)*.2, ['Monkey ' num2str(m)], 'FontSize', 18, 'fontweight','bold')
    end
        
    % Right graphs, one subplot for each monkey:
    subplot(nRows, nCols, nCols * (m - 1) + 2)
    hold all
    
    % for sessions with significant bias, plot b0 at start and end
    plot(1:2,[drug_b{m,1}(signB0); drug_b_late{m,1}(signB0)],'linewidth',2, ...
        'color', myBlack, 'marker','o', 'markerfacecolor', myBlack, 'markersize', 8)
    % only if a session has less than the required number of trials,
    % superimpose a grey data point on the late marker
    if sum(npt{m}<postTrls)
        plot(2,drug_b_late{m,1}(npt{m}<postTrls),'linewidth',2, ...
            'color', myLigthGray, 'marker','o', 'markerfacecolor', myLigthGray, 'markersize', 8)
    end
    axis tight; set(gca,'TickDir','out','FontSize',18,'Box','off');
    set(gca, 'xlim', [0 3], 'xtick', 1:2, 'xticklabel', {['Trial 1' char(8211) num2str(windowLength)],['Trial ' num2str(postTrls-windowLength+1) char(8211) num2str(postTrls)]})
    line(xlim, [0 0], 'color', 'k')
    ylabel('\beta_0')
    % y axis is matched across tasks (dots vs async)
    if m == 1 || m == 2
        set(gca, 'ylim', ylim_dots) 
    elseif m == 3 || m ==4
        set(gca, 'ylim', ylim_async) 
    end
            
    %% Across-sessions fits
   
    % Create list of coherence values as predictor for glm
    pred_wL_coh = dataPostDrug_wL{m,1}(:,C.signedContraCoherence);
    if m<3
        pred_wL_coh_dotDur = (dataPostDrug_wL{m,1}(:,C.signedContraCoherence) ) .* ...
                             (dataPostDrug_wL{m,1}(:,C.dot_duration).^pow_rdm(m));
    end
    
    % Create session number for consecutive drug sessions
    pred_wL_sessNr = reshape(repmat([1 : nSess], windowLength, 1), [1, windowLength * nSess])';

    % Create list of choices
    choice_wL = dataPostDrug_wL{m,1}(:,C.contraChoice);
    % Create list of clozapine dose, only used for glm for monkey 4
    pred_wL_dose = dataPostDrug_wL{m,1}(:,C.drug_dose_session); 

    % run glm
    if m==1
        % ignore low dose session
        loIdx = dataPostDrug_wL{m,1}(:,C.drug_dose_session) == .5;
        pred_wL_coh_dotDur(loIdx) = [];
        pred_wL_sessNr(loIdx) = [];
        choice_wL(loIdx) = [];
    end
    
    
    if m < 3 % muscimol sessions, dots task
        [~, ~, bstats_acrossSessions] = glmfit([pred_wL_coh_dotDur pred_wL_sessNr], choice_wL, 'binomial');

        % plot a line that shows compensation across sessions
        % we use b0 (average bias) PLUS b2*sessionNumber for monkey 1-3
        subplot(nRows, nCols, nCols * (m - 1) + 1), hold on
        plot([1,nSess],[bstats_acrossSessions.beta(1) + bstats_acrossSessions.beta(3)*1, ...
            bstats_acrossSessions.beta(1) + bstats_acrossSessions.beta(3)*nSess],...
            'color',myLigthGray,'LineWidth',2)

    elseif m == 3 % muscimol sessions, async task
        [~, ~, bstats_acrossSessions] = glmfit([pred_wL_coh pred_wL_sessNr], choice_wL, 'binomial');

        % plot a line that shows compensation across sessions
        % we use b0 (average bias) PLUS b2*sessionNumber for monkey 1-3
        subplot(nRows, nCols, nCols * (m - 1) + 1), hold on
        plot([1,nSess],[bstats_acrossSessions.beta(1) + bstats_acrossSessions.beta(3)*1, ...
            bstats_acrossSessions.beta(1) + bstats_acrossSessions.beta(3)*nSess],...
            'color',myLigthGray,'LineWidth',2)

    elseif m == 4 % dreadd sessions, async task
        [~, ~, bstats_acrossSessions] = glmfit([pred_wL_coh pred_wL_dose], choice_wL, 'binomial'); 

        % plot a line that shows the dose dependancy
        % we use b0 (average bias) PLUS b2*dose for monkey 4
        subplot(nRows, nCols, nCols * (m - 1) + 1), hold on
        plot([max(drug_dose{4,1}) min(drug_dose{4,1})],...
            [bstats_acrossSessions.beta(1) + bstats_acrossSessions.beta(3)*max(pred_wL_dose), ...
             bstats_acrossSessions.beta(1) + bstats_acrossSessions.beta(3)*min(pred_wL_dose)],...
             'color',myLigthGray,'LineWidth',2)

    end
    
end % end of loop across monkeys

