% The Meaning of Arguments
%
% algo: 
%   'GreedyTree' for Greedy Tree Growing Algorithm
%   'GreedyEdge' for Greedy Edge Selection Algorithm
%
% corrGraph:
%   A sparse matrix representing the weighted graph
%
% maxTreeSize:
%   Control the max tree size. Set to -1 if you don't want to control it.
%
% outputcolor:
%   specifying the output format
%   false
%     for outputing node ids in each tree, like this:
%     [1, 2, 4]   % Tree 1
%     [3, 5]      % Tree 2
%     To put this varied-length output into a matrix, I pad it with 0s.
% 
%   true
%     for outputing the tree id for each node, like this:
%     [1, 1, 2, 1, 2]
%
% Wenlu April 24

function partition = treePartition(...
    algo, ...
    corrGraph, ...
    maxTreeSize, ...
    outputcolor)

    if nargin < 4
        outputcolor = false;
    end
    
    graph_fn = 'graph.txt';
    fid = fopen(graph_fn, 'wt');
    [i,j, weight] = find(triu(corrGraph));
    fprintf(fid, '%d\n', length(corrGraph)); % number of nodes
    fprintf(fid, '%d %d %f\n', [i, j, weight]'); % edges
    fclose(fid);
    pyscript = '../../tree-partition/RunTreePartitioning.py';
    
    if outputcolor
        outputOption = ' --outputcolor';
    else 
        outputOption = '';
    end

    
    
    cmd = ['python ', pyscript, ' ', ...
       algo, ' ', graph_fn, ' ', ...
       num2str(maxTreeSize), ' ', outputOption]
    
    [status, cmdout] = dos(cmd);

    cmdout
    size(cmdout)
    partition = str2num(cmdout);
end
