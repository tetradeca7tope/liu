%GETNEXTCLIQUES Find a pair of cliques ready for message passing
%   [i, j] = GETNEXTCLIQUES(P, messages) finds ready cliques in a given
%   clique tree, P, and a matrix of current messages. Returns indices i and j
%   such that clique i is ready to transmit a message to clique j.
%
%   We are doing clique tree message passing, so
%   do not return (i,j) if clique i has already passed a message to clique j.
%
%	 messages is a n x n matrix of passed messages, where messages(i,j)
% 	 represents the message going from clique i to clique j. 
%   This matrix is initialized in CliqueTreeCalibrate as such:
%      MESSAGES = repmat(struct('var', [], 'card', [], 'val', []), N, N);
%
%   If more than one message is ready to be transmitted, return 
%   the pair (i,j) that is numerically smallest. If you use an outer
%   for loop over i and an inner for loop over j, breaking when you find a 
%   ready pair of cliques, you will get the right answer.
%
%   If no such cliques exist, returns i = j = 0.
%
%   See also CLIQUETREECALIBRATE
%
% Copyright (C) Daphne Koller, Stanford University, 2012


function [sender, receiver] = GetNextCliques(P, messages)

% initialization
% you should set them to the correct values in your code
sender = 0;
receiver = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YOUR CODE HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% P, P.edges, messages,
N = size(messages, 1);

for i = 1:N
  
  % Obtain the list of nodes it has received a message from
  messages_received_from = zeros(1, N);
  messages_sent_to = zeros(1, N);
  for j = 1:N
    if (i ~= j && numel(messages(j, i).var) ~= 0)
      messages_received_from(j) = 1;
    end
    if (i ~= j && numel(messages(i, j).var) ~= 0)
      messages_sent_to(j) = 1;
    end
  end
  neighbors = P.edges(i,:);
  candidates = neighbors .* (1 - messages_sent_to);
  neighbors_not_received_from = neighbors .* (1 - messages_received_from);
%   fprintf('%i\nneighbors:     %s\nreceived_from: %s\nsent_to:       %s\ncandidates:    %s\nnot_received:  %s\n\n', i, ...
%     mat2str(neighbors), mat2str(messages_received_from), mat2str(messages_sent_to), ...
%     mat2str(candidates), mat2str(neighbors_not_received_from));
  
  if sum(neighbors_not_received_from) == 0
    cand_receiver = find(candidates, 1);
    if ~isempty(cand_receiver)
      sender = i;
      receiver = cand_receiver;
      return;
    end
  elseif sum(neighbors_not_received_from) == 1
    cand_receiver = find(neighbors_not_received_from);
    if (messages_sent_to(cand_receiver) == 0)
      sender = i;
      receiver = cand_receiver;
      return;
    end
  end
  
end



return;
