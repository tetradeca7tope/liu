function [errorRates] = reconstruct(image, nRows, nCols, nodePot, edgePot, edgeStruct, burnIn, blocks, initial, maxSteps,stepSize)

  tic;
  [nodeBelHist junk] = UGM_Sample_Infer_Block_Gibbs(nodePot,edgePot,edgeStruct,burnIn,blocks,...
                                                    @UGM_Sample_Infer_Tree, initial);
  toc

  figure;
  
  for i = 1:maxSteps
      upto = i*stepSize;
      [junk nodeLabels] = max(nodeBelHist(:, :, upto), [], 2);
      recon = reshape(nodeLabels, nRows, nCols);
      errorRates(i) = (sum(sum(abs(1 - (recon == image))))) / (nRows * nCols);
      subplot(2,5,i);
      imagesc(recon);
      colormap gray
  end
end
