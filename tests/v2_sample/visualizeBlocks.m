function visualizeGridBlocks(blocks, nRows, nCols)
% Visualize the Blocks for a Grid Graph

  % Prelims
  nNodes = nRows * nCols;
  visual = zeros(nRows, nCols);
  numBlocks = numel(blocks);
  colours = linspace(0, 1, numBlocks);
  % Set colours for each block
  for bIter = 1:numBlocks
    visual(blocks{bIter}) = colours(bIter);
  end

  % Show blocks
  imagesc(visual);
end
