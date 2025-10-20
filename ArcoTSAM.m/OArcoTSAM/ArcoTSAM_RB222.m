classdef ArcoTSAM_RB222 < ArcoTSAM_RB
    %ArcoTSAM_RB222 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
      %nDatosJunta=10
      %GeomConex
      %nCxJ
    end
    
    properties
      %Geom
      %  GeomConex
       
    end
    
    methods
                
        function elem = ArcoTSAM_RB222(geomConex)
          elem.nGdlxJ=6;
          elem.nSxJ=6;
          if ~nargin
              % the default constructor. Needed for array creation
          else
              % only take care of the array part for simplicity:
              if iscell(geomConex)
                  disp '---pendiente de programar -----'
                %[elem(1:length(GeomConex)).GeomConex] = deal(GeomConex{:});
                for ielem = 1: length(geomConex)
                    elem(ielem).geomConex=geomConex{ielem};
                end
              else
                % Las tres ultimas componentes son las conex del solido
                GeomConex=geomConex(1:end-3);
                GeomConex=reshape(GeomConex,10,size(GeomConex,2)/10);
                njunt=size(GeomConex,2);
                elem.Geome = (reshape(GeomConex(1:4,:),2,2*njunt))';
                elem.Junta = (reshape(1:2*njunt,2,njunt))';
                %elem.Conex = GeomConex(5:10,:)';
                %[GeomConex(5:10,:)'
                %[geomConex(end-2:end) 0 0 0]]
                %obj.Conex = [GeomConex(5:7,:)'; geomConex(end-2:end)];
                elem.Conex = [GeomConex(5:10,:)'
                             [geomConex(end-2:end) 0 0 0]];
              end
          end
        end
        
        function ngdl = GetNGdl(elem)
            njunt = GetNJuntas(elem);
            ngdl = elem.nGdlxJ*njunt+3;
        end 
             
        function   ns = GetNs(elem)
            njunt = GetNJuntas(elem);
            ns = elem.nGdlxJ*njunt;
        end 
        
        %Obsoleta
        function   iH = GetH0(elem)
  
            njunt = GetNJuntas(elem);
            ngdl  = GetNGdl(elem);
            ns    = GetNs(elem);
  
            iH = zeros(ngdl, ns);
            for ijunt = 1 : njunt
                xi = elem.Geome(elem.Junta(ijunt,1),1);
                zi = elem.Geome(elem.Junta(ijunt,1),2);
                xj = elem.Geome(elem.Junta(ijunt,2),1);
                zj = elem.Geome(elem.Junta(ijunt,2),2); 

                lx = xj-xi;
                lz = zj-zi;
                l = sqrt(lx*lx+lz*lz); 
                c = lx/l;
                s = lz/l;
                ih = [-s c 0;
                       c s 0;
                       0 0 1];
                % EQU nudo i ----------------------------------------------
                icolH = elem.nSxJ*(ijunt-1)+1;
                jcolH = elem.nSxJ*(ijunt-1)+3;
                iH(icolH:jcolH,icolH:jcolH) = ih;
                % EQU elem ------------------------------------------------
                % EQU elem ->
                iH(ngdl-2,icolH:jcolH) = ih(1,:);
                % EQU elem |
                iH(ngdl-1,icolH:jcolH) = ih(2,:);
                % EQU elem @
                iH(ngdl,icolH:jcolH)   = ih(1,:)*zi- ih(2,:)*xi;
                iH(ngdl,jcolH)         = 1;

                % EQU nudo j ----------------------------------------------    
                icolH = elem.nSxJ*(ijunt-1)+4;
                jcolH = elem.nSxJ*(ijunt-1)+6;   
                iH(icolH:jcolH,icolH:jcolH) = ih;
                iH(jcolH,  jcolH)= -1;
                % EQU elem ------------------------------------------------
                % EQU elem ->
                iH(ngdl-2,icolH:jcolH) = ih(1,:);
                % EQU elem |
                iH(ngdl-1,icolH:jcolH) = ih(2,:);
                % EQU elem @
                iH(ngdl,icolH:jcolH)   = ih(1,:)*zj- ih(2,:)*xj;
                iH(ngdl,jcolH)         = -1;
            end  
        end 
        
        function   iH = GetH(elem)
  
            njunt = GetNJuntas(elem);
            ngdl  = GetNGdl(elem);
            ns    = GetNs(elem);
  
            iH = zeros(ngdl, ns);
            for ijunt = 1 : njunt
                xi = elem.Geome(elem.Junta(ijunt,1),1);
                zi = elem.Geome(elem.Junta(ijunt,1),2);
                xj = elem.Geome(elem.Junta(ijunt,2),1);
                zj = elem.Geome(elem.Junta(ijunt,2),2); 

                lx = xj-xi;
                lz = zj-zi;
                l = sqrt(lx*lx+lz*lz); 
                c = lx/l;
                s = lz/l;
                
                % EQU nudo i ----------------------------------------------
                ih = [-s         c         0;
                       c         s         0;
                      -s*zi-c*xi c*zi-s*xi 1];
                icolH = elem.nSxJ*(ijunt-1)+1;
                jcolH = elem.nSxJ*(ijunt-1)+3;
                iH(icolH:jcolH,icolH:jcolH)  = ih;
                % EQU elem ------------------------------------------------
                iH(ngdl-2:ngdl, icolH:jcolH) = ih; 

                % EQU nudo j ----------------------------------------------
                ih =  [-s         c         0;
                        c         s         0;
                       -s*zj-c*xj c*zj-s*xj 1];    
                icolH = elem.nSxJ*(ijunt-1)+4;
                jcolH = elem.nSxJ*(ijunt-1)+6;   
                iH(icolH:jcolH,icolH:jcolH)  = ih;
                % EQU elem ------------------------------------------------
                iH(ngdl-2:ngdl, icolH:jcolH) = ih; 
                
            end  
        end 
             
        function   lb = GetLb(elem)
            njunt = GetNJuntas(elem);
            lb = [];
            for ijunt = 1 : njunt  
                       %    N    V    m    N    V     m
                lb = [lb -Inf -Inf -Inf  -Inf -Inf -Inf];
            end
        end
        
        function   ub = GetUb(elem)
            njunt = GetNJuntas(elem);
            ub = [];
            for ijunt = 1 : njunt  
                       %    N    V    m    N    V    m      
                ub = [ub    0  Inf    0    0  Inf    0];
            end    
        end
    end       
    %methods (Static)
    %end
end

