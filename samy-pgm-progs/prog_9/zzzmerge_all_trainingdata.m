
% num_poses_in_train1 = size(datasetTrain1.poseData, 1);
% num_poses_in_train2 = size(datasetTrain2.poseData, 1);
% num_poses_in_train3 = size(datasetTrain3.poseData, 1);
% num_poses_in_test1 = size(datasetTest1.poseData, 1);
% num_poses_in_test2 = size(datasetTest2.poseData, 1);
% 
% mdstrain = datasetTrain1;
% mdstest = datasetTest1;
% 
% ds2_temp = datasetTrain2;
% for i = 1:3
%   ds2_temp
% end

mtrain = datasetTrain1;
mtemp = datasetTest1;
for i = 1:3
  actions = datasetTest1.actionData((i-1)*30 + 1 : i*30);
  poses = actions(1).marg_ind(1):actions(30).marg_ind(end);
  pairs = actions(1).pair_ind(1):actions(30).pair_ind(end);
  actions, size(poses), size(pairs),
  num_new_poses = numel(poses);
  num_new_pairs = numel(pairs);
  
  pose_offset = size(datasetTrain1(i).InitialClassProb, 1) - actions(1).marg_ind(1) +1;
  pair_offset = size(datasetTrain1(i).InitialPairProb, 1) - actions(1).pair_ind(1) +1;
  
  % modify marg_ind and pair_ind in actions
  for j = 1:numel(actions)
    actions(j).action = 'unknown';
    actions(j).marg_ind = actions(j).marg_ind + pose_offset;
    actions(j).pair_ind = actions(j).pair_ind + pair_offset;
  end
  
  mtrain(i).actionData, actions,
  mtrain(i).actionData = [mtrain(i).actionData, actions];
  
%   size(mtrain.poseData), size(datasetTest1.poseData(poses,:,:)),
  mtrain(i).poseData = [mtrain(i).poseData; ...
                        datasetTest1.poseData(poses,:,:)];
  mtrain(i).InitialClassProb = [mtrain(i).InitialClassProb; ...
                                ones(num_new_poses, 3)/3];
  mtrain(i).InitialPairProb = [mtrain(i).InitialPairProb; ...
                                ones(num_new_poses, 9)/9]
                                
end