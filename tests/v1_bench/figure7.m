%% Generate a "patch image"

nRows = 20;
nCols = 20;
nStates = 15;
nNodes = nRows * nCols;
patchWidth = 2;
patchHeight = patchWidth;

% How many pixels to flip
noiseLevel = nNodes * .35;

%% Generate the normal image
image = [];
for i = 1:(nRows/patchHeight)
    rowOfPatches = [];
    for j = 1:(nCols/patchWidth)
        %patchState = mod(i * (nRows/patchHeight) + j, nStates);
        patchState = randi(nStates);
        patch = repmat(patchState, [patchHeight, patchWidth]);
        rowOfPatches = [rowOfPatches patch];
    end
    image = [image ; rowOfPatches];
end

%%figure(1);
imagesc(image);
colormap gray

%% Add noise

% Pick the pixels to noise. 
noisyImage = image;
perm = randperm(nNodes, noiseLevel);
for i = 1:noiseLevel
    % Flip the pixel, force it to _not_ end up being the same thing
    old = image(ind2sub(size(image), perm(i)));
    offset = randi(nStates - 1);
    noisyImage(ind2sub(size(image), perm(i))) = mod(old + offset, nStates) + 1;
end

%%figure(2);
imagesc(noisyImage);
colormap gray

%% Construct the UGM -- following the construction in ../UGM/examples/getNoisyX.m 


adj = sparse(nNodes,nNodes);

% Add Down Edges
ind = 1:nNodes;
exclude = sub2ind([nRows nCols],repmat(nRows,[1 nCols]),1:nCols); % No Down edge for last row
ind = setdiff(ind,exclude);
adj(sub2ind([nNodes nNodes],ind,ind+1)) = 1;

% Add Right Edges
ind = 1:nNodes;
exclude = sub2ind([nRows nCols],1:nRows,repmat(nCols,[1 nRows])); % No right edge for last column
ind = setdiff(ind,exclude);
adj(sub2ind([nNodes nNodes],ind,ind+nRows)) = 1;

% Add Up/Left Edges
adj = adj+adj';
edgeStruct = UGM_makeEdgeStruct(adj,nStates);

% Make nodePot
alpha = .15
nodePot = zeros(nNodes,nStates);
for i = 1:nStates
    nodePot(:,i) = ((noisyImage(:) == i) + alpha) / (nStates * alpha + 1);
end
nodePot;

% Make edgePot
edgePot = zeros(nStates,nStates,edgeStruct.nEdges);
repblock = ones(nStates, nStates) + diag(repmat(2, nStates, 1));
%edgePot = repmat([1.35 1;1 1.35],[1 1 edgeStruct.nEdges]);
edgePot = repmat(repblock,[1 1 edgeStruct.nEdges]);


burnIn = 0;
iterRange = 10;
maxSteps = 10;
stepSize = iterRange/maxSteps;

%%% Generate the initial point that all of the MCMC chains will start from
% Start at max of node potentials (ie: basically from the corrupted image)
%[junk initial] = max(nodePot, [], 2);

% Random initialization
initial = randi(nStates, [nNodes 1]);

% Naive Gibbs
%%figure(3);

edgeStruct.maxIter = iterRange;
edgeStruct.useMex = 0;
tic;
samplesNaiveGibbs = UGM_Sample_Gibbs(nodePot,edgePot,edgeStruct,burnIn, initial);
toc

for i = 1:maxSteps
    edgeStruct.maxIter = i*stepSize;
	
    maxOfMarginalsGibbsDecode = UGM_Decode_MaxOfMarginals(nodePot,edgePot,edgeStruct, @UGM_Infer_Sample, @(nodePot, edgePot, edgeStruct, v) (samplesNaiveGibbs(:, 1:edgeStruct.maxIter)),burnIn);

    %maxOfMarginalsGibbsDecode = UGM_Decode_MaxOfMarginals(nodePot,edgePot,edgeStruct, @UGM_Infer_Sample,@UGM_Sample_Gibbs,burnIn);

    recon = reshape(maxOfMarginalsGibbsDecode, nRows, nCols);
%    recon = double(reshape(samplesNaiveGibbs(:,edgeStruct.maxIter), ...
%                     nRows, nCols));
    errorRatesNaive(i) = (sum(sum(abs(1 - (recon == image))))) / nNodes;
    subplot(2,5,i);
    imagesc(recon);
    colormap gray
end

%%% Checker

%% Make Blocks
blocks1 = [];
blocks2 = [];
nodeNums = reshape(1:nNodes,nRows,nCols);
for j = 1:nCols
  for i = 1:nRows
     if mod(i, 2) == mod(j, 2)
        blocks1 = [blocks1; sub2ind([nRows nCols], i, j)];
     else
        blocks2 = [blocks2; sub2ind([nRows nCols], i, j)];
     end
  end
end
b1Ind = nNodes/2;
blocks = {blocks1;blocks2};

%%% Visualize the blocks
%%%figure(4);
%visual = zeros(nNodes, 1);
%for j = 1:b1Ind
%    visual(blocks2(j)) = 1;
%end
%imagesc(reshape(visual, nRows, nCols));
%colormap gray

%%figure(5);
edgeStruct.maxIter = iterRange;
tic;
[nodeBelHist junk] = UGM_Sample_Infer_Block_Gibbs(nodePot,edgePot,edgeStruct,burnIn,blocks,...
                                                  @UGM_Sample_Infer_Tree, initial);
toc

for i = 1:maxSteps
    upto = i*stepSize;
    [junk nodeLabels] = max(nodeBelHist(:, :, upto), [], 2);
    recon = reshape(nodeLabels, nRows, nCols);
    errorRatesBlockCB(i) = (sum(sum(abs(1 - (recon == image))))) / nNodes;
    subplot(2,5,i);
    imagesc(recon);
    colormap gray
end

%%% Our algorithm 

display('Computing correlations.')
%corrGraph = estimateCorrelations(nodePot, edgePot, edgeStruct, 10, 10000);
corrGraph = estimateCorrelations(nodePot, edgePot, edgeStruct, 10, 1000);
display('Partitioning.')
partition = treePartition('GreedyTree', corrGraph);

% We need to convert the partition into a cell array and remove the trailing zeros
% that wenlu had to add.
[nBlocks, junk] = size(partition);
blocks = {};
for i = 1:nBlocks
	row = partition(i, :);
	last = find(row, 1, 'last');
	blocks{i} = row(1:last)';
end

blocks = blocks'

%%figure(6);
edgeStruct.maxIter = iterRange;
tic;
[nodeBelHist junk] = UGM_Sample_Infer_Block_Gibbs(nodePot,edgePot,edgeStruct,burnIn,blocks,...
                                                  @UGM_Sample_Infer_Tree, initial);
toc

for i = 1:maxSteps
    upto = i*stepSize;
    [junk nodeLabels] = max(nodeBelHist(:, :, upto), [], 2);
    recon = reshape(nodeLabels, nRows, nCols);
    errorRatesBlockOT(i) = (sum(sum(abs(1 - (recon == image))))) / nNodes;
    subplot(2,5,i);
    recon(1:5, 1:5)
    imagesc(recon);
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

%% Visualize the blocks
%%%figure(6)
%visual = zeros(nNodes, 1);
%for j = 1:b1Ind
%    visual(blocks2(j)) = 1;
%end
%imagesc(reshape(visual, nRows, nCols));
%colormap gray

%%figure(7);
edgeStruct.maxIter = iterRange;
tic;
[nodeBelHist junk] = UGM_Sample_Infer_Block_Gibbs(nodePot,edgePot,edgeStruct,burnIn,blocks,...
                                                  @UGM_Sample_Infer_Tree, initial);
toc

for i = 1:maxSteps
    upto = i*stepSize;
    [junk nodeLabels] = max(nodeBelHist(:, :, upto), [], 2);
    recon = reshape(nodeLabels, nRows, nCols);
    errorRatesBlockHF(i) = (sum(sum(abs(1 - (recon == image))))) / nNodes;
    subplot(2,5,i);
    imagesc(recon);
    colormap gray
end


errorRatesNaive
errorRatesBlockCB
errorRatesBlockOT
errorRatesBlockHF

%%figure(8);
title('Error rate vs. Samples');
ylabel('Error rate');
xlabel('Number of samples');
plot(errorRatesNaive, 'b-o'); hold on,
plot(errorRatesBlockCB, 'r-x');
plot(errorRatesBlockHF, 'g-x');
legend('Naive', 'Checker Board', 'Hamze-Freitas');

