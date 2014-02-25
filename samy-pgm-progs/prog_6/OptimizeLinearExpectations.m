% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = OptimizeLinearExpectations( I )
  % Inputs: An influence diagram I with a single decision node and one or more utility nodes.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: the maximum expected utility of I and an optimal decision rule 
  % (represented again as a factor) that yields that expected utility.
  % You may assume that there is a unique optimal decision.
  %
  % This is similar to OptimizeMEU except that we will have to account for
  % multiple utility factors.  We will do this by calculating the expected
  % utility factors and combining them, then optimizing with respect to that
  % combined expected utility factor.  
  D = I.DecisionFactors(1);
  OptimalDecisionRule = D;
  OptimalDecisionRule.val = zeros(size(D.val));
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE
  %
  % A decision rule for D assigns, for each joint assignment to D's parents, 
  % probability 1 to the best option from the EUF for that joint assignment 
  % to D's parents, and 0 otherwise.  Note that when D has no parents, it is
  % a degenerate case we can handle separately for convenience.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  EUFs = repmat(struct('var', [], 'card', [], 'val', []), ...
                size(I.UtilityFactors, 1), size(I.UtilityFactors, 2));
  I1 = I;
  for i = 1:numel(I.UtilityFactors)
    I1.UtilityFactors = I.UtilityFactors(i);
    EUFs(i) = CalculateExpectedUtilityFactor(I1);
%     PrintFactor(EUFs(i));
  end
  
  EUF = EUFs(1);
  for i = 2:numel(EUFs)
    EUF = FactorSum(EUF, EUFs(i));
  end
%   PrintFactor(EUF);

  decision_var = D.var(1);
  
  dec_var_idx = find(EUF.var == decision_var);
  dec_var_card = D.card(1);
  par_var_idxs = find(EUF.var ~= decision_var);
  dec_var_parents = setdiff(D.var, decision_var);
  num_parent_combinations = prod(D.card(2:end));
  num_decision_combinations = prod(D.card);
  Idx_to_Ass = IndexToAssignment(1:prod(D.card), D.card);
  parent_assignments = IndexToAssignment(1:num_parent_combinations, ...
                                         D.card(2:end));
  
%   PrintFactor(EUF),dec_var_idx, par_var_idxs, dec_var_parents,
%   num_parent_combinations, parent_assignments, num_decision_combinations
  
  MEU = 0;
  for i = 1:num_parent_combinations
    curr_parent_ass = parent_assignments(i, :);
    curr_parent_ass_ = repmat(curr_parent_ass, num_decision_combinations, 1);
    
    current_matches = Idx_to_Ass(:, par_var_idxs) == curr_parent_ass_;
    current_match_rows = prod(double(current_matches), 2);
    
    [max_val, max_idx] = max(EUF.val(find(current_match_rows)));
    MEU = MEU + max_val;
    OptimalDecisionRule.val( (i-1)*dec_var_card + max_idx) = 1;
    
%     curr_parent_ass, current_matches, current_match_rows, max_idx,
  end
  
  I.DecisionFactors = OptimalDecisionRule;
%   MEU = sum(EUF.val .* OptimalDecisionRule.val);

end
