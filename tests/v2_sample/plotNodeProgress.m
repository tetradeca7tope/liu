function plotNodeProgress(gridRes, nodeIdx)
% Plots the progress of the mean of one node vs sample number.
% nodeIdx is the index of the node you pick.

  numGrids = numel(gridResults);
  % Create a cell array of colors
  plotCols = {'b', 'r', 'g', 'c', 'm', 'k'};
  strategyNames = {};


end

function gridResults = summarizeNodeMeans(gridResults, nNodes, atIter, plotOk)
% Given the grid Results, this plots the node means at Iteration atIter


  for gridIter = 1:numGrids
    gridRes = gridResults{gridIter};
    if isempty(gridRes) break; end

    % Iterate through each strategy
    currNumStrategies = numel(gridRes.strategyResults);
    strategyMeans = zeros(currNumStrategies, nNodes);
    strategyStdErrs = zeros(currNumStrategies, nNodes);

    for stratIter = 1:currNumStrategies
      stratRes = gridRes.strategyResults{stratIter};
      if isempty(stratRes) break; end
      % extract the mean and std over each trial.
      strategyMeans(stratIter, :) = mean(stratRes.allSamples(atIter, :, :), 3);
      strategyStdErrs(stratIter, :) = ...
        mean(stratRes.allSamples(atIter, :, :).^2, 3) - ...
        mean(stratRes.allSamples(atIter, :, :), 3).^2;

      % store the strategy name
      strategyNames{stratIter} = stratRes.strategyName;
    end

    % Store these results to gridResults.
    % TODO: stores at the same place regardless of atIter so can't store results
    % for all iters. But not worrying about his for now since this function is
    % mostly aimed at the last iteration.
    gridResults{gridIter}.strategyMeans = strategyMeans;
    gridResults{gridIter}.strategyStdErrs = strategyStdErrs;
    
    % Finally plot the results for this figure;
    if plotOk
      figure;
      % First the means
      subplot(1, 2, 1); hold on,
      for stratIter = 1:currNumStrategies
        plot(strategyMeans(stratIter, :), ...
          plotDesc{stratIter}, 'Color', plotCols{stratIter});
      end
      titleStr = sprintf('Means for Grid: %s', gridRes.gridName);
      legend(strategyNames);
      title(titleStr);
      % Then the Standard Errors
      subplot(1, 2, 2); hold on,
      for stratIter = 1:currNumStrategies
        plot(strategyStdErrs(stratIter, :), ...
          plotDesc{stratIter}, 'Color',plotCols{stratIter});
      end
      titleStr = sprintf('Stds for Grid: %s', gridRes.gridName);
      legend(strategyNames);
      title(titleStr);
    end % end plotOk

  end % end for gridIter

end

