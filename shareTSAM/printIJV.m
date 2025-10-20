function printIJV(file_id,S)
  [i,j,v] = find(S);
  %file_id = fopen(file_name,'wt');
  % uncomment this to have the first line be:
  % num_rows num_cols
  fprintf(file_id,'%d %d\n', size(S));
  fprintf(file_id,'%d %d %g\n',[i,j,v]');
  %fclose(file_id);
end
