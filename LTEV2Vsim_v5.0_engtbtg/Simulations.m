close all    % Close all open figures
clear        % Reset variables
clc          % Clear the command window

%LTEV2Vsim('help');

%% LTE Autonomous (3GPP Mode 4) - on a subframe basis
% Autonomous allocation algorithm defined in 3GPP standard
%density = [50, 100, 200]; %density(i)

%for i = 1:length(density)
    LTEV2Vsim('BenchmarkPoisson.cfg','simulationTime',40, 'rho', 500,...
        'BRAlgorithm',18, 'camDiscretizationType', 'allSteps', ...
        'NLanes', 4, 'roadWidth', 4, 'roadLength', 2000, 'TypeOfScenario', 'ETSI-Highway', ...
        'printUpdateDelay', true, 'printCBR', true, 'cbrSensingInterval', 0.1, 'MCS_LTE', 7);
%end
%'cV', 90,'roadWidth', 4, 'roadLength', 3000,'TypeOfScenario', 'ETSI-Highway',
