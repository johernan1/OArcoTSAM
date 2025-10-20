%%
 % se imprime información del LP a resolver

function infoLP
  
  global fq fg H 

  whosfq=whos('fq');
  whosfg=whos('fg');
  whosH=whos('H');
  
  fprintf('issparse(fq) .................. %d, (%d), %d\n', ...
          issparse(fq), size(fq,1), whosfq.bytes);
  fprintf('issparse(fg) .................. %d, (%d), %d\n', ...
          issparse(fg), size(fg,1), whosfg.bytes);
  fprintf('issparse(H) .................. %d, (%d, %d), %d\n', ...
          issparse(H), size(H,1), size(H,2), whosH.bytes);

end
