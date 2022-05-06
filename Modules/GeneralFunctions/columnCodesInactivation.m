function E = columnCodesInactivation
% Data is saved in a matrix per monkey. 
% Each row is a trial. 
% Each column is a piece of relevant information from that trial.
% This list helps us find the correct column. 
% Note: some information is experiment specific, e.g., the async task does
% not have a 'dot diameter' variable. In such cases, the entry in the data
% matrix is nan. 

E.monkeyID = 1; 
E.sessionNumber = 2; 
E.fileNumber = 3; 
E.trialNumber = 4; % count starting at 1 for each combined 'pre' and 'post' dataset, include aborted trials
E.trial_type = 5;
E.dot_diam = 6;
E.coherence = 7;
E.dot_dir = 8;
E.target1_x = 9;
E.target1_y = 10;
E.target2_x = 11;
E.target2_y = 12;
E.dot_duration = 13;
E.fixation_x = 14;
E.fixation_y = 15;
E.dots_x = 16;
E.dots_y = 17;
E.dot_speed = 18;
E.date = 19; % YYYYMMDD format of session date
E.seedvar = 20;
E.seed = 21;
E.pre0_post1 = 22; % codes for pre inactivation (0) or post (1)
E.time_FP_on = 23;
E.time_fix_acq = 24;
E.time_target_on = 25;
E.time_target_off = 26;
E.time_dots_on = 27;
E.time_dots_off = 28;
E.time_FP_off = 29;
E.time_saccade = 30;
E.time_targ_acq = 31;
E.time_reward = 32;
E.time_end = 33;
E.target_choice = 34; % 1 /0 /-1 /-2 /-10 = Corr/Err/NoChoice/FixBreak/No fix acq
E.correct_target = 35; 
E.isCorrect = 36;
E.react_time = 37;
E.drug_type_session = 38; % sham (-1), saline (0), muscimol (1), or clozapine (1)
E.drug_dose_session = 39; % sham (-1), saline (0), low-dose muscimol (.5), muscimol (1), clozapine dose (mg/kg)
E.drug_type_experiment = 40; % pharmacology (1) or chemogenetics (2)
E.RF_x = 41;
E.RF_y = 42;
E.time_target1_on = 43; % For asynchronous target paradigms
E.time_target2_on = 44; % For asynchronous target paradigms
E.offset_frame_target1and2 = 45; % Time between target 1 and 2 onset. Exact number of frames
E.target_asynchrony = 46; % Time between target 1 and 2 onset. Exact time in ms
E.time_since_previous_trial = 47;
E.reward_size = 48;
E.reward_prize = 49; 
E.signedCoherence = 50; % either signed coherence (dots) or signed async
E.rightwardChoice = 51;
E.signedIpsiCoherence = 52; % either signed ipsi coherence (dots) or signed ipsi async
E.ipsiChoice = 53;
E.signedContraCoherence = 54; % either signed contra coherence (dots) or signed contra async
E.contraChoice = 55;
