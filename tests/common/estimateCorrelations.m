function corrGraph = estimateCorrelations(nodePot, ...
  edgePot, edgeStruct, numBurnIn, numSamples)
% This function measures the correlations between two variables in the graph and
% outputs a graph whose weights are the estimated correlations.
% @ Wenlu: when you are writing your function/ wrapper you could assume that the
% input is a sparse Matrix.

% nodePot and edgePot are the Node and Edge Potentials. These 2 along with
% edgeStruct are needed by the UGM library for sampling. 
% numBurnIn and numSamples are the number of MCMC samples for estimating the
% correlations.

  if ~exist('numBurnin', 'var')
    numBurnIn = 100;
  end
  if ~exist('numSamples', 'var')
    numSamples = 100000;
  end

  edgeStruct.maxIter = numSamples;
  edgeStruct.useMex = 0;
  samples = UGM_Sample_Gibbs(nodePot, edgePot, edgeStruct, numBurnIn);
  samples = double(samples);
  
  estimMeans = mean(samples')';
  estimStds = std(samples')';
  estimStds = estimStds + double((estimStds == 0));

  % Now for each edge in the graph, compute the correlations
  corrGraph = sparse(double(edgeStruct.nNodes), double(edgeStruct.nNodes));
  for edgeIter = 1:edgeStruct.nEdges
    n1 = edgeStruct.edgeEnds(edgeIter, 1);
    n2 = edgeStruct.edgeEnds(edgeIter, 2);

    edgeSamples = samples([n1, n2], :);
    edgeMeans = estimMeans([n1, n2]);
    edgeStds = estimStds([n1, n2]);
    covarVals = bsxfun(@minus, edgeSamples, edgeMeans);
    covar = mean(covarVals(1,:) .* covarVals(2,:));
    currCorr = covar/ prod(edgeStds);
    corrGraph(n1, n2) = 1 + abs(currCorr);
    corrGraph(n2, n1) = 1 + abs(currCorr);
  end

end

