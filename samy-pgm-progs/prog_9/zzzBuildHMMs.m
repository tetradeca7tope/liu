% File: RecognizeActions.m
%
% Copyright (C) Daphne Koller, Stanford Univerity, 2012

function [HMM_Models] = zzzBuildHMMs(datasetTrain, G, maxIter)

% INPUTS
% datasetTrain: dataset for training models, see PA for details
% datasetTest: dataset for testing models, see PA for details
% G: graph parameterization as explained in PA decription
% maxIter: max number of iterations to run for EM

% OUTPUTS
% accuracy: recognition accuracy, defined as (#correctly classified examples / #total examples)
% predicted_labels: N x 1 vector with the predicted labels for each of the instances in datasetTest, with N being the number of unknown test instances

num_classes = numel(datasetTrain);
K = size(datasetTrain(1).InitialClassProb, 2);

% First, correct the dimensionality of G
if size(G,3) == 1
  for k = 1:K
    G(:,:,k) = G(:,:,1);
  end
end

% Train a model for each action
% Note that all actions share the same graph parameterization and number of max iterations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:num_classes
  HMM_Models(i) = EM_HMM(datasetTrain(i).actionData, ...
                        datasetTrain(i).poseData, ...
                        G, ...
                        datasetTrain(i).InitialClassProb, ...
                        datasetTrain(i).InitialPairProb, ...
                        maxIter);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Classify each of the instances in datasetTrain
% Compute and return the predicted labels and accuracy
% Accuracy is defined as (#correctly classified examples / #total examples)
% Note that all actions share the same graph parameterization

% test_loglikelihoods = zeros(num_test_data, num_classes);
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % YOUR CODE HERE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for i = 1:num_classes
%   test_loglikelihoods(:,i) = EstimateProbs(HMM_Model(i), ...
%                                            datasetTest.actionData, ...
%                                            datasetTest.poseData, ...
%                                            G, K);                                         
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [~, predicted_labels] = max(test_loglikelihoods, [], 2);
% accuracy = sum( predicted_labels == datasetTest.labels )/ num_test_data;
end