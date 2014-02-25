function [accuracy, predicted_labels] = ...
  zzzMakePredictions( HMM_Models, datasetTest, G, K )
%ZZZMAKEPREDICTIONS Summary of this function goes here
%   Detailed explanation goes here

% First, correct the dimensionality of G
if size(G,3) == 1
  for k = 1:K
    G(:,:,k) = G(:,:,1);
  end
end

num_classes = numel(HMM_Models);
% num_vars = size(G, 1);
num_test_data = numel(datasetTest.actionData);

% Initialize test_loglikelihoods
test_loglikelihoods = zeros(num_test_data, num_classes);

for i = 1:num_classes
  test_loglikelihoods(:,i) = zzzEstimateProbs(HMM_Models(i), ...
                                           datasetTest.actionData, ...
                                           datasetTest.poseData, ...
                                           G, K);                                         
end

[~, predicted_labels] = max(test_loglikelihoods, [], 2);
accuracy = sum( predicted_labels == datasetTest.labels )/ num_test_data;

end

