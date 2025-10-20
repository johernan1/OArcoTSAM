function   wobinichTamino( varargin )
%WOBINICH Summary of this function goes here
%   Detailed explanation goes here

    aux=dbstack;
    naux=size(aux,1);
    for iaux=1: naux-1
        txtaux=sprintf('%s', aux(naux+1-iaux).name);
        section(txtaux,iaux-1,1);
    end
end

