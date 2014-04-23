function pairs = getTwoVecCombs(v1, v2)
% v1 and v2 are row vectors of size n1 x n2. Returns an (n1*n2) x 2 vector with
% all possible pairs - one taken from v1 and the second taken from v2;
  [idx2, idx1] = find(true(numel(v2), numel(v1)));
  pairs = [v1(idx1) v2(idx2)];
end
