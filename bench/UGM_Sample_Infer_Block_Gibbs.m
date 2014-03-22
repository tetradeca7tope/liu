function [nodeBel, samples] = UGM_Sample_Infer_Block_Gibbs(nodePot,edgePot,edgeStruct,burnIn,blocks,sampleFunc)
% Block Gibbs Sampling

[nNodes,maxStates] = size(nodePot);
nEdges = size(edgePot,3);
edgeEnds = edgeStruct.edgeEnds;
V = edgeStruct.V;
E = edgeStruct.E;
nStates = edgeStruct.nStates;
maxIter = edgeStruct.maxIter;
for n = 1:nNodes
    nodeBel(n,1:nStates(n)) = zeros(1, nStates(n));
end
size(nodeBel)

% Initialize
nBlocks = length(blocks);
[junk y] = max(nodePot,[],2);

samples = zeros(nNodes,0);

for i = 1:burnIn+maxIter
    
    if i <= burnIn
        fprintf('Generating burnIn sample %d of %d\n',i,burnIn);
    else
        fprintf('Generating sample %d of %d\n',i-burnIn,maxIter);
    end

    for b = 1:nBlocks
        clamped = y;
        clamped(blocks{b}) = 0;

        [clampedNP,clampedEP,clampedES] = UGM_makeClampedPotentials(nodePot, edgePot, edgeStruct, clamped);

        clampedES.maxIter = 1;
        [nodeBels_upd, y(blocks{b})] = sampleFunc(clampedNP,clampedEP,clampedES);
	if i > burnIn
	    nodeBel(blocks{b}, :) = nodeBel(blocks{b}, :) + nodeBels_upd;
	end
    end
    %disp('Foo2')
    %nodeBel(1, :)
    %disp('Estimate:')
    %[junk est] = max(nodeBel(1, :), [], 2);
    %est

    if i > burnIn
        samples(:,i-burnIn) = y;
    end
end

nodeBel = nodeBel / maxIter;
