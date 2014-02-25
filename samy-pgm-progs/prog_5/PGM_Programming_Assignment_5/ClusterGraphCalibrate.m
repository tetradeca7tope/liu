% CLUSTERGRAPHCALIBRATE Loopy belief propagation for cluster graph calibration.
%   P = CLUSTERGRAPHCALIBRATE(P, useSmart) calibrates a given cluster graph, G,
%   and set of of factors, F. The function returns the final potentials for
%   each cluster. 
%   The cluster graph data structure has the following fields:
%   - .clusterList: a list of the cluster beliefs in this graph. These entries
%                   have the following subfields:
%     - .var:  indices of variables in the specified cluster
%     - .card: cardinality of variables in the specified cluster
%     - .val:  the cluster's beliefs about these variables
%   - .edges: A cluster adjacency matrix where edges(i,j)=1 implies clusters i
%             and j share an edge.
%  
%   UseSmart is an indicator variable that tells us whether to use the Naive or Smart
%   implementation of GetNextClusters for our message ordering
%
%   See also FACTORPRODUCT, FACTORMARGINALIZATION
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function [P MESSAGES] = ClusterGraphCalibrate(P,useSmartMP)

if(~exist('useSmartMP','var'))
  useSmartMP = 0;
end

RESID_19_3 = true;

N = length(P.clusterList);

MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);
[edgeFromIndx, edgeToIndx] = find(P.edges ~= 0);

for m = 1:length(edgeFromIndx),
    i = edgeFromIndx(m);
    j = edgeToIndx(m);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    %
    %
    %
    % Set the initial message values
    % MESSAGES(i,j) should be set to the initial value for the
    % message from cluster i to cluster j
    %
    % The matlab/octave functions 'intersect' and 'find' may
    % be useful here (for making your code faster)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    [sepset_var, idx_i] = intersect(P.clusterList(i).var, ...
                                    P.clusterList(j).var);
    
    MESSAGES(i,j).var = sepset_var;
    MESSAGES(i,j).card = P.clusterList(i).card(idx_i);
    MESSAGES(i,j).val = ones(1, prod(MESSAGES(i,j).card))/ ...
                          prod(MESSAGES(i,j).card);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end;

% MESSAGES,

% perform loopy belief propagation
tic;
iteration = 0;

lastMESSAGES = MESSAGES;

% Construct residuals for messages 19-3, 15-40, 17-2
if RESID_19_3
  resid_19_03 = zeros(0,1);
  resid_15_40 = zeros(0,1);
  resid_17_02 = zeros(0,1);
end

while (iteration < 100000),
    iteration = iteration + 1;
    [i, j] = GetNextClusters(P, MESSAGES,lastMESSAGES, iteration, useSmartMP); 
    prevMessage = MESSAGES(i,j);
%     [i, j],
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % YOUR CODE HERE
    % We have already selected a message to pass, \delta_ij.
    % Compute the message from clique i to clique j and put it
    % in MESSAGES(i,j)
    % Finally, normalize the message to prevent overflow
    %
    % The function 'setdiff' may be useful to help you
    % obtain some speedup in this function
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % First identify the messages from other neighboring clusters
    neighbors = P.edges(i,:);
    neighbors(j) = 0; % Do not include the cluster to which the message
                      % will be passed.
    sepset_var = intersect(P.clusterList(i).var, P.clusterList(j).var);
    neighbor_msg_idxs = find(neighbors);
    
    % Now obtain the product of factors
    prod_of_factors = P.clusterList(i);
    for msg_idx = 1:numel(neighbor_msg_idxs)
      prod_of_factors = factorProduct(prod_of_factors, ...
                           MESSAGES(neighbor_msg_idxs(msg_idx), i));
      prod_of_factors.val = prod_of_factors.val / sum(prod_of_factors.val);
    end
   
    % Now marginalize the factors
    marg_over = setdiff(prod_of_factors.var, sepset_var);
    final_message = factorMarginalization(prod_of_factors, marg_over);
    final_message.val = final_message.val/ sum(final_message.val);
    
    MESSAGES(i, j) = final_message;
    
    % TO PLOT GRAPHS for 19-3, ...
    if RESID_19_3
      if i == 19 && j == 3
        resid_19_03 = [resid_19_03; MessageDelta(MESSAGES(i,j), ...
                                                 prevMessage)];
      end
      if i == 15 && j == 40
        resid_15_40 = [resid_15_40; MessageDelta(MESSAGES(i,j), ...
                                                 prevMessage)];
      end
      if i == 17 && j == 2
        resid_17_02 = [resid_17_02; MessageDelta(MESSAGES(i,j), ...
                                                 prevMessage)]; 
      end
    end
    
%     i, j, sepset_var, P.clusterList(i), P.clusterList(j), neighbors(j), neighbor_msg_idxs, final_message,
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if(useSmartMP==1)
      lastMESSAGES(i,j)=prevMessage;
    end
    
    % Check for convergence every m iterations
    if mod(iteration, length(edgeFromIndx)) == 0
        if (CheckConvergence(MESSAGES, lastMESSAGES))
            break;
        end
        disp(['LBP Messages Passed: ', int2str(iteration), '...']);
        if(useSmartMP~=1)
          lastMESSAGES=MESSAGES;
        end
    end
    
end;
toc;
disp(['Total number of messages passed: ', num2str(iteration)]);

if RESID_19_3
  ymax = .0005;
  figure; plot(resid_19_03); title('19->3'); %axis([0 40 0 ymax]);
  figure; plot(resid_15_40); title('15->40'); %axis([0 40 0 ymax]);
  figure; plot(resid_17_02); title('17->2'); %axis([0 40 0 ymax]);
end

% Compute final potentials and place them in P
for m = 1:length(edgeFromIndx),
    j = edgeFromIndx(m);
    i = edgeToIndx(m);
    P.clusterList(i) = FactorProduct(P.clusterList(i), MESSAGES(j, i));
end


% Get the max difference between the marginal entries of 2 messages -------
function delta = MessageDelta(Mes1, Mes2)
delta = max(abs(Mes1.val - Mes2.val));
return;


