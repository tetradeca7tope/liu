% Derived from examples in example_UGM_MCMC and example_UGM_Block

%% Make noisy X
getNoisyX

% No burnin, we're trying to test convergence.
burnIn = 0;
iterRange = 20;
stepSize = 2;
maxSteps = (iterRange/stepSize)

% Naive Gibbs
figure(3);

for i = 1:maxSteps
    edgeStruct.maxIter = i*stepSize;
	
    maxOfMarginalsGibbsDecode = UGM_Decode_MaxOfMarginals(nodePot,edgePot,edgeStruct, @UGM_Infer_Sample,@UGM_Sample_Gibbs,burnIn);

    reconX = reshape(maxOfMarginalsGibbsDecode -1., nRows, nCols)
    errorRatesNaive(i) = (sum(sum(abs(reconX - origX)))) / nNodes
    subplot(2,5,i);
    imagesc(reconX)
    colormap gray
end

%%%% HF Block Gibbs sampling

%% Make Blocks
nodeNums = reshape(1:nNodes,nRows,nCols);
blocks1 = zeros(nNodes/2,1);
blocks2 = zeros(nNodes/2,1);
b1Ind = 0;
b2Ind = 0;
for j = 1:nCols
    if mod(j,2) == 1
        blocks1(b1Ind+1:b1Ind+nCols-1) = nodeNums(1:nCols-1,j);
        b1Ind = b1Ind+nCols-1;
        
        blocks2(b2Ind+1) = nodeNums(nRows,j);
        b2Ind = b2Ind+1;
    else
        blocks1(b1Ind+1) = nodeNums(1,j);
        b1Ind = b1Ind+1;
        
        blocks2(b2Ind+1:b2Ind+nCols-1) = nodeNums(2:nCols,j);
        b2Ind = b2Ind+nCols-1;
    end
end
blocks = {blocks1;blocks2};

% Visualize the blocks
figure(5)
visual = zeros(nNodes, 1);
for j = 1:b1Ind
    visual(blocks2(j)) = 1;
end
imagesc(reshape(visual, nRows, nCols))
colormap gray


% Precompute the block samples, then we'll make a dummy function to do max of
% marginals that just returns these - this way we sample iterRange times rather
% than numsteps/2 * (iterRange + stepsize)  times

samplesBlockGibbs = UGM_Sample_Block_Gibbs(nodePot,edgePot,edgeStruct,burnIn,blocks,@UGM_Sample_Tree);

figure(6);
for i = 1:maxSteps
    edgeStruct.maxIter = i*stepSize;
	
    maxOfMarginalsGibbsDecode = UGM_Decode_MaxOfMarginals(nodePot,edgePot,edgeStruct, @UGM_Infer_Sample, @(nodePot, edgePot, edgeStruct, v) (samplesBlockGibbs(:, 1:edgeStruct.maxIter)) ,burnIn);

    reconX = reshape(maxOfMarginalsGibbsDecode -1., nRows, nCols)
    errorRatesBlockHF(i) = (sum(sum(abs(reconX - origX)))) / nNodes
    subplot(2,5,i);
    imagesc(reconX)
    colormap gray
end

errorRatesNaive
errorRatesBlockHF
