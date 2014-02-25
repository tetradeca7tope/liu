%COMPUTEINITIALPOTENTIALS Sets up the cliques in the clique tree that is
%passed in as a parameter.
%
%   P = COMPUTEINITIALPOTENTIALS(C) Takes the clique tree skeleton C which is a
%   struct with three fields:
%   - nodes: cell array representing the cliques in the tree.
%   - edges: represents the adjacency matrix of the tree.
%   - factorList: represents the list of factors that were used to build
%   the tree. 
%   
%   It returns the standard form of a clique tree P that we will use through 
%   the rest of the assigment. P is struct with two fields:
%   - cliqueList: represents an array of cliques with appropriate factors 
%   from factorList assigned to each clique. Where the .val of each clique
%   is initialized to the initial potential of that clique.
%   - edges: represents the adjacency matrix of the tree. 
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function P = ComputeInitialPotentials(C)

% number of cliques
N = length(C.nodes);
num_factors = numel(C.factorList);

% initialize cluster potentials 
P.cliqueList = repmat(struct('var', [], 'card', [], 'val', []), N, 1);
P.edges = zeros(N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% First, compute an assignment of factors from factorList to cliques. 
% Then use that assignment to initialize the cliques in cliqueList to 
% their initial potentials. 

% C.nodes is a list of cliques.
% So in your code, you should start with: P.cliqueList(i).var = C.nodes{i};
% Print out C to get a better understanding of its structure.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

P.edges = C.edges;
factor_still_available = ones(num_factors, 1);

assignment_to_cliques = zeros(num_factors, 1);
cardinalities = zeros(0,0);

for i = 1:N
  % For each clique in the Clique Tree, assign possible factors
  for j = 1:num_factors
%     C.factorList(j).var,
%     C.nodes(i),
    if (factor_still_available(j) && ...
        IsSubsetOf(C.factorList(j).var, cell2mat(C.nodes(i))))
          assignment_to_cliques(j) = i;
          factor_still_available(j) = 0;
          for k = 1:numel(C.factorList(j).var)
            cardinalities(C.factorList(j).var(k)) = C.factorList(j).card(k);
          end
%           fprintf('%d assigned to %d\n', j, i);
    end
  end
end

% cardinalities,
% assignment_to_cliques,

for i = 1:N
  
  % First create a dummy factor (with all 1s). The idea is that sometimes
  % the factors assigned to a clique might not fully encompass all the
  % variables assigned to the clique.
  f.var = cell2mat(C.nodes(i));
  f.card = cardinalities(f.var);
  f.val = ones(1, prod(f.card));
  
  current_factors = C.factorList(assignment_to_cliques == i);
  
  for j = 1:numel(current_factors)
%     f, current_factors(j),
    f = FactorProduct(f, current_factors(j));
  end
  P.cliqueList(i) = f;
end


end


function f = IsSubsetOf(sub, super)
%   class(sub), class(super),
  f = prod(double(ismember(sub, super)));
end
