function [blocks] = partition_to_blocks(partition)

% We need to convert the partition into a cell array and remove the trailing zeros
% that wenlu had to add.
[nBlocks, junk] = size(partition);
blocks = {};
n = 1;
for i = 1:nBlocks
	row = partition(i, :);
	last = find(row, 1, 'last');
	if not(isempty(last))
		blocks{n} = row(1:last)';
		n = n + 1;
	end
end

blocks = blocks';

end
