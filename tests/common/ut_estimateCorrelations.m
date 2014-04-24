% A unit test for EstimateCorrelations.m

% Create the graph 
nStates = 2;
adjMat = sparse(5,5);
adjMat(1,2) = 1;
adjMat(1,3) = 1;
adjMat(1,4) = 1;
adjMat(3,4) = 1;
adjMat(3,5) = 1;
adjMat = adjMat + adjMat';
% Create the Edge struct
edgeStruct = UGM_makeEdgeStruct(adjMat, nStates);
% Create Node potentials
nodePot = 0.01 * ones(5, nStates);

% Create Edge Potentials
s = 100;
edgePot = zeros(nStates, nStates, edgeStruct.nEdges);
edgePot(:, :, 1) = s*[2 0.1; 0.1 2];
edgePot(:, :, 2) = s*[0.5 0.5; 0.5 0.5];
edgePot(:, :, 3) = s*[0.6 0.4; 0.3 0.7];
edgePot(:, :, 4) = s*[0.5 1; 1 0.5];
edgePot(:, :, 5) = s*[1 3; 3 1];

% Now obtain the correlation graph
corrGraph = estimateCorrelations(nodePot, edgePot, edgeStruct, 10, 10000);
corrGraph,

% Partition into Trees
% Greedy Tree Growing
partition_1 = treePartition('GreedyTree', corrGraph)
color_1 = treePartition('GreedyTree', corrGraph, true)
% Greedy Edge Selection
partition_2 = treePartition('GreedyEdge', corrGraph)
color_2 = treePartition('GreedyEdge', corrGraph, true)
