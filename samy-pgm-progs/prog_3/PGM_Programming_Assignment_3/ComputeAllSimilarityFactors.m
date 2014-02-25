function factors = ComputeAllSimilarityFactors (images, K)
% This function computes all of the similarity factors for the images in
% one word.
%
% Input:
%   images: An array of structs containing the 'img' value for each
%     character in the word.
%   K: The alphabet size (accessible in imageModel.K for the provided
%     imageModel).
%
% Output:
%   factors: Every similarity factor in the word. You should use
%     ComputeSimilarityFactor to compute these.
%
% Copyright (C) Daphne Koller, Stanford University, 2012

n = length(images);
f_idxs = nchoosek (1:n, 2);
nFactors = size(f_idxs, 1);

factors = repmat(struct('var', [], 'card', [K, K], 'val', []),  nFactors, 1);
% Your code here:
for i = 1:nFactors
  factors(i) = ComputeSimilarityFactor (images, K, ...
                  f_idxs(i,1), f_idxs(i,2));
end

end

