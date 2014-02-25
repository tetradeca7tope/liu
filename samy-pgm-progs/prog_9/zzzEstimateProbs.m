function test_logls = zzzEstimateProbs(P, actionData, poseData, G, K )

% Initialize variables
N = size(poseData, 1);
L = size(actionData, 2); % number of actions
num_vars = size(G,1);

test_logls = zeros(L, 1);

% Create inline lognormpdf function
lognormpdf_inline = inline( ...
  '-log(sigma*sqrt(2*pi))-(x-mu).^2 ./ (2*sigma.^2);', ...
  'x', 'mu', 'sigma');

  % E-STEP preparation: compute the emission model factors (emission 
  % probabilities) in log space for each 
  % of the poses in all actions = log( P(Pose | State) )
  % Hint: This part should be similar to (but NOT the same as) your
  % code in EM_cluster.m
  
  logEmissionProb = zeros(N,K);
  
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
    
    % Finally store the results in logEmissionProb
    logEmissionProb(i,:) = curr_log_probs;
  end
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
  % E-STEP to compute expected sufficient statistics
  % ClassProb contains the conditional class probabilities for each pose in all actions
  % PairProb contains the expected sufficient statistics for the transition CPDs (pairwise transition probabilities)
  % Also compute log likelihood of dataset for this iteration
  % You should do inference and compute everything in log space, only converting to probability space at the end
  % Hint: You should use the logsumexp() function here to do probability normalization in log space to avoid numerical issues
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % YOUR CODE HERE
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  for i = 1:L
  % Iterate through all actions, performing inference on all of them.
    num_poses_in_curr_action = numel(actionData(i).marg_ind);
    num_pairs_in_curr_action = numel(actionData(i).pair_ind);
    
    % Create a factor for the prior probs in P.c
    prior_factor = struct('var', 1, 'card', K, 'val', log(P.c) );
    
    % Create singleton factors for the logEmissionProbabilities
    singleton_factors = repmat(struct('var', 0, 'card', K, 'val', []), ...
                               1, num_poses_in_curr_action);
    for sf_i = 1:num_poses_in_curr_action
      singleton_factors(sf_i).var = sf_i;
      singleton_factors(sf_i).val = ...
        logEmissionProb(actionData(i).marg_ind(sf_i), :);
    end
    
    % Create Pairwise factors for the Pairwise Probabilities
    pairwise_factors = repmat(struct ('var', [0, 0], 'card', [K K], ...
                                      'val', log(P.transMatrix(:))' ), ...
                              1, num_pairs_in_curr_action);
    for pf_i = 1:num_pairs_in_curr_action
      pairwise_factors(pf_i).var = [pf_i, pf_i+1];
    end
    
    % Now create All Factors
    all_factors = [prior_factor, singleton_factors, pairwise_factors];
    
    % Now perform Clique Tree Callibration to obtain the exact marginals
    [~, PCalibrated] = ComputeExactMarginalsHMM(all_factors);
    
    % Now store the loglikelihood for the current action according
    % to the current model.
    test_logls(i) = logsumexp(PCalibrated.cliqueList(1).val);
%     % Now update ClassProb
%     for action_i = 1:num_poses_in_curr_action
%       log_norm = logsumexp(M(action_i).val);
%       log_norm_probs = M(action_i).val - log_norm;
%       norm_probs = exp(log_norm_probs);
%       ClassProb(actionData(i).marg_ind(action_i), :) = norm_probs;
%     end
%     
%     % Now update PairProb
%     for pair_i = 1:num_pairs_in_curr_action
%       log_norm = logsumexp(PCalibrated.cliqueList(pair_i).val);
%       log_norm_probs = PCalibrated.cliqueList(pair_i).val - log_norm;
%       norm_probs = exp(log_norm_probs);
%       PairProb(actionData(i).pair_ind(pair_i), :) = norm_probs;        
%     end
%     
%     % Now accumulate the loglikelihood.
%     loglikelihood(iter) = loglikelihood(iter) + ...
%                           logsumexp(PCalibrated.cliqueList(1).val);
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end