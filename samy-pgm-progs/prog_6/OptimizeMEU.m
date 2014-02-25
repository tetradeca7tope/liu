% Copyright (C) Daphne Koller, Stanford University, 2012

function [MEU OptimalDecisionRule] = OptimizeMEU( I )

  % Inputs: An influence diagram I with a single decision node and a single utility node.
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return value: the maximum expected utility of I and an optimal decision rule 
  % (represented again as a factor) that yields that expected utility.
  
  % We assume I has a single decision node.
  % You may assume that there is a unique optimal decision.
  D = I.DecisionFactors(1);
  OptimalDecisionRule = D;
  OptimalDecisionRule.val = zeros(size(D.val));
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE...
  % 
  % Some other information that might be useful for some implementations
  % (note that there are multiple ways to implement this):
  % 1.  It is probably easiest to think of two cases - D has parents and D 
  %     has no parents.
  % 2.  You may find the Matlab/Octave function setdiff useful.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    
  EUF = CalculateExpectedUtilityFactor(I);
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
  
  for i = 1:num_parent_combinations
    curr_parent_ass = parent_assignments(i, :);
    curr_parent_ass_ = repmat(curr_parent_ass, num_decision_combinations, 1);
    
    current_matches = Idx_to_Ass(:, par_var_idxs) == curr_parent_ass_;
    current_match_rows = prod(double(current_matches), 2);
    
    [~, max_idx] = max(EUF.val(find(current_match_rows)));
    OptimalDecisionRule.val( (i-1)*dec_var_card + max_idx) = 1;
    
%     curr_parent_ass, current_matches, current_match_rows, max_idx,
  end
  
  I.DecisionFactors = OptimalDecisionRule;
  MEU = SimpleCalcExpectedUtility(I);

end
