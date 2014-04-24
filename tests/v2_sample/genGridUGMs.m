% This script generates 3 graphs: gridUnif, gridRand and gridBHor. Each graph is
% an nRowsxnCols grid. gridUni has uniform edge potentials for all edges.
% gridRand has randomly generated potentials and gridBHor is biased to have
% strong correlations among nodes horizontally and random correlations
% vertically.

% Create adjacency matrix
% =======================
adjMat = sparse(nNodes, nNodes);
% Add Down Edges
ind = 1:nNodes;
% No Down edge for last row
exclude = sub2ind([nRows nCols],repmat(nRows,[1 nCols]),1:nCols);
ind = setdiff(ind,exclude);
adjMat(sub2ind([nNodes nNodes],ind,ind+1)) = 1;
% Add Right Edges
% No right edge for last column
exclude = sub2ind([nRows nCols],1:nRows,repmat(nCols,[1 nRows]));
ind = setdiff(ind,exclude);
adjMat(sub2ind([nNodes nNodes],ind,ind+nRows)) = 1;
% Add Up/Left Edges
adjMat = adjMat + adjMat';
edgeStruct = UGM_makeEdgeStruct(adjMat,nStates);

% Specify the node potentials for the 3 cases
% ===========================================

% 1. gridUnif
% -----------
nodePotUnif = 0.1 * ones(nNodes, nStates);
edgePotUnif = ones(nStates, nStates, edgeStruct.nEdges);

% 2. gridRand
% -----------
nodePotRand = nodePotUnif;
% Create a strong bias for neighbors to have similar states.
% edgePotRand = 1 * repmat(eye(nStates), [1, 1, edgeStruct.nEdges]) + ...
%               3*randn(nStates, nStates, edgeStruct.nEdges) ;
edgePotRand = 3*randn(nStates, nStates, edgeStruct.nEdges) ;

% 3. gridBHor
% -----------
nodePotBHor = 0.1*ones(nNodes, nStates);

% Finalize
gridNames = {'Uniform', 'Random'};
gridEdgePots = {edgePotUnif, edgePotRand};
gridNodePots = {nodePotUnif, nodePotRand};

% Graphs that seem to work so far.
% nodePotUnif = 0.1 * ones(nNodes, nStates);
% edgePotRand = 3 * repmat(eye(nStates), [1, 1, edgeStruct.nEdges]) + ...
%               0.5*rand(nStates, nStates, edgeStruct.nEdges) + 0.5;
% nStates = 13, nRows = nCols = 9;
