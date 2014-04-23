function gridResults = summarizeNodeMeans(gridResults, nNodes, nSamples, ...
          meansAtIter, progressAtNode, plotOk)
% Given the grid Results, this plots the node means at Iteration meansAtIter
% It does the following if plotOk is true
% 1. plots the empirical mean and standard error of each node at the
% meansAtIter^th iteration.
% 2. Plots the empirical mean of the node at progressAtNode with Iteration.
% Also plots the standard errors as error bars.
% 3. TODO: Redo 2 with adjustments for computational time.

  numGrids = numel(gridResults);
  % Create a cell array of colors
  plotCols = {'b', 'r', 'g', 'c', 'm', 'k'};
  plotDesc = {'-o', '-x', '-s', '-d', '-*', '-^'};
  strategyNames = {};

  for gridIter = 1:numGrids
    gridRes = gridResults{gridIter};
    if isempty(gridRes) continue; end

    % Iterate through each strategy
    currNumStrategies = numel(gridRes.strategyResults);
    strategyMeans = zeros(currNumStrategies, nNodes);
    strategyStdErrs = zeros(currNumStrategies, nNodes);
    nodeMeans = zeros(currNumStrategies, nSamples);
    nodeStdErrs = zeros(currNumStrategies, nSamples);

    for stratIter = 1:currNumStrategies
      stratRes = gridRes.strategyResults{stratIter};
      if isempty(stratRes) continue; end
      % extract the mean and std over each trial.
      strategyMeans(stratIter, :) = ...
        mean(stratRes.allSamples(meansAtIter, :, :), 3);
      strategyStdErrs(stratIter, :) = ...
        mean(stratRes.allSamples(meansAtIter, :, :).^2, 3) - ...
        mean(stratRes.allSamples(meansAtIter, :, :), 3).^2;

      % Obtain the values at the node nodeIdx
      nodeSamples = stratRes.allSamples(:, progressAtNode, :); 
      nodeSamples = reshape(nodeSamples, size(nodeSamples, 1), ...
                            size(nodeSamples, 3))';
      nodeMeans(stratIter, :) = mean(nodeSamples);
      nodeStdErrs(stratIter, :) = std(nodeSamples);

      % store the strategy name
      strategyNames{stratIter} = stratRes.strategyName;
    end


    % Store these results to gridResults.
    % TODO: stores at the same place regardless of meansAtIter so can't store
    % results for all iters. But not worrying about his for now since this
    % function is mostly aimed at the last iteration.
    gridResults{gridIter}.strategyMeans = strategyMeans;
    gridResults{gridIter}.strategyStdErrs = strategyStdErrs;
    gridResults{gridIter}.nodeMeans = nodeMeans;
    gridResults{gridIter}.nodeStdErrs = nodeStdErrs;
    
    % Finally plot the results for this figure;
    if plotOk
      figure;
      % First the means
      subplot(1, 2, 1); hold on,
      for stratIter = 1:currNumStrategies
        plot(strategyMeans(stratIter, :), ...
          plotDesc{stratIter}, 'Color', plotCols{stratIter});
      end
      legend(strategyNames);
      titleStr = sprintf('Means for Grid: %s', gridRes.gridName);
      title(titleStr);
      % Then the Standard Errors
      subplot(1, 2, 2); hold on,
      for stratIter = 1:currNumStrategies
        plot(strategyStdErrs(stratIter, :), ...
          plotDesc{stratIter}, 'Color',plotCols{stratIter});
      end
      legend(strategyNames);
      titleStr = sprintf('Stds for Grid: %s', gridRes.gridName);
      title(titleStr);

      % Now plot the progress of the node
      figure; hold on,
      for stratIter = 1:currNumStrategies
        errorbar(nodeMeans(stratIter, :), nodeStdErrs(stratIter, :), ...
          plotDesc{stratIter}, 'Color',plotCols{stratIter});
      end
      legend(strategyNames);
      titleStr = sprintf('Sample # vs Mean @ Node %d: %s', ...
                  progressAtNode, gridRes.gridName);
      title(titleStr);
      % plot w/o error bars too
      figure; hold on,
      for stratIter = 1:currNumStrategies
        plot(nodeMeans(stratIter, :), ...
          plotDesc{stratIter}, 'Color',plotCols{stratIter});
      end
      legend(strategyNames);
      titleStr = sprintf('Sample # vs Mean @ Node %d: %s', ...
                  progressAtNode, gridRes.gridName);
      title(titleStr);

    end % end plotOk

  end % end for gridIter

end

