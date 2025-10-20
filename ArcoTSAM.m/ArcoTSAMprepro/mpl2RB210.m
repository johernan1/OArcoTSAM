function MRB = mpl2RB210( nodos, topo )
%MPL2RB210 Summary of this function goes here
%   Detailed explanation goes here


    % create a directory "+containers" in Octaves "m" folder (you have to use sudo if it's a global install)
    % wget http://hg.savannah.gnu.org/hgweb/octave/raw-file/b04466113212/scripts/%2Bcontainers/Map.m

    MRB=ArcoTSAM_ModeloNL();
    hconex = containers.Map;
    ns=0;
    for ielem=1:numel(topo)
% fprintf('-------------------------------------------------elemto=%d, iRB \n', ielem);
% topo{ielem}
% abs(topo{ielem})
% nodos
% nodos(abs(topo{ielem}),:)

%iRB.Geome
%fprintf('itopo \n'); itopo
        iRB=ArcoTSAM_RB210NL(); 
        nGdlxJ=iRB.nGdlxJ;
        %iRB.Geome=nodos(abs(topo(ielem,:)),:);
        %itopo=topo(ielem,:);
        iRB.Geome=nodos(abs(topo{ielem}),:);
        itopo=topo{ielem};
        
        junta=[];
        conex=[];
        nnud = size(itopo,2);
        for inud=1: nnud
            if itopo(inud)<0  
                if inud==nnud
                    inud1=1;
                else    
                    inud1=inud+1;
                end                  
                junta(end+1,1:2)=[inud inud1];
%fprintf('Junta:'); junta
                key1=strcat(num2str(itopo(inud)),',',num2str(itopo(inud1)));
                key2=strcat(num2str(-itopo(inud1)),',',num2str(-itopo(inud)));
                if isKey(hconex,key1) || isKey(hconex,key2)
                else
                    hconex(key1)=(1:nGdlxJ)+ns;
                    hconex(key2)=(1:nGdlxJ)+ns;
                    ns=ns+nGdlxJ;
                end
                conex(end+1,1:nGdlxJ)=hconex(key1);
            end
        end
        % Los gdl de cada solid
        conex(end+1,1:3)=(1:3)+ns;
        ns=ns+3;
        iRB.Junta=junta;
        iRB.Conex=conex;
        MRB.Adds(iRB);
    end
end

