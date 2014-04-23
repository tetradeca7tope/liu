% This function will create blocks for the 3 sampling strategies: Naive,
% Checker Board and HF.

% Parameters
plotOk = false; %true;

% 1. Naive
% ========
naiveBlocks = mat2cell(1:nNodes, 1, ones(1, nNodes))';

% we will need these below
oddRows = (1:2:nRows)';
evenRows = (2:2:nRows)';
oddCols = (1:2:nCols)';
evenCols = (2:2:nCols)';
gridSub2Idx = @(t) sub2ind([nRows nCols], t(:,1), t(:,2));

% 2. Checker Board
% ================
ooNodes = getTwoVecCombs(oddRows, oddCols);
oeNodes = getTwoVecCombs(oddRows, evenCols);
eoNodes = getTwoVecCombs(evenRows, oddCols);
eeNodes = getTwoVecCombs(evenRows, evenCols);
cb1 = [gridSub2Idx(ooNodes); gridSub2Idx(eeNodes)];
cb2 = [gridSub2Idx(oeNodes); gridSub2Idx(eoNodes)];
cbBlocks = {sort(cb1); sort(cb2)};

% 3. Hamze, deFreitas
% ===================
oddColNodes = getTwoVecCombs((1:nRows)', oddCols);
evenColNodes = getTwoVecCombs((1:nRows)', evenCols);
firstRow = getTwoVecCombs(1, (1:nCols)');
lastRow = getTwoVecCombs(nRows, (1:nCols)');
hf1 = setdiff(union(gridSub2Idx(oddColNodes), gridSub2Idx(firstRow)), ...
             gridSub2Idx(lastRow) );
hf2 = setdiff(union(gridSub2Idx(evenColNodes), gridSub2Idx(lastRow)), ...
              gridSub2Idx(firstRow) );
hfBlocks = {sort(hf1); sort(hf2)};

% Plot results
if plotOk
  figure; visualizeBlocks(naiveBlocks, nRows, nCols);
  title('Blocks for Naive Gibbs');
  figure; visualizeBlocks(cbBlocks, nRows, nCols);
  title('Blocks for CB Sampler');
  figure; visualizeBlocks(hfBlocks, nRows, nCols);
  title('Blocks for HF Sampler');
  pause;
end

% Finalize 
strategyNames = {'Naive', 'Checker Board', 'Hamze-Freitas'};
strategyBlocks = {naiveBlocks, cbBlocks, hfBlocks};

