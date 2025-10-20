classdef ArcoTSAM_Res < ArcoTSAM_RBs
    %ArcoTSAM_Res Summary of this class goes here
    %   Condiciones de resistencia de las juntas de los elementos
    %   de elems = {}
    
    properties
        gM=1.5;          % Coeficiente de seguridad parcial del material
        fc=5;            % Resistencia 5N/mm2 (fábrica ladrillo CTE)
                         % Para calcular la resultante en kN/m
                         % 5*10^6/10^3*b/1.5
        nRes=3; % Numero de lados de la envolvente de las condiciones
                % de resistencia
        ConeS;  % Para definir estas restricciones como condicones de =
                % se van a introducir variables de holgura equivalentes
                % a '1-coeficiente de utilización'
        Conex;
        Hipts = {};  % 'Hipotesis de carga' de las Res
                     % [1 x numero de hipotesis] cell array.
                     %
                     % Si Hipts{i}=1 el 'vector f' es GetfR 
        VectU = {};
        VectS = {};
        VectE = {};
    end
    
    
    methods
        
        function   ns = GetNs(obj)
            nelem=obj.GetNelems;
            ns=0;
            for ielem = 1 : nelem                 
                ns = ns+(obj.elems{ielem}.GetNJuntas)*2;
            end
        end
        
        function   ns = GetNsAmp(obj)          
            ns = obj.GetNs + obj.GetNGdl; 
        end
        

        function obj = set.Conex(obj, conex)
            obj.Conex = conex;
        end   
        
        
        function   c = GetConex(obj)
            c=obj.Conex;
        end
        function   c = GetConexf(obj)
             c = obj.GetConex;
        end;  
        function   c = GetConeS(obj)
            nS    = obj.GetNs;
            
            c = [];
            for i = 1: obj.GetNelems
                cones=obj.elems{i}.GetConeS;
                conesl=obj.elems{i}.GetConeSNPl; % Se seleccionan los N
                c =  [c, cones(conesl~=0)];
            end
            
            c=[c,obj.ConeS];
        end
        %8s|
        function   sg = GetSigma(obj, varargin)
            sg=[];
            fprintf('%5s|%5s|%8s|%8s|%8s|%8s|%8s|%8s\n', 'elem', 'junt', ...
                'N1', 'N2','h','hcc','b','sigma');
            for ielem = 1 : obj.GetNelems
                njunt = obj.elems{ielem}.GetNJuntas;
                s=obj.elems{ielem}.GetVectS(varargin{:});
                Ljunta = obj.elems{ielem}.GetLJunta;
                b = obj.elems{ielem}.b;
                sgi=[];
                for ijunt = 1: njunt
                    % OJO ESTO DEPENDE DEL TIPO DE ELEMENTO. VALIDO PARA
                    % RB210. 
                    % TODO chequear el tipo de elemento
                    % TODO chequear el tipo de elemento
                    fprintf('%5.0d|%5.0d|', ielem, ijunt);
                    N1= s(3*(ijunt-1)+1);
                    N2= s(3*(ijunt-1)+2);
                    fprintf('%8.3f|%8.3f|', N1, N2);
                    ljunta = Ljunta(ijunt);
                    R=N1+N2;
                    hcc_2=min(abs(N1/R),abs(N2/R))*ljunta;
                    fprintf('%8.3f|%8.3f|%8.3f|', ...
                        ljunta, 2*hcc_2, b);
                    fprintf('%8.4f\n', R/b/(2*hcc_2)/1000);
                    sgi=[sgi, R/b/(2*hcc_2)/1000];
                end
                sg=[sg;sgi];
            end
        end
        
        function   iF = GetfR(obj)
            
            nfil=1;            
            % Condición de resistencia:
            % n1*eta+(eta-1)*n2+1/2*eta^2*Nmax<=0; eta=0:1
            % ... ver resto en GetR(obj)
            
            %Termino independiente de R
            for ielem = 1 : obj.GetNelems
                njunt = obj.elems{ielem}.GetNJuntas;
                for ijunt = 1: njunt   
                     for iRes=2 : obj.nRes 
                         iF(nfil,1)=1;
                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                         nfil=nfil+1;
                         iF(nfil,1)=1;
                         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                         nfil=nfil+1;
                     end
                end
            end
        end
            
        function   iH = GetH(obj)
            iH = GetR(obj);
        end
        function   iR = GetR(obj)
            % Condición de resistencia:
            % (obtenida calculando la recta tangente a la 
            %  curva de interacción para una distribución de tensiones 
            %  rectangular)
            % n1*eta+(eta-1)*n2+1/2*eta^2*Nmax<=0; eta=0:1  
            %
            % O normalizado
            % n1*eta/(R)+n2*(eta-1)/(R)-1<=0
            % con R=1/2*eta^2*Nmax
            %
            % Introduciendo variables de holgura se trasnsforman los <=
            % en igualdades. 
            % n1*eta/(R)+n2*(eta-1)/(R)-h=1
            % y se puede tratar los objetos ArcoTSAM_Res como ArcoTSAM_RB
            % donde GetH==GetR.
            %
            % La interpretación de las variables de horgura es inmediata
            % h=1-U, con U= coeficiente de utilización
            %
            % TODO El modo de ensamblar sparse es muy poco eficiente
            % Ver, por ejemplo, https://es.mathworks.com/matlabcentral/answers/203734-most-efficient-way-to-add-multiple-sparse-matrices-in-a-loop-in-matlab
            %
            nfil=1;
            ncol=1;
            iR=sparse(1,1,1);
            
            for ielem = 1 : obj.GetNelems
                njunt = obj.elems{ielem}.GetNJuntas;
                Ljunta = obj.elems{ielem}.GetLJunta;
                fcdkN_m=obj.fc*1000*obj.elems{ielem}.b/obj.gM;
                
                for ijunt = 1: njunt
                    % La primera restriccion en Ni<=0. En formato E/R
                    % da lugar a una indeterminación. Se omite
                    for iRes=2 : obj.nRes
                        %fprintf('%d/%d\n', iRes, obj.nRes);
                        eta=(iRes-1)/(obj.nRes-1);
                        
                        R=fcdkN_m*Ljunta(ijunt)*eta^2/2;
                        %R=1;
                        %iR(nfil,[ncol,ncol+1])=[eta eta-1]/R;
                        iR(nfil,[ncol,ncol+1])=[eta-1 eta]/R;
                        nfil=nfil+1;
                        iR(nfil,[ncol,ncol+1])=[eta eta-1]/R;
                        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                        nfil=nfil+1;
                    end
                    ncol=ncol+2;
                end
            end
            % Se añade una matriz I para incluir las variables de holgura
            % cuyo significado es h=1-E/R, 1 menos el coeficiente de util.
             for ifil= 1: nfil-1
                 ir=1;
%                  if mod(ifil,2)==0
%                      ir=ir*-1;
%                  end
                 iR(ifil, ncol+1-2+ifil)=ir;
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              for ifil= 1: nfil-4:2
%                  iR(ifil, ncol+1-2+ifil)=1;
%                  iR(ifil+1, ncol+1-2+ifil+1)=-1;
            end
        end
        
        function  ns = GetMaxConeS(obj)
            ns = 0;
            for i = 1: obj.GetNelems
                ns = max(ns, obj.elems{i}.GetMaxConeS);
            end
            ns = max([ns, obj.ConeS]);
        end
        
        function  nc = GetMaxConex(obj)
            nc = 0;
            for i = 1: obj.GetNelems
                nc = max(nc, obj.elems{i}.GetMaxConex);
            end
            nc = max([nc, obj.Conex]);
        end
        
%         function nsf = SetConeS(obj,ns0)
%             nsf       = ns0+obj.GetNs;
%             obj.ConeS = [ns0+1:nsf];
%         end
        function nsf=SetConeS(obj, varargin)
            
            
            ns0=chkArg(0, varargin{:});

            %fprintf ('ArcoTSAM_Res.SetConeS chapuza provisonal %d %d\n', sum(abs(obj.GetfR)),obj.GetNsAmp-obj.GetNs);
            %nsf=ns0+(sum(abs(obj.GetfR)));
            nsf       = ns0+obj.GetNsAmp-obj.GetNs;
            obj.ConeS=[ns0+1:nsf];
            
        end
        
        function  ng = olgGetNGdl(obj)
            fprintf ('ArcoTSAM_Res.GetNGdl chapuza provisonal %d\n', numel(obj.Conex));      
            ng = numel(obj.Conex);
        end
        function  ng = GetNGdl(obj)
            nelem=obj.GetNelems;
            ng=0;
            for ielem = 1 : nelem                 
                ng = ng+(obj.elems{ielem}.GetNJuntas)*2*(obj.nRes-1);
            end
        end

         function SetG(obj, iHip)
             obj.Hipts{iHip}=0;
         end
         
         function SetR(obj, iHip)
             % Hipótesis en la cual se introducen las condiciones de res
             obj.Hipts{iHip}=1;
         end
         
         function  nh = GetNHipts(obj)
            nh = numel(obj.Hipts);
         end 
         
         function   f = Getf(obj, varargin)
             iHip=chkIndex(obj.GetNHipts, varargin{:});
             f=obj.GetfR;
             if (obj.Hipts{iHip} ~= 1)
                f=f*0;
             end
         end
         
         function  np = GetConeSNPl(obj)
             np=ones(1,obj.GetNsAmp);
         end
         
         function  np = GetConeSNAl(obj)
             np=zeros(1,obj.GetNsAmp);
         end
         
         function  np = GetConeSl(obj)
             np=ones(1,obj.GetNsAmp);
         end
         
%          function  ns = GetNsol(obj)
%              ns = 0;
%              for ielem = 1: obj.GetNelems
%                  ns = max(ns, obj.elems{ielem}.GetNsol);
%              end
%          end
    

         function addju(obj, vectU, varargin)
         end
         function addUyReacc(obj,varargin)
         end
         function xuy = GetVectUy(obj,varargin)
             xuy=[];
         end
         function       addu(obj, vectU, varargin)
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            obj.VectU{nsol}=vectU;
         end
         
         % Funcion copiada de ArcoTSAM_RB
         function  ns = GetNsol(elem)
             ns = size(elem.VectU,2);
         end
         % Funcion copiada de ArcoTSAM_RB
         function       adds(obj, vectS, varargin)
             nsol=chkIndexIn(obj.GetNsol,varargin{:});
             cs=obj.GetConeS;
             ivectS=[];
             ivectS(cs~=0)=vectS(cs(cs~=0));
             obj.VectS{nsol}=ivectS';
         end
         % Funcion copiada de ArcoTSAM_RB
         function       adde(obj, vectE, varargin)
             nsol=chkIndexIn(obj.GetNsol,varargin{:});
             cs=obj.GetConeS;
             cs=cs(cs~=0);
             obj.VectE{nsol}=vectE(cs);
         end
         
         function   g = plotu(obj, varargin)
             g=[];
         end
         
         function   lb = GetLb(obj) 
            lb=[];
            for i = 1: obj.GetNelems
                %cones=obj.elems{i}.GetConeS;
                % OJO esto solo es valido para RESISTENCIA en N
                conesl=obj.elems{i}.GetConeSNPl; % Se seleccionan los N
                lb =  [lb, -Inf*(conesl(conesl))];
            end
            lb = [lb, -Inf*ones(1,GetNGdl(obj))];
        end
        
        function   ub = GetUb(obj)
            ub=[];
            for i = 1: obj.GetNelems
                %cones=obj.elems{i}.GetConeS;
                % OJO esto solo es valido para RESISTENCIA en N
                conesl=obj.elems{i}.GetConeSNPl; % Se seleccionan los N
                ub =  [ub, 0*(conesl(conesl))];
            end
            ub = [ub, zeros(1,GetNGdl(obj))];
        end
        
        function u=GetVectU(obj, iSol)
            
            u =  obj.VectU{iSol};
        end
        
        function s=GetVectS(obj, iSol)
            warning('Esto no debería ocurrir, ¿o sí?');
            s =  obj.VectS{iSol};
        end       
    end
end

