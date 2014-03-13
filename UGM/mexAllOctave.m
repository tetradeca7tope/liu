
function mexme(outdir, srcdir, fn)
  cmd = sprintf("mkoctfile --mex --output %s/%s.mex %s/%s.c", outdir, fn, srcdir, fn) ;
  [ status output ] = system(cmd) ;
  if status!=0
    error("Executing command %s\n", cmd);
  else
    delete(sprintf("%s/%s.o", srcdir, fn));
    printf("%s compiled\n", fn);
  endif
endfunction 

mexme("minFunc_2009", "minFunc_2009", "lbfgsC");
mexme("minFunc_2009", "minFunc_2009", "mcholC");
mexme("KPM", "KPM", "max_mult");

mexme("compiled", "mex", "UGM_makeEdgeVEC");
mexme("compiled", "mex", "UGM_Decode_ExactC");
mexme("compiled", "mex", "UGM_Infer_ExactC");
mexme("compiled", "mex", "UGM_Infer_ChainC");
mexme("compiled", "mex", "UGM_makeClampedPotentialsC");
mexme("compiled", "mex", "UGM_Decode_ICMC");
mexme("compiled", "mex", "UGM_Decode_GraphCutC");
mexme("compiled", "mex", "UGM_Sample_GibbsC");
mexme("compiled", "mex", "UGM_Infer_MFC");
mexme("compiled", "mex", "UGM_Infer_LBPC");
mexme("compiled", "mex", "UGM_Decode_LBPC");
mexme("compiled", "mex", "UGM_Infer_TRBPC");
mexme("compiled", "mex", "UGM_Decode_TRBPC");
mexme("compiled", "mex", "UGM_CRF_makePotentialsC");
mexme("compiled", "mex", "UGM_CRF_PseudoNLLC");
mexme("compiled", "mex", "UGM_LogConfigurationPotentialC");
mexme("compiled", "mex", "UGM_Decode_AlphaExpansionC");
mexme("compiled", "mex", "UGM_Decode_AlphaExpansionBetaShrinkC");
mexme("compiled", "mex", "UGM_CRF_NLLC");

%mex -Imex -outdir compiled mex/UGM_makeEdgeVEC.c
%mex -Imex -outdir compiled mex/UGM_Decode_ExactC.c
%mex -Imex -outdir compiled mex/UGM_Infer_ExactC.c
%mex -Imex -outdir compiled mex/UGM_Infer_ChainC.c
%mex -Imex -outdir compiled mex/UGM_makeClampedPotentialsC.c
%mex -Imex -outdir compiled mex/UGM_Decode_ICMC.c
%mex -Imex -outdir compiled mex/UGM_Decode_GraphCutC.c
%mex -Imex -outdir compiled mex/UGM_Sample_GibbsC.c
%mex -Imex -outdir compiled mex/UGM_Infer_MFC.c
%mex -Imex -outdir compiled mex/UGM_Infer_LBPC.c
%mex -Imex -outdir compiled mex/UGM_Decode_LBPC.c
%mex -Imex -outdir compiled mex/UGM_Infer_TRBPC.c
%mex -Imex -outdir compiled mex/UGM_Decode_TRBPC.c
%mex -Imex -outdir compiled mex/UGM_CRF_makePotentialsC.c
%mex -Imex -outdir compiled mex/UGM_CRF_PseudoNLLC.c
%mex -Imex -outdir compiled mex/UGM_LogConfigurationPotentialC.c
%mex -Imex -outdir compiled mex/UGM_Decode_AlphaExpansionC.c
%mex -Imex -outdir compiled mex/UGM_Decode_AlphaExpansionBetaShrinkC.c
%mex -Imex -outdir compiled mex/UGM_CRF_NLLC.c
