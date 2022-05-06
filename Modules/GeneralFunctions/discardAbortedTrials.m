function [data, nAborted] = discardAbortedTrials(data, countOnly)
% function [data, nAborted] = discardAbortedTrials(data, countOnly)
% Remove incomplete trials and count how many were removed.
% If countOnly flag is true, only count how many aborted trials are in data
% matrix but don't delete them. Default for countOnly is false. 

if nargin==1
    countOnly = false; % default is to remove aborted trials
end

C = columnCodesInactivation; 

abortedTrials = data(:,C.target_choice)<0;
nAborted = sum(abortedTrials);
if ~countOnly
    data(abortedTrials,:)=[];
end
