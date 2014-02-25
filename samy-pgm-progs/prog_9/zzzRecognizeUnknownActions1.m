
% You should put all your code for recognizing unknown actions in this file.
% Describe the method you used in YourMethod.txt.
% Don't forget to call SavePrediction() at the end with your predicted labels to save them for submission, then submit using submit.m

% Create Mock test labels
datasetTest3.labels = zeros(90,1);

% Merge the training and testing intances of dataset1,

dstrain = mtrain;
dstest = datasetTest3;

[dstrain, dstest] = zzzFeatureScaling(dstrain, dstest);

[accuracy, predictions, HMM_Model] = RecognizeActions(dstrain, dstest, G, 15);
accuracy,
SavePredictions(predictions);

beep,
                             