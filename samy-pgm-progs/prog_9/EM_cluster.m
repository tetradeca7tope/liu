% File: EM_cluster.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [P loglikelihood ClassProb] = EM_cluster(poseData, G, InitialClassProb, maxIter)

% INPUTS
% poseData: N x 10 x 3 matrix, where N is number of poses;
%   poseData(i,:,:) yields the 10x3 matrix for pose i.
% G: graph parameterization as explained in PA8
% InitialClassProb: N x K, initial allocation of the N poses to the K
%   classes. InitialClassProb(i,j) is the probability that example i belongs
%   to class j
% maxIter: max number of iterations to run EM

% OUTPUTS
% P: structure holding the learned parameters as described in the PA
% loglikelihood: #(iterations run) x 1 vector of loglikelihoods stored for
%   each iteration
% ClassProb: N x K, conditional class probability of the N examples to the
%   K classes in the final iteration. ClassProb(i,j) is the probability that
%   example i belongs to class j

% Initialize variables
N = size(poseData, 1);
K = size(InitialClassProb, 2);
num_vars = size(G, 1);

% First, correct the dimensionality of G
if size(G,3) == 1
  for k = 1:K
    G(:,:,k) = G(:,:,1);
  end
end

ClassProb = InitialClassProb;

loglikelihood = zeros(maxIter,1);

P.c = [];
P.clg.sigma_x = [];
P.clg.sigma_y = [];
P.clg.sigma_angle = [];

% Create inline lognormpdf function
lognormpdf_inline = inline( ...
  '-log(sigma*sqrt(2*pi))-(x-mu).^2 ./ (2*sigma.^2);', ...
  'x', 'mu', 'sigma');
                            

% EM algorithm
for iter=1:maxIter
  fprintf('iteration: %d / %d\n', iter, maxIter);
  % M-STEP to estimate parameters for Gaussians
  %
  % Fill in P.c with the estimates for prior class probabilities
  % Fill in P.clg for each body part and each class
  % Make sure to choose the right parameterization based on G(i,1)
  %
  % Hint: This part should be similar to your work from PA8
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  P = LearnCPDsGivenGraph(poseData, G, ClassProb);
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % E-STEP to re-estimate ClassProb using the new parameters
  %
  % Update ClassProb with the new conditional class probabilities.
  % Recall that ClassProb(i,j) is the probability that example i belongs to
  % class j.
  %
  % You should compute everything in log space, and only convert to
  % probability space at the end.
  %
  % Tip: To make things faster, try to reduce the number of calls to
  % lognormpdf, and inline the function (i.e., copy the lognormpdf code
  % into this file)
  %
  % Hint: You should use the logsumexp() function here to do
  % probability normalization in log space to avoid numerical issues
  
  ClassProb = zeros(N,K);
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  for i = 1:N
    
    curr_log_probs = zeros(1,K);
    
    for k = 1:K
      for v = 1:num_vars
        curr_x = [poseData(i,v,1); poseData(i,v,2); poseData(i,v,3)];
        
        % Now compute the Gaussian mean
        if G(v, 1, k) == 0
        % If the current variable has no parent.
          mu_ = [P.clg(v).mu_y(k); P.clg(v).mu_x(k); P.clg(v).mu_angle(k)];
        else
          par_idx = G(v, 2, k);
          par_x_ = [1; poseData(i, par_idx, 1); ...
                    poseData(i, par_idx, 2); poseData(i, par_idx, 3)];
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
                
        % Finally accumulate the ClassProb in logspace
        curr_log_probs(k) = curr_log_probs(k) + ...
          lognormpdf_inline(curr_x(1), mu_(1), sigma_(1)) + ...
          lognormpdf_inline(curr_x(2), mu_(2), sigma_(2)) + ...
          lognormpdf_inline(curr_x(3), mu_(3), sigma_(3));           
      end
    end
    
    curr_logl_components = log(P.c) + curr_log_probs;
    curr_logsumexp = logsumexp(curr_logl_components);
    curr_log_probs = curr_logl_components - curr_logsumexp;
    
    % Finally assign the actual probabilities
    ClassProb(i,:) = exp(curr_log_probs);
    
    % and accumulate the log likelihood
    loglikelihood(iter) = loglikelihood(iter) + curr_logsumexp;
    
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Compute log likelihood of dataset for this iteration
  % Hint: You should use the logsumexp() function here
%   loglikelihood(iter) = 0;
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Print out loglikelihood
  disp(sprintf('EM iteration %d: log likelihood: %f', ...
    iter, loglikelihood(iter)));
  if exist('OCTAVE_VERSION')
    fflush(stdout);
  end
  
  % Check for overfitting: when loglikelihood decreases
  if iter > 1
    if loglikelihood(iter) < loglikelihood(iter-1)
      break;
    end
  end
  
end

% Remove iterations if we exited early
loglikelihood = loglikelihood(1:iter);

end