function prettifyPsychometricFunction(fignr, nRows, nCols)

%% define settings
fsl = 20; % fontsize

%% call figure, get handle, change size
figure(fignr)
a = gcf;
a.Position = [100 100 1500 500];

%% settings
% axis
motionAxis   = [-53 53 0 1];
motionXticks = [-50 -25 0 25 50];
asyncAxis    = [-.25 .25 0 1];
asyncXticks  = [-.2 -.1 0 .1 .2];

% labels
motionXlabel = 'Motion strength (% coh)';
asyncXlabel  = 'Target asynchrony (s)';
yLabel       = 'Proportion contralateral choices'; 

%% subplot 1, Napoleon
subplot(nRows, nCols, 1)

xlabel(motionXlabel, 'FontSize', fsl)
axis(motionAxis)
xticks(motionXticks)
xticklabels(motionXticks)

% most leftward plot for dots task gets ylabel
ylabel(yLabel, 'FontSize', fsl)

%% subplot 2, Damien
subplot(nRows, nCols, 2)

xlabel(motionXlabel, 'FontSize', fsl)
axis(motionAxis)
xticks(motionXticks)
xticklabels(motionXticks)

%% subplot 3, Yossi
subplot(nRows, nCols, 3)

xlabel(asyncXlabel, 'FontSize', fsl)
axis(asyncAxis)
xticks(asyncXticks)
xticklabels(asyncXticks)

% most leftward plot for async task gets ylabel
ylabel(yLabel, 'FontSize', fsl)

%% subplot 3, Mega
subplot(nRows, nCols, 4)

xlabel(asyncXlabel, 'FontSize', fsl)
axis(asyncAxis)
xticks(asyncXticks)
xticklabels(asyncXticks)

%% across all subplots
for i = 1 : (nRows * nCols)
    subplot(nRows, nCols, i)
    title(['Monkey ' num2str(i)])
    line(xlim,[0.5 0.5],'color','k')
    line([0 0],ylim,'color','k')
    yticks([0 .5 1])
    h=gca;
    axprefs(h)
    h.FontSize=fsl;
end
    