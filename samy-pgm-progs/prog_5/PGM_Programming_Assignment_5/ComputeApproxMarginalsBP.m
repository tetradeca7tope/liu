% COMPUTEAPPROXMARGINALSBP Computation of approximate marginals using Loopy BP
%   M = COMPUTEAPPROXMARGINALSBP(F,E ) returns the approximate marginals over
%       each variable in F given the evidence E.
%   . 
%   The Factor list F has the following fields:
%     - .var:  indices of variables in the specified cluster
%     - .card: cardinality of variables in the specified cluster
%     - .val:  the cluster's beliefs about these variables
%   - .edges: Contains indices of the clusters that have edges between them.
%
%   The Evidence E is a vector of length equal to the number of variables in the
%   factors where 0 stands for unobserved and other values are an observed 
%   assignment to that variable. It can be left empty (E=[]) if there is no evidence
%  
%   M should be an array of factors with one factor for each variable and 
%   M(i).val should be filled in with the marginal of variable i.
%
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function M = ComputeApproxMarginalsBP(F,E)

    % returning approximate marginals.
    
    clusterGraph = CreateClusterGraph(F,E);
    
    P = ClusterGraphCalibrate(clusterGraph);
    
    N = unique([P.clusterList(:).var]);
    
    % compute marginals on each variable
    M = repmat(struct('var', 0, 'card', 0, 'val', []), length(N), 1);
    
    % Populate M so that M(i) contains the marginal probability over
    % variable i
    for i = 1:length(N),
    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % YOUR CODE HERE
        %
        % Populate M(i) such that M(i) contains a factor representation of
        % the marginal proability over the variable with index i.
        % (ie. M(i).val is the actual marginal)
        %
        % You may want to use the helper function 'FindPotentialWithVariable'
        % which is defined at the bottom of this file.  Read through it
        % to make sure you understand its functionality.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        pot_idx = FindPotentialWithVariable(P, N(i));
        % First identify the messages from other neighboring clusters
%         neighbors = P.edges(pot_idx,:);
%         neighbor_msg_idxs = find(neighbors);
%         
%         neighbor_msg_idxs,
%         
%         % Now obtain the product of factors
%         prod_of_factors = P.clusterList(pot_idx);
%         for msg_idx = 1:numel(neighbor_msg_idxs)
%           prod_of_factors = factorProduct(prod_of_factors, ...
%                                MESSAGES(neighbor_msg_idxs(msg_idx), pot_idx));
%           prod_of_factors.val = prod_of_factors.val / sum(prod_of_factors.val);
%           prod_of_factors,
%         end
        
        % Now marginalize the factors
        marg_over = setdiff(P.clusterList(pot_idx).var, N(i));
        final_message = factorMarginalization(P.clusterList(pot_idx), ...
                                              marg_over);
        final_message.val = final_message.val/ sum(final_message.val);
        M(i) = final_message;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end



return;

% Helper function:
function indx = FindPotentialWithVariable(P, V)

indx = 0;
for i = 1:length(P.clusterList),
    if (any(P.clusterList(i).var == V)),
        indx = i;
        return;
    end;
end;

return;
