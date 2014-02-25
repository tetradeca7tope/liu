%CLIQUETREECALIBRATE Performs sum-product or max-product algorithm for 
%clique tree calibration.

%   P = CLIQUETREECALIBRATE(P, isMax) calibrates a given clique tree, P 
%   according to the value of isMax flag. If isMax is 1, it uses max-sum
%   message passing, otherwise uses sum-product. This function 
%   returns the clique tree where the .val for each clique in .cliqueList
%   is set to the final calibrated potentials.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

function P = CliqueTreeCalibrate(P, isMax)


% Number of cliques in the tree.
N = length(P.cliqueList);

% Setting up the messages that will be passed.
% MESSAGES(i,j) represents the message going from clique i to clique j. 
MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% We have split the coding part for this function in two chunks with
% specific comments. This will make implementation much easier.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isMax == 1
  % Log Transform
  for i = 1:numel(P.cliqueList)
    P.cliqueList(i).val = log(P.cliqueList(i).val); 
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% YOUR CODE HERE
% While there are ready cliques to pass messages between, keep passing
% messages. Use GetNextCliques to find cliques to pass messages between.
% Once you have clique i that is ready to send message to clique
% j, compute the message and put it in MESSAGES(i,j).
% Remember that you only need an upward pass and a downward pass.
%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[sender, receiver] = GetNextCliques(P, MESSAGES);
while (sender ~= 0)
%   fprintf('sender, receiver: %d, %d\n', sender, receiver);
  
  % starting with the current potentials start computing the factor prods
  curr_message = P.cliqueList(sender);
  neighbors = P.edges(sender,:);
  for i = 1:N
    % If the current sender has received any messages from its neighbors
    % then incorporate them into the messages passed as well.
    if (neighbors(i) && receiver ~= i && (~ isempty(MESSAGES(i, sender).var)))
      if isMax == 1
        curr_message = FactorSum(curr_message, MESSAGES(i, sender));
      else
        curr_message = FactorProduct(curr_message, MESSAGES(i, sender));
      end
%curr_message,
    end
  end
  
  
%   fprintf('Sender vars: %s\nReceiver vars: %s\n\n', ...
%           mat2str(P.cliqueList(sender).var), mat2str(P.cliqueList(receiver).var));
  % Finally marginalize over the non Sep-set variables.
  if isMax == 1
    MESSAGES(sender, receiver) = FactorMaxMarginalization(curr_message, ...
                                  setdiff(curr_message.var, P.cliqueList(receiver).var));
  else
    MESSAGES(sender, receiver) = FactorMarginalization(curr_message, ...
                                  setdiff(curr_message.var, P.cliqueList(receiver).var));
    MESSAGES(sender, receiver).val = MESSAGES(sender, receiver).val / sum(MESSAGES(sender, receiver).val);
  end
    %   fprintf('Message sent:');
%   MESSAGES(sender, receiver),
  
  [sender, receiver] = GetNextCliques(P, MESSAGES);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%
% Now the clique tree has been calibrated. 
% Compute the final potentials for the cliques and place them in P.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% fprintf('##################################\n');
for i = 1:N
  curr_beliefs = P.cliqueList(i);
  neighbors = P.edges(i,:);
  
  for j = 1:N
    if (neighbors(j) && (~ isempty(MESSAGES(j, i).var)))
%       curr_beliefs,
%       MESSAGES(j, i),
      if isMax == 1
        curr_beliefs = FactorSum(curr_beliefs, MESSAGES(j, i));
      else
        curr_beliefs = FactorProduct(curr_beliefs, MESSAGES(j, i));
      end
%       curr_beliefs,
    end
  end
  P.cliqueList(i) = curr_beliefs;
end

return
