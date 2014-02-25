function loglikelihood = ComputeLogLikelihood(P, G, dataset)
% returns the (natural) log-likelihood of data given the model and graph structure
%
% Inputs:
% P: struct array parameters (explained in PA description)
% G: graph structure and parameterization (explained in PA description)
%
%    NOTICE that G could be either 10x2 (same graph shared by all classes)
%    or 10x2x2 (each class has its own graph). your code should compute
%    the log-likelihood using the right graph.
%
% dataset: N x 10 x 3, N poses represented by 10 parts in (y, x, alpha)
% 
% Output:
% loglikelihood: log-likelihood of the data (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset,1); % number of examples
K = length(P.c); % number of classes
num_vars = size(G,1);
% num_coords = size(dataset, 3);

loglikelihood = 0;
% You should compute the log likelihood of data as in eq. (12) and (13)
% in the PA description
% Hint: Use lognormpdf instead of log(normpdf) to prevent underflow.
%       You may use log(sum(exp(logProb))) to do addition in the original
%       space, sum(Prob).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First, correct the dimensionality of G
if size(G,3) == 1
  for k = 1:K
    G(:,:,k) = G;
  end
end

% Some arrays that will be needed for computation

% Iterate through all examples
for i = 1:N
  
  curr_log_probs = zeros(1,K);
  
  for k = 1:K
    for v = 1:num_vars
    curr_x = [dataset(i, v, 1); dataset(i, v, 2); dataset(i, v, 3)];
      
      % Now compute the 3 means of the gaussian
      if G(v, 1, k) == 0
        mu_ = [P.clg(v).mu_y(k); P.clg(v).mu_x(k); P.clg(v).mu_angle(k)];
      else
        par_idx = G(v, 2, k);
        par_x_ = [1; dataset(i, par_idx, 1); ...
                  dataset(i, par_idx, 2); dataset(i, par_idx, 3)];
        mu_ = zeros(3,1);
        for coord_cnt = 1:3   % over y, x and alpha
          mu_(coord_cnt) = ...
            P.clg(v).theta(k, ((coord_cnt-1)*4 + 1):(coord_cnt*4) ) * ...
            par_x_;
        end
      end
      
      % Now obtain the stds
      sigma_ = [P.clg(v).sigma_y(k); P.clg(v).sigma_x(k); ...
          P.clg(v).sigma_angle(k)];
%       [curr_x, mu_, sigma_],
      curr_log_probs(k) = curr_log_probs(k) + ...
                          sum_lognormpdf(curr_x, mu_, sigma_);
    end
  end
  
  curr_logl_components = log(P.c) + curr_log_probs;
%   curr_logl = max(curr_logl_components);
  curr_logl = log( sum(exp( curr_logl_components )) );
  loglikelihood = loglikelihood + curr_logl;
%   fprintf('%d. curr_logl_components: %s, curr_log_probs: %s, loglikelihood %f\n',i,  mat2str(curr_logl_components), mat2str(curr_log_probs), loglikelihood);
  
end

end

function f = sum_lognormpdf(curr_x, mu_, sigma_)
  f = 0;
  for i =1:3
    f = f + lognormpdf(curr_x(i), mu_(i), sigma_(i));
  end
end