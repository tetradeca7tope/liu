% function [nll, grad] = InstanceNegLogLikelihood(X, y, theta, modelParams)
% returns the negative log-likelihood and its gradient, given a CRF with parameters theta,
% on data (X, y). 
%
% Inputs:
% X            Data.                           (numCharacters x numImageFeatures matrix)
%              X(:,1) is all ones, i.e., it encodes the intercept/bias term.
% y            Data labels.                    (numCharacters x 1 vector)
% theta        CRF weights/parameters.         (numParams x 1 vector)
%              These are shared among the various singleton / pairwise features.
% modelParams  Struct with three fields:
%   .numHiddenStates     in our case, set to 26 (26 possible characters)
%   .numObservedStates   in our case, set to 2  (each pixel is either on or off)
%   .lambda              the regularization parameter lambda
%
% Outputs:
% nll          Negative log-likelihood of the data.    (scalar)
% grad         Gradient of nll with respect to theta   (numParams x 1 vector)
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [nll, grad] = InstanceNegLogLikelihood(X, y, theta, modelParams)

    % featureSet is a struct with two fields:
    %    .numParams - the number of parameters in the CRF (this is not numImageFeatures
    %                 nor numFeatures, because of parameter sharing)
    %    .features  - an array comprising the features in the CRF.
    %
    % Each feature is a binary indicator variable, represented by a struct 
    % with three fields:
    %    .var          - a vector containing the variables in the scope of this feature
    %    .assignment   - the assignment that this indicator variable corresponds to
    %    .paramIdx     - the index in theta that this feature corresponds to
    %
    % For example, if we have:
    %   
    %   feature = struct('var', [2 3], 'assignment', [5 6], 'paramIdx', 8);
    %
    % then feature is an indicator function over X_2 and X_3, which takes on a value of 1
    % if X_2 = 5 and X_3 = 6 (which would be 'e' and 'f'), and 0 otherwise. 
    % Its contribution to the log-likelihood would be theta(8) if it's 1, and 0 otherwise.
    %
    % If you're interested in the implementation details of CRFs, 
    % feel free to read through GenerateAllFeatures.m and the functions it calls!
    % For the purposes of this assignment, though, you don't
    % have to understand how this code works. (It's complicated.)
    
    featureSet = GenerateAllFeatures(X, modelParams);

    % Use the featureSet to calculate nll and grad.
    % This is the main part of the assignment, and it is very tricky - be careful!
    % You might want to code up your own numerical gradient checker to make sure
    % your answers are correct.
    %
    % Hint: you can use CliqueTreeCalibrate to calculate logZ effectively. 
    %       We have halfway-modified CliqueTreeCalibrate; complete our implementation 
    %       if you want to use it to compute logZ.
    
    grad = zeros(size(theta));
    %%%
    % Your code here:
    % First generate an uncalibrated Clique Tree
    num_characters = size(X, 1);
    num_cliques = num_characters - 1;
    num_features = numel(featureSet.features);
    
    UncalibCliqueTree.edges = zeros(num_cliques);
    for i = 1:(num_cliques-1)
      UncalibCliqueTree.edges(i, i+1) = 1;
      UncalibCliqueTree.edges(i+1, i) = 1;
    end
    
    UncalibCliqueTree.cliqueList = repmat( struct( 'var', [], ...
      'card', [], 'val', []), num_cliques, 1 );

    for i = 1:num_cliques
      var = [i, i+1];
      card = modelParams.numHiddenStates * ones( size(var) );
      UncalibCliqueTree.cliqueList(i) = ...
        GenerateCliqueFactor(i, featureSet, card, theta, num_cliques);
    end
%     P = UncalibCliqueTree;
    
    % Compute LogZ by calibrating the uncalibrated CT
    isMax = 0; % This is not a max-sum CT calibration
    [CalibCliqueTree, logZ] = CliqueTreeCalibrate( ...
      UncalibCliqueTree, isMax);
    
    % Compute the weighted feature counts
    feature_vec = GenerateFeatureVector(y, featureSet.features);
    feature_coeffs = theta([featureSet.features.paramIdx]);
    weighted_feature_counts = sum(feature_vec .* feature_coeffs');
    neg_weighted_feature_counts = - weighted_feature_counts;
    
    % Compute the regularization cost
    reg_cost = (modelParams.lambda/2) * sum(theta.^2);
    
    % Compute the negative log likelihood
    nll = logZ + neg_weighted_feature_counts + reg_cost;
    
    % Print intermediate results
    logZ, neg_weighted_feature_counts, reg_cost, nll,
    
    % COMPUTE GRAD
    % The regularization gradient
    reg_grad = modelParams.lambda * theta;
    
    % Expected feature values
    D_features = zeros(1, featureSet.numParams);
    parameters = [featureSet.features.paramIdx];
    for i = 1:featureSet.numParams
      D_features(i) = sum( (parameters == i) .* feature_vec');
    end
    
    % compute the Expected Features
    E_features = zeros(1, featureSet.numParams);
    P_phi = CalibCliqueTree.cliqueList(1);
    for i = 2:numel(CalibCliqueTree.cliqueList)
      P_phi = FactorProduct(P_phi, CalibCliqueTree.cliqueList(i));
    end
    A = IndexToAssignment(1:prod(P_phi.card), P_phi.card);
    A(:, P_phi.var) = A;
    feature_probs = zeros(1, num_features); 
    for i = 1:prod(P_phi.card)
      if (mod(i,26) == 0)
        fprintf('Computing expected values for i = %d\t %s\n', i, mat2str(A(i,:)));
      end
      feat_vec = GenerateFeatureVector(A(i,:), featureSet.features);
      feature_probs = feature_probs + feat_vec' * ...
                exp( sum(feat_vec .* feature_coeffs') );
    end
    for i = 1:featureSet.numParams
      E_features(i) = sum( (parameters == i) .* feature_probs );
    end
    % Finally normalize the answers
    E_features = E_features/exp(logZ);
    
    % Compute the Grad
    grad = E_features - D_features + reg_grad;
    
end


function feature_vec = GenerateFeatureVector(y, features)
  feature_vec = zeros(numel(features), 1);
  for i = 1:numel(feature_vec)
%     fprintf('\t %d\n', i);
    feature_vec(i) = isequal(y(features(i).var), features(i).assignment);
  end
end

function clique_factor = GenerateCliqueFactor(clique_num, ...
          featureSet, card, theta, num_cliques)
  clique_vars = {featureSet.features.var};
  reqd_feature_idxs = cellfun(@(x)(isequal(x, clique_num)), clique_vars);
  reqd_feature_idxs = reqd_feature_idxs | ...
    cellfun( @(x)(isequal(x, [clique_num, clique_num+1])), clique_vars);
  
  % further, if clique_num is 1, then add it to this as well
  if clique_num == num_cliques
    reqd_feature_idxs = reqd_feature_idxs | ...
      cellfun(@(x)(isequal(x, num_cliques+1)), clique_vars);
  end
  
  reqd_features = featureSet.features(reqd_feature_idxs);
  reqd_coeffs = theta([reqd_features.paramIdx]);
  
  % DEBUG
%   fprintf('clique_num = %d, reqd_features = %d\n', clique_num, numel(reqd_coeffs));
  
  clique_factor = struct('var', [clique_num, clique_num+1], ...
                         'card', card, ...
                         'val', zeros(1, prod(card) ) ...
                        );
  A = IndexToAssignment(1:prod(clique_factor.card), clique_factor.card);
  for i = 1:prod(card)
%     fprintf('%d\n', i);
    assignment = zeros(1, num_cliques+1);
    assignment(clique_factor.var) = A(i, :);
%     A(i), assignment,
    feat_vec = GenerateFeatureVector(assignment, reqd_features);
    clique_factor.val(i) = exp ( reqd_coeffs * feat_vec );
  end
end