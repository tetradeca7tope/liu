%% Generate a "patch image"

nRows = 50;
nCols = 50;
nStates = 11;
nNodes = nRows * nCols;
patchWidth = 5;
patchHeight = patchWidth;

% How many pixels to flip
noiseLevel = nNodes * .10;

%% Generate the normal image
image = [];
for i = 1:(nRows/patchHeight)
    rowOfPatches = [];
    for j = 1:(nCols/patchWidth)
        %patchState = mod(i * (nRows/patchHeight) + j, nStates);
        patchState = randi(nStates);
        patch = repmat(patchState, [patchHeight, patchWidth]);
        rowOfPatches = [rowOfPatches patch];
    end
    image = [image ; rowOfPatches];
end

figure;
imagesc(image);
colormap gray

%% Add noise

% Pick the pixels to noise. 
noisyImage = image;
perm = randperm(nNodes, noiseLevel);
for i = 1:noiseLevel
    % Flip the pixel, force it to _not_ end up being the same thing
    old = image(ind2sub(size(image), perm(i)));
    offset = randi(nStates - 1);
    noisyImage(ind2sub(size(image), perm(i))) = mod(old + offset, nStates) + 1;
end

figure;
imagesc(noisyImage);
colormap gray
