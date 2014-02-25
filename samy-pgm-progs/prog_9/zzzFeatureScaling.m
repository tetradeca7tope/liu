function [ datasetTrain, datasetTest ] = ...
  zzzFeatureScaling( datasetTrain, datasetTest )

% This function modifies the poses in the training and testing data.
all_poses = [datasetTrain(1).poseData; datasetTrain(2).poseData; ...
             datasetTrain(3).poseData; datasetTest.poseData];
           
means = mean(all_poses);
means(:,:,3) = 0;

stds = std(all_poses);
stds(:,:,3) = 1;

for i = 1:3
  for j = 1:size(datasetTrain(i).poseData, 1)
    datasetTrain(i).poseData(j,:,:) = ...
      (datasetTrain(i).poseData(j,:,:) - means) ./ stds;
  end
end

% Now normalize the Test Data
for j = 1:size(datasetTest.poseData, 1)
  datasetTest.poseData(j,:,:) = ...
    (datasetTest.poseData(j,:,:) - means) ./ stds;
end

end

