%% Generate a "patch image"

nRows = 50;
nCols = 50;
nStates = 15;
nNodes = nRows * nCols;
patchWidth = 5;
patchHeight = patchWidth;

% How many pixels to flip
noiseLevel = nNodes * .20;

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

figure;
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

figure;
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

% Naive Gibbs
figure(3);

edgeStruct.maxIter = iterRange;
edgeStruct.useMex = 1;
samplesNaiveGibbs = UGM_Sample_Gibbs(nodePot,edgePot,edgeStruct,burnIn);

for i = 1:maxSteps
    edgeStruct.maxIter = i*stepSize;
	
    maxOfMarginalsGibbsDecode = UGM_Decode_MaxOfMarginals(nodePot,edgePot,edgeStruct, @UGM_Infer_Sample,@UGM_Sample_Gibbs,burnIn);

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
for i = 1:nCols
  for j = 1:nRows
     if mod(i, 2) == mod(j, 2)
        blocks1 = [blocks1 sub2ind([nRows nCols], i, j)];
     else
        blocks2 = [blocks2 sub2ind([nRows nCols], i, j)];
     end
  end
end
b1Ind = nNodes/2;
blocks = {blocks1;blocks2};

%% Visualize the blocks
figure;
visual = zeros(nNodes, 1);
for j = 1:b1Ind
    visual(blocks2(j)) = 1;
end
imagesc(reshape(visual, nRows, nCols));
colormap gray

figure;
for i = 1:maxSteps
    edgeStruct.maxIter = i*stepSize;
	
    [nodeBel junk] = UGM_Sample_Infer_Block_Gibbs(nodePot,edgePot,edgeStruct,burnIn,blocks,@UGM_Sample_Infer_Tree);
    [junk nodeLabels] = max(nodeBel, [], 2);
    recon = reshape(nodeLabels, nRows, nCols);
    errorRatesBlockCB(i) = (sum(sum(abs(1 - (recon == image))))) / nNodes
    subplot(2,5,i);
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
%figure(5)
%visual = zeros(nNodes, 1);
%for j = 1:b1Ind
%    visual(blocks2(j)) = 1;
%end
%imagesc(reshape(visual, nRows, nCols));
%colormap gray


%
%figure(6);
%for i = 1:maxSteps
%    edgeStruct.maxIter = i*stepSize;
%	
%    maxOfMarginalsGibbsDecode = UGM_Decode_MaxOfMarginals(nodePot,edgePot,edgeStruct, @UGM_Infer_Sample, @(nodePot, edgePot, edgeStruct, v) (samplesBlockGibbs(:, 1:edgeStruct.maxIter)) ,burnIn);
%
%    recon = reshape(maxOfMarginalsGibbsDecode, nRows, nCols);
%%     reconX = reshape(samplesBlockGibbs(:,edgeStruct.maxIter) -1., nRows, nCols)
%    errorRatesBlockHF(i) = (sum(sum(abs(1 - (recon == image))))) / nNodes;
%    subplot(2,5,i);
%    imagesc(recon);
%    colormap gray
%end

figure;
for i = 1:maxSteps
    edgeStruct.maxIter = i*stepSize;
	
    [nodeBel junk] = UGM_Sample_Infer_Block_Gibbs(nodePot,edgePot,edgeStruct,burnIn,blocks,@UGM_Sample_Infer_Tree);
    [junk nodeLabels] = max(nodeBel, [], 2);
    recon = reshape(nodeLabels, nRows, nCols);
    errorRatesBlockHF(i) = (sum(sum(abs(1 - (recon == image))))) / nNodes
    subplot(2,5,i);
    imagesc(recon);
    colormap gray
end

figure;
plot(errorRatesNaive, 'b-o'); hold on,
plot(errorRatesBlockHF, 'g-x');
plot(errorRatesBlockCB, 'r-x');
legend('Naive', 'Blocked', 'CB');

