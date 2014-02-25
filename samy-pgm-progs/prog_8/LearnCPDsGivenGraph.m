function [P loglikelihood] = LearnCPDsGivenGraph(dataset, G, labels)
%
% Inputs:
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
% G: graph parameterization as explained in PA description
% labels: N x 2 true class labels for the examples. labels(i,j)=1 if the 
%         the ith example belongs to class j and 0 elsewhere        
%
% Outputs:
% P: struct array parameters (explained in PA description)
% loglikelihood: log-likelihood of the data (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

M = size(dataset, 1);
K = size(labels,2);
num_vars = size(G, 1);

loglikelihood = 0;
P.c = zeros(1,K);

% estimate parameters
% fill in P.c, MLE for class probabilities
% fill in P.clg for each body part and each class
% choose the right parameterization based on G(i,1)
% compute the likelihood - you may want to use ComputeLogLikelihood.m
% you just implemented.
%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First, correct the dimensionality of G
if size(G,3) == 1
  for k = 1:K
    G(:,:,k) = G;
  end
end

P.c = sum(labels)/M;
P.clg = repmat(struct('mu_y', [], 'sigma_y', zeros(1, K), ...
                      'mu_x', [], 'sigma_x', zeros(1, K), ...
                      'mu_angle', [], 'sigma_angle', zeros(1, K), ...
                      'theta', []), ...
               1, num_vars);

for i = 1:num_vars
  
  if G(i, 1, 1) == 0  % If there are no parents for this node.
                      % We can expect subsequent models not to have parents
                      % for this node.
    % Allocate space for the mu's
    P.clg(i).mu_y = zeros(1, K);
    P.clg(i).mu_x = zeros(1, K);
    P.clg(i).mu_angle = zeros(1, K);
    for k = 1:K
      % Iterate over all classes learning different params for each class
      [P.clg(i).mu_y(k), P.clg(i).sigma_y(k)] = ...
        FitGaussianParameters( squeeze(dataset(labels(:,k)==1,i,1)) );
      [P.clg(i).mu_x(k), P.clg(i).sigma_x(k)] = ...
        FitGaussianParameters( squeeze(dataset(labels(:,k)==1,i,2)) );
      [P.clg(i).mu_angle(k), P.clg(i).sigma_angle(k)] = ...
        FitGaussianParameters( squeeze(dataset(labels(:,k)==1,i,3)) );
    end
    
  else
    % Allocate space for the theta
    P.clg(i).theta = zeros(k, 12);
    for k = 1:K
      par_idx = G(i, 2, k);
      par_vars = squeeze( dataset(labels(:,k) ==1, par_idx, :) );
      
      [beta_y, P.clg(i).sigma_y(k)] = FitLinearGaussianParameters( ...
          squeeze(dataset(labels(:,k)==1,i,1)), par_vars);
      P.clg(i).theta(k, 1:4) = [beta_y(4,:), beta_y(1:3,:)'];
      
      [beta_x, P.clg(i).sigma_x(k)] = FitLinearGaussianParameters( ...
          squeeze(dataset(labels(:,k)==1,i,2)), par_vars);
      P.clg(i).theta(k, 5:8) = [beta_x(4,:), beta_x(1:3,:)'];
      
      [beta_a, P.clg(i).sigma_angle(k)] = FitLinearGaussianParameters( ...
          squeeze(dataset(labels(:,k)==1,i,3)), par_vars);
      P.clg(i).theta(k, 9:12) = [beta_a(4,:), beta_a(1:3,:)'];
    end
  end
  
end

% finally compute the log likelihood
loglikelihood = ComputeLogLikelihood(P, G, dataset);
fprintf('log likelihood: %f\n', loglikelihood);

