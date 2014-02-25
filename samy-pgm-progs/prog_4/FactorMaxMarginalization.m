% FactorMaxMarginalization Max-marginalizes a factor 
% by taking the max over a given set variables.
% 
%   B = FactorMaxMarginalization(A,V) computes the factor with the variables
%   in V maxed out. The factor data structure has the following fields:
%       .var    Vector of variables in the factor, e.g. [1 2 3]
%       .card   Vector of cardinalities corresponding to .var, e.g. [2 2 2]
%       .val    Value table of size prod(.card)
%
%   B.var will be A.var minus V.
%   For each assignment in B, its value is the maximum value in A 
%   of all assignments in A consistent with that assignment in B.
%
%   The resultant factor should have at least one variable remaining or this
%   function will throw an error.
%
%   This is exactly the same as FactorMarginalization, 
%   but with the sum replaced by a max.
% 
%   See also FactorMarginalization.m, IndexToAssignment.m, and AssignmentToIndex.m
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function B = FactorMaxMarginalization(A, V)

% Check for empty factor or variable list
if (isempty(A.var) || isempty(V)), B = A; return; end;

% Construct the output factor over A.var \ V (the variables in A.var that are not in V)
% and mapping between variables in A and B
[B.var, mapB] = setdiff(A.var, V);
% Check for empty resultant factor
if isempty(B.var)
  error('Error: Resultant factor has empty scope');
end;

% initialization



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
% Correctly set up and populate the factor values of B
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
B.card = A.card(mapB);
B.val = zeros(1, prod(B.card));

A_assignments = IndexToAssignment(1:prod(A.card), A.card);
B_assignments = IndexToAssignment(1:prod(B.card), B.card);

% A_assignments, B_assignments,

for i = 1:size(B_assignments, 1)
  B_ass_intermediate = repmat(B_assignments(i,:), prod(A.card), 1);
  A_ass_comp = A_assignments(:, mapB);
  matching_candidates = prod(double(B_ass_intermediate == A_ass_comp), 2);
%   [B_ass_intermediate, A_ass_comp, matching_candidates],
  
  B.val(i) = max(A.val(matching_candidates == 1));
  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
