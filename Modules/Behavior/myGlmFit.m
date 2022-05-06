function [b, xvals, yfit, stats] = myGlmFit(signedCoh, choice)
%function [b, xvals, yfit, stats] = myGlmFit(signedCoh, choice)

cohList = unique(signedCoh);

b = nan(2,1);
steps = 100;
xvals = nan(steps,1);
yfit  = nan(steps,1);
xvals(:,1) = linspace(min(cohList), max(cohList), steps);

[b(:,1), ~, stats] = glmfit(signedCoh, choice, 'binomial');
yfit(:,1) = glmval(b(:,1), xvals(:,1), 'logit');
