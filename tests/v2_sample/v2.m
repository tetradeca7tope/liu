% This script compare the sampling strategies for each of the graphs.
clear all
close all

% Specify parameters for the graph
nRows = 30;
nCols = 30;
nNodes = nRows * nCols;
nStates = 25;

% Define the parameters for the experiment
nTrials = 500;
nSamples = 30;
burnIn = 0;

% Generate the Grids and the Blocks
genGridUGMs;
genSamplingStrategies;
numGrids = numel(gridEdgePots);
numStrategies = numel(strategyBlocks);
edgeStruct.maxIter = nSamples;

% Initialize a random starting state
% initialStates = randi(nStates, [nTrials, nNodes]);
initialState = ones(nNodes, 1); % use same init for all trials.
gridResults = cell(numGrids, 1);

for gridIter = 1: numGrids

  % Prepare struct for saving results for this grid
  gridRes.gridName = gridNames{gridIter};
  gridRes.strategyResults = cell(numStrategies, 1);
  gridRes.runTimeMeans = zeros(numStrategies, 1);
  gridRes.runTimeStds = zeros(numStrategies, 1);

  for stratIter = 1: numStrategies

    % Prepare struct for saving results for this strategy
    stratRes.strategyName = strategyNames{stratIter};
    stratRes.allSamples = zeros(nSamples, nNodes, nTrials);

    % prelims
    blocks = strategyBlocks{stratIter};
    gridEdgePotential = gridEdgePots{gridIter};
    gridNodePotential = gridNodePots{gridIter};
    currStratRunTimes = zeros(nTrials, 1);
    description = sprintf('Grid: %s\nStrategy:%s\n', gridNames{gridIter}, ...
                          strategyNames{stratIter});
    fprintf('%s', description);
    
    for trialIter = 1:nTrials
%       currInitState = initialStates(trialIter, :)';
      tic,
      if strcmp(stratRes.strategyName,'Naive')
        samples = UGM_Sample_Gibbs(gridNodePotential, gridEdgePotential, ...
          edgeStruct, burnIn);
      else
        samples = UGM_Sample_Block_Gibbs(gridNodePotential, ...
          gridEdgePotential, edgeStruct, burnIn, blocks, @UGM_Sample_Tree, ...
          initialState);
      end
      currStratRunTimes(trialIter) = toc;
      stratRes.allSamples(:,:,trialIter) = samples'; % save the samples
    end

    % Save results
    gridRes.strategyResults{stratIter} = stratRes;
    gridRes.runTimeMeans(stratIter) = mean(currStratRunTimes);
    gridRes.runTimeStds(stratIter) = std(currStratRunTimes);

    fprintf('Running Time: %0.4f +/- %0.4f  x  %d secs\n', ...
      gridRes.runTimeMeans(stratIter), gridRes.runTimeStds(stratIter), ...
      nTrials);
    fprintf('\n');
  end

  % Store the results for this grid
  gridResults{gridIter} = gridRes;
end

% Finally plot the results
summarizeNodeMeans(gridResults, nNodes, nSamples, nSamples, randi(nNodes), 1);

