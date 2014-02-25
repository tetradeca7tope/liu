function accuracy = ClassifyDataset(dataset, labels, P, G)
% returns the accuracy of the model P and graph G on the dataset 
%
% Inputs:
% dataset: N x 10 x 3, N test instances represented by 10 parts
% labels:  N x 2 true class labels for the instances.
%          labels(i,j)=1 if the ith instance belongs to class j 
% P: struct array model parameters (explained in PA description)
% G: graph structure and parameterization (explained in PA description) 
%
% Outputs:
% accuracy: fraction of correctly classified instances (scalar)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

N = size(dataset, 1);
K = length(P.c); % number of classes
num_vars = size(G,1);
accuracy = 0.0;

% Get labels onto one vector
[r,c] = find(labels);
L(r,1) = c;
predictions = zeros(size(L));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First, correct the dimensionality of G
if size(G,3) == 1
  for k = 1:K
    G(:,:,k) = G;
  end
end

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
      curr_log_probs(k) = curr_log_probs(k) + ...
                          sum_lognormpdf(curr_x, mu_, sigma_);
    end
  end
  
  curr_logl_components = log(P.c) + curr_log_probs;
  [~, predictions(i)] = max(curr_logl_components);
end

accuracy = sum(predictions == L)/ N;

fprintf('Accuracy: %.2f\n', accuracy);

end


function f = sum_lognormpdf(curr_x, mu_, sigma_)
  f = 0;
  for i =1:3
    f = f + lognormpdf(curr_x(i), mu_(i), sigma_(i));
  end
end