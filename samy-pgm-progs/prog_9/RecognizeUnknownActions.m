% You should put all your code for recognizing unknown actions in this file.
% Describe the method you used in YourMethod.txt.
% Don't forget to call SavePrediction() at the end with your predicted labels to save them for submission, then submit using submit.m

% Create Mock test labels
datasetTest3.labels = zeros(90,1);

dstrain = mtrain;
dstest = datasetTest3;

for i = 1:3
  mtrain(i).InitialClassProb = ones(size(mtrain(i).InitialClassProb, 1), 6)/6;
  mtrain(i).InitialPairProb = ones(size(mtrain(i).InitialPairProb, 1), 36)/36;
end

[dstrain, dstest] = zzzFeatureScaling(dstrain, dstest);

[~, predictions3] = RecognizeActions(dstrain, dstest, G, 10);
% SavePredictions(predictions);
                               
