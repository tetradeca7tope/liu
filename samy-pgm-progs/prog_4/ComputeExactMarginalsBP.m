%COMPUTEEXACTMARGINALSBP Runs exact inference and returns the marginals
%over all the variables (if isMax == 0) or the max-marginals (if isMax == 1). 
%
%   M = COMPUTEEXACTMARGINALSBP(F, E, isMax) takes a list of factors F,
%   evidence E, and a flag isMax, runs exact inference and returns the
%   final marginals for the variables in the network. If isMax is 1, then
%   it runs exact MAP inference, otherwise exact inference (sum-prod).
%   It returns an array of size equal to the number of variables in the 
%   network where M(i) represents the ith variable and M(i).val represents 
%   the marginals of the ith variable. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function M = ComputeExactMarginalsBP(F, E, isMax)

% initialization
% you should set it to the correct value in your code
% M = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Implement Exact and MAP Inference.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
P = CreateCliqueTree(F, E);
P = CliqueTreeCalibrate(P, isMax);
num_vars = numel(unique([P.cliqueList.var]));
M = repmat(struct('var', [], 'card', [], 'val', []), num_vars, 1);
% P, P.cliqueList, [P.cliqueList.var], num_vars,

for i = 1:numel(P.cliqueList)
  for j = 1:numel(P.cliqueList(i).var)
    if isMax == 1
      M(P.cliqueList(i).var(j)) = FactorMaxMarginalization(P.cliqueList(i), ...
          setdiff(P.cliqueList(i).var, [P.cliqueList(i).var(j)]));
    else
      M(P.cliqueList(i).var(j)) = FactorMarginalization(P.cliqueList(i), ...
          setdiff(P.cliqueList(i).var, [P.cliqueList(i).var(j)]));
      M(P.cliqueList(i).var(j)).val = M(P.cliqueList(i).var(j)).val / ...
                                      sum(M(P.cliqueList(i).var(j)).val);
    end
  end
end

end
