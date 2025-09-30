%%
clc;
clear;
addpath(genpath('./src'));
set(0, 'DefaultFigureVisible', 'on');

%%

params = setParams();
cords = loadData(params);


cord = cords{1};
cord = preprocessFr(cord, params);
cord = pcaFit(cord, params);
cord = linearFit(cord, params);


%%

plotDeduce(cord, params)