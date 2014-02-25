% Copyright (C) Daphne Koller, Stanford University, 2012

function EU = SimpleCalcExpectedUtility(I)

  % Inputs: An influence diagram, I (as described in the writeup).
  %         I.RandomFactors = list of factors for each random variable.  These are CPDs, with
  %              the child variable = D.var(1)
  %         I.DecisionFactors = factor for the decision node.
  %         I.UtilityFactors = list of factors representing conditional utilities.
  % Return Value: the expected utility of I
  % Given a fully instantiated influence diagram with a single utility node and decision node,
  % calculate and return the expected utility.  Note - assumes that the decision rule for the 
  % decision node is fully assigned.

  % In this function, we assume there is only one utility node.
  F = [I.RandomFactors I.DecisionFactors];
  U = I.UtilityFactors(1);
  EU = [];
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  % YOUR CODE HERE
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % First obtain the utilities using factorProduct.
  utility_factor = U(1);
%   for i = 2:numel(U)
%     utility_factor = FactorProduct(utility_factor, U(i));
%   end
  
  all_vars = unique([F.var]);
  utility_vars = utility_factor.var;
  
  % Now eliminate variables
  F = VariableElimination(F, setdiff(all_vars, utility_vars));
%   for i = 1:numel(F)
%     F(i) = FactorMarginalization(F(i), ...
%                       setdiff(all_vars, utility_vars));
%   end
  
  % Now obtain the complete joint prob
  joint_prob = F(1);
  for i = 2:numel(F)
    joint_prob = FactorProduct(joint_prob, F(i));
  end
  
  EU_factor_product = FactorProduct(joint_prob, utility_factor);
  EU = sum(EU_factor_product.val);
  
%   all_vars, utility_vars, [U.var],
%   PrintFactor(joint_prob),
%   PrintFactor(utility_factor),
%   PrintFactor(EU_factor_product),
  
end
