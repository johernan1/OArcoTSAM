classdef ArcoTSAM_Modelo < ArcoTSAM_RBs
    %ArcoTSAM_Modelo Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        H; % Calcular H es muy costoso, por lo que cuando se ensambla se 
           % conserva una copia por si es necesario utilizarla mas de una
           % vez
        epsEQU = 10^-10;
    end
    
   
    methods
        
        
        % matlab.mixin.Copyable no funciona en octave
        function newObj = copy(obj)
            %wobinichTamino;
            newObj = eval(class(obj));
            newObj.H = obj.H;
            for ielem = 1 : numel(obj.elems)
                newElem =  obj.elems{ielem}.copy;
                newObj.Adds(newElem);
            end
        end
               
%         function obj = Adds(obj,RB)
%             obj.elems{size(obj.elems,2)+1} = RB;
%         end

        function iH = iGetH(obj, varargin)   
            % Extrae partes de H:
            % MRB.iGetH(':',1);  Primera columna de H 
            % MRB.iGetH(':',abs(c)>10^-5);  Columnas de H que cumplen la
            % condición abs(c)>10^-5
            iH=obj.H(varargin{:});
        end
     
        function  nj = GetNJuntas(obj)
            nj = 0;
            for i = 1: size(obj.elems,2)
                nj = nj + obj.elems{i}.GetNJuntas;
            end
        end
        
        function  ns = GetNs(obj)
            ns = 0;
            %             for i = 1: size(obj.elems,2)
            %                 ns = ns + obj.elems{i}.GetNs;
            %             end
            ns = obj.GetMaxConeS;
            
            %            for i = 1: obj.GetNelems
            %                ns =  ns+ obj.elems{i}.GetNs;
            %            end
        end
        
        function  ns = GetNsAmp(obj)
%            warning('ArcoTSAM_Modelo.GetNsAmp-> TODO, TODO, TODO')
            ns = obj.GetNs;
        end   
        
        function obj = MoveConex(obj, desp)
            for i = 1: obj.GetNelems
                 obj.elems{i}.MoveConex(desp);
            end
        end
        
        function  ns = GetMaxConeS(obj)
            ns = 0;
            for i = 1: obj.GetNelems
                ns = max(ns, obj.elems{i}.GetMaxConeS);
            end
        end
      
%         function  ns = KO_GetMaxConeR(obj)
%             ns = 0;
%             for i = 1: obj.GetNelems
%                 ns = max(ns, obj.elems{i}.GetMaxConeR);
%             end
%         end
  
        function  nc = GetMaxConex(obj)
            nc = 0;
            for i = 1: obj.GetNelems
                nc = max(nc, obj.elems{i}.GetMaxConex);
            end
        end
        
        function   c = GetConex(obj)
            c = zeros(obj.GetMaxConex,1);
            for i = 1: obj.GetNelems
                cx=obj.elems{i}.Conex;
                [cxi, cxj] = size(cx);
                cx=reshape(cx', cxi*cxj,1);
                c(cx(cx~=0))=cx(cx~=0);
                %reshape(obj.elems{i}.Conex, size(
            end
        end;
        
        function   c = GetConexf(obj)
            c = zeros(obj.GetMaxConex,1);
            for i = 1: obj.GetNelems
                cx=obj.elems{i}.GetConexf;
                [cxi, cxj] = size(cx);
                cx=reshape(cx', cxi*cxj,1);
                c(cx(cx~=0))=cx(cx~=0);
                %reshape(obj.elems{i}.Conex, size(
            end
        end;
        
%         function   c = GetConexf(obj)
%             c = obj.GetConex;
%             %c = c';
%         end;
        
        function   c = reSetConex(obj)
            % se "renumeran" las conexiones de los elemntos eliminando los 
            % "ceros". Cuando se hace una numeración automática se pueden
            % introducir condiciones de apoyo posteriormente anulando las
            % conexiones correspondientes. Esta funcion permite renumerar 
            % las conexiones eliminando los ceros   
            
            c = obj.GetConex;
            newc= c;
            lc=c~=0;
            ic=1;
            %TODO TODO seguro que se puede hacer sin for
            for i=1: obj.GetMaxConex
                if lc(i)
                    newc(i)=ic;
                    ic=ic+1;
                end
            end    
            
            for i = 1: obj.GetNelems
                cx=obj.elems{i}.Conex;
                cx(cx~=0)=newc(cx(cx~=0));
                obj.elems{i}.Conex=cx;
            end
        end;
        
        function  ng = GetNGdl(obj)
            ng = obj.GetMaxConex;
        end
        
%         function  ne = GetNelems(obj)
%             ne = size(obj.elems,2);
%         end
        
%         function  nh = GetNHipts(obj)
%             nh = 0;
%             for ielem = 1: obj.GetNelems
%                 nh = max(nh, obj.elems{ielem}.GetNHipts);
%             end
%         end 
              
        function  ns = GetNsol(obj)
            ns = 0;
            for ielem = 1: obj.GetNelems
                ns = max(ns, obj.elems{ielem}.GetNsol);
            end
        end 
                             
        function   H = GetH(obj)
            
            nelem = obj.GetNelems;
            %nS    = obj.GetNs;
            %nS    = obj.GetMaxConeS;
            %nGdl  = obj.GetNGdl;
            %nConx = obj.GetMaxConex;
           
            % Se cuentan los elementos  no nulos de H
            numnnH = 0;
            for ielem = 1 : nelem
                ns   = obj.elems{ielem}.GetNsAmp;
                iConex = obj.elems{ielem}.GetConex;
                iConeS = obj.elems{ielem}.GetConeS;
                for ins = 1 : ns
                    ngdl = obj.elems{ielem}.GetNGdl;
                    insG=iConeS(ins);
                    for igdl = 1 : ngdl
                        igdlG = iConex(igdl);
                        if igdlG > 0 && insG > 0
                            numnnH = numnnH+1;
                        end
                    end
                end
            end
 
            % allocale TODO las primeras podrían ser int16
            col=zeros(1, numnnH);
            fil=zeros(1, numnnH);
            Hij=zeros(1, numnnH);
            %H=spalloc(nGdl,nS,1);
            %insG=0;
            isparse=1;
            for ielem = 1 : nelem
                %fprintf('ensamblando elem%d en H(%d,%d)\n',ielem,nGdl,nS)
                iH = obj.elems{ielem}.GetH;
                
                % TODO TODO comprobar que estan definidas Conex y ConeS
                %iConex = obj.elems{ielem}.Conex;
                %iConex = reshape(iConex',1, size(iConex,1)*size(iConex,2));
                iConex = obj.elems{ielem}.GetConex;
                iConeS = obj.elems{ielem}.GetConeS;
                              
                ngdl = obj.elems{ielem}.GetNGdl;
                %ngdl = numel(obj.elems{ielem}.Conex);
                ns   = obj.elems{ielem}.GetNsAmp;
                
                %fprintf('   ns=%d, iConeS=\n',ns); %iConeS
                
                % TODO TODO, eso se puede hacer sin for, pero si algun dia
                % se quiere rescribir la funcion en otro lenguaje est
                for ins = 1 : ns
                    insG=iConeS(ins);
%fprintf('ins=%d/%d insG=%d\n',ins,ns,insG)
% if (ins>size(iH,2))
%     print ('ko,ko,ko');
% end    
                    for igdl = 1 : ngdl
                        igdlG = iConex(igdl);
                    
%  size(H)
%  size(iH)
                        if igdlG > 0 && insG > 0
                            %H(igdlG,insG) = H(igdlG, insG) + iH(igdl,ins);
                            fil(isparse)=igdlG;
                            col(isparse)=insG;
                            %xxx=iH(igdl, ins);
                            %Hij(isparse)=xxx;
                            % TODO TODO TODO TODO TODO TODO TODO TODO TODO
                            % Cuando se ensamblan las condiciones de
                            % resistencia la siguiente función es poco
                            % eficiente, pues iH puede ser una matriz
                            % sparse muy grande y 'ensamblarla' es muy
                            % costoso al ir haciéndolo elemento a elemento
                            % TODO TODO TODO TODO TODO TODO TODO TODO TODO
                            Hij(isparse) = iH(igdl, ins);
                            isparse=isparse+1;
                        end
                    end
                end
%                 % Se 'ensamablan' las reacciones
%                 if ~isempty(obj.elems{ielem}.ConeR)
%                     iConeR = obj.elems{ielem}.GetConeR;
%                     for igdl = 1 : ngdl
%                         inR=iConeR(igdl)
%                         igdlG = iConex(igdl);
%                         if igdlG > 0 && inR>0
%                             H(igdlG,inR) = H(igdlG, inR) + 1;
%                         end
%                     end
%                end
            end
            %obj.H = H;
            obj.H=sparse(fil,col,Hij);
            H=obj.H;
        end
     
        function   H = GetHULM(obj)
            %TODO TODO. Debería unificarse con GetH
            
            nelem = obj.GetNelems;
            nS    = obj.GetNs;
            nGdl  = obj.GetNGdl;
            nConx = obj.GetMaxConex;
           
            H=spalloc(nGdl,nS,1);
            insG=0;
            for ielem = 1 : nelem
                iH = obj.elems{ielem}.GetHULM;
                
                % TODO TODO comprobar que estan definidas Conex y ConeS
                iConex = obj.elems{ielem}.Conex;
                iConex = reshape(iConex',1, size(iConex,1)*size(iConex,2));
                iConeS = obj.elems{ielem}.ConeS;
                              
                ngdl = obj.elems{ielem}.GetNGdl;
                ns   = obj.elems{ielem}.GetNsAmp;
                
                %fprintf('ns del elemento=%d\n', ns)
                % TODO TODO, eso se puede hacer sin for, pero si algun dia
                % se quiere rescribir la funcion en otro lenguaje est
                for ins = 1 : ns
                    insG=iConeS(ins);
                    for igdl = 1 : ngdl
                        igdlG = iConex(igdl);
                        if igdlG > 0 && insG > 0
                            H(igdlG,insG) = H(igdlG, insG) + iH(igdl,ins);
                        end
                    end
                end
            end
            obj.H = H;
        end
        


        
        function       SetG(obj, iHip) %Peso propio (accion G)
            
            %wobinichTamino
            nelem = obj.GetNelems;
            
            for ielem = 1 : nelem
                %fprintf('ielem=%d de nelem=%d\n', ielem,nelem);
                %G = ArcoTSAM_f([obj.elems{ielem}.GetCdg ...
                %    0 obj.elems{ielem}.GetArea*elems{ielem}.rho 0]);
                %G = obj.elems{ielem}.GetG;
                %obj.elems{ielem}.addf(G,iHip)
                obj.elems{ielem}.SetG(iHip)
            end
        end
        
        function       SetGUNL(obj, iHip, rho)
            
            nelem = obj.GetNelems;
           
            for ielem = 1 : nelem
                %G = ArcoTSAM_f([obj.elems{ielem}.GetCdgULM ...
                %    0 obj.elems{ielem}.GetArea*rho 0]);
                G = obj.elems{ielem}.GetGULM;
                obj.elems{ielem}.addf(G,iHip)
            end
        end
                  
        function       SetQ(obj, iHip, ielem, f)
            Q = ArcoTSAM_f([obj.elems{ielem}.GetCdg, f]);
            obj.elems{ielem}.addf(Q,iHip);
        end
        
        function       SetQA(obj, iHip, ielem, aris, f)
            cdgAris=obj.elems{ielem}.GetCdgAris;
            Q = ArcoTSAM_f([cdgAris(aris,:), f]);
            obj.elems{ielem}.addf(Q,iHip);
        end
        
        function       SetQApml(obj, iHip, ielem, aris, f)
            
            cdgAris=obj.elems{ielem}.GetCdgAris;
            LAris=obj.elems{ielem}.GetLAris;
            Q = ArcoTSAM_f([cdgAris(aris,:), LAris(aris)*f]);
            obj.elems{ielem}.addf(Q,iHip);
        end

        
        function       delHipts(obj, varargin)
            nelem = obj.GetNelems;
            iHip=chkIndex(obj.GetNHipts,varargin{:});
            
            if iHip
                for ielem = 1 : nelem
                    obj.elems{ielem}.delHipts(iHip)
                end
            end
        end
        
        function       clearHipts(obj)
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                obj.elems{ielem}.clearHipts;
            end
        end
        
        function       clearSol(obj)
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                obj.elems{ielem}.clearSol;
            end
        end
             
        function   f = Getf(obj, varargin)
            nelem = obj.GetNelems;
            iHip=chkIndex(obj.GetNHipts, varargin{:});
            %nconx = obj.GetMaxConex;
            
            f = zeros(obj.GetNGdl,1);
            for ielem = 1 : nelem
                if (obj.elems{ielem}.GetNHipts >= iHip)
                    % Los tres primeros elementos de la ultima fila de
                    % Conex son los GDL del solido
                    %f(obj.elems{ielem}.Conex(end,1:3)) = ...
                    ind=obj.elems{ielem}.GetConexf;
                    val=obj.elems{ielem}.Getf(iHip);
                    f(ind(ind>0))=val(ind>0);
                    %f(obj.elems{ielem}.GetConexf) = ...
                    %    obj.elems{ielem}.Getf(iHip);
                        %obj.elems{ielem}.Hipts{iHip}.GetComp;
                end
            end
        end
  
        function insG=SetConeS(obj, varargin)
            % No asigna las 'reacciones/ligaduras'
            
            nelem = obj.GetNelems;
            
            insG=chkArg(0, varargin{:});
            for ielem = 1 : nelem
                % ns    = obj.elems{ielem}.GetNs;
                % obj.elems{ielem}.ConeS = [insG+1:insG+ns];
                % insG=insG+ns;
                insG = obj.elems{ielem}.SetConeS(insG);
                % obj.elems{1}.elems{3}.ConeS
                % obj.elems{2}.elems{1}.ConeS
                % obj.elems{3}.ConeS
            end
        end
                        
        function   c = GetConeS(obj)
            nS    = obj.GetNs;
            %c = 1: nS;
            %          c = [];
            %          for i = 1: obj.GetNelems
            %              c =  [c, obj.elems{i}.GetConeS];
            %          end
            c=zeros(1,nS);
            for i = 1: obj.GetNelems
                %fprintf('nelem=%d, i=%d\n', obj.GetNelems,i)
                ic=obj.elems{i}.GetConeS;
                c(ic(ic~=0))=ic(ic~=0);
            end
        end
        
        function   l = GetConeSl(obj)
            l =  obj.GetConeS~=0;
        end
                   
        function  na = GetConeSNAl(obj)  
            % Componentes de s no acotadas (normalmente los cortantes)
            % (LOGICAL)
            nelem = obj.GetNelems;
            nS    = obj.GetNs;
            
            na=zeros(nS,1)==0;
            for ielem = 1 : nelem
                iSNA = obj.elems{ielem}.GetConeSNAl;
                %iconeS = obj.elems{ielem}.ConeS;
                %na(iconeS(iconeS~=0)) = iSNA(iconeS~=0);
                iconeS = obj.elems{ielem}.GetConeS;
                iconeSl = obj.elems{ielem}.GetConeSl;
                %xxx=iconeSl~=0
                na(iconeS(iconeSl~=0)) = iSNA(iconeSl);
            end 
            
            % Intento fallido para que funcione de forma recursiva 
            %nelem = obj.GetNelems;
            %
            %na=logical([]);
            %for ielem = 1 : nelem
            %    na = [na, obj.elems{ielem}.GetConeSNAl];
            %end
        end
                   
        function  na = GetConeSNA(obj)  
            % Componentes de s no acotadas (normalmente los cortantes)
            cones = obj.GetConeS;
            conesNAl = obj.GetConeSNAl;
            na = cones(conesNAl);
            na= na(na~=0);
        end
                   
        function  np = GetConeSNPl(obj)  
            % Componentes de s no positivas (normalmente los axiles)
            % (LOGICAL)
            nelem = obj.GetNelems;
            nS    = obj.GetNs;
            
            np=zeros(1,nS)==0;
            for ielem = 1 : nelem
                %fprintf('--------------------------------------ielem=%d de %d\n',ielem, nelem);
                iconesNP = obj.elems{ielem}.GetConeSNPl;
                %iconeS = obj.elems{ielem}.ConeS;
                %np(iconeS(iconeS~=0)) = iconesNP(iconeS~=0);
                iconeS = obj.elems{ielem}.GetConeS;
                iconeSl = obj.elems{ielem}.GetConeSl;
                %fprintf('-------ielem=%d de %d\n',ielem, nelem);
                %iconeSl
                %iconesNP
                %%np
                %iconeS
                %iconeS~=0
                %iconeS(iconeS~=0)
                %fprintf('...\n');
                %iconesNP(iconeSl)
                %np(iconeS(iconeS~=0))
                %fprintf('------- Fin\n');
                np(iconeS(iconeS~=0)) = iconesNP(iconeSl);
            end 
            % Intento fallido de funcionamiento recursivo
            %            nelem = obj.GetNelems;
            %
            %np=logical([]);
            %for ielem = 1 : nelem
            %    np = [np, obj.elems{ielem}.GetConeSNPl];
            %end
        end
                   
        function  na = GetConeSNP(obj)  
            % Componentes de s no positivas (normalmente los axiles)
            cones = obj.GetConeS;
            conesNPl = obj.GetConeSNPl;
            na = cones(conesNPl);
            na=na(na~=0);
        end
        
        function       addu(obj, vectU, isol, varargin)
            obj.SetVectU(vectU,isol);
        end
        
        function addUyReacc(obj, varargin)
            % No hay nada que hacer. Al hacer SetVecU se llama a esta
            % función para los objetos 'de niveles inferiores' los RB, 
            % por lo que cuando se llega a este nivel ya no queda nada por 
            % hacer
        end
        
        function xuy = GetVectUy(obj,varargin)
            iSol=chkIndex(obj.GetNsol,varargin{:}); 
            nelem = obj.GetNelems;
            xuy=[];
            for ielem = 1 : nelem
                %ixuy=(obj.elems{ielem}.GetVectUy);
                %fprintf('Modelo.GetVectUy nsol=%d\n',iSol);
                ixuy=obj.elems{ielem}.GetVectUy(iSol);
                if not(isempty(ixuy))
                    xuy=[xuy; ixuy];
                end
            end
        end
        
        function       SetVectU(obj, vectU, varargin)
            
            iSol=chkIndexIn(obj.GetNsol,varargin{:});
            
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                obj.elems{ielem}.addu(vectU,iSol);
            end
            % Lo que sigue es para 2.5D
            % Al llegar a este punto se han addu a los distintos MRB que
            % definen la boveda y los MRBrst. En estos se han definido los
            % VectUy de las dovelas de las juntas
            % Ahora hay que 'ampliar' VectU con las componetes en la 
            % direccion perpendicular al plano
            % Es necesario un for dstinto para asegurar que ya se han
            % procesdo todos los VectU y VectUy
            for ielem = 1 : nelem
                obj.elems{ielem}.addUyReacc(iSol);
%201031                obj.elems{ielem}.GetVectUy(iSol);
                %obj.elems{ielem}.SetUy(obj.GetVectUy);
                %obj.elems{ielem}.uyInterp1(isol,xu);
            end
            
%            for ielem = 1 : nelem
%                obj.elems{ielem}.SetUy(obj.GetVectUy);
%            end
        end
        
        function       OldSetVectU(obj, vectU, varargin)
            
%             if nargin == 2
%                 nsol=[]; % Se añade la solucion a continuacion de la ultima
%             else
%                 nsol=nSol;
%             end
            iSol=chkIndexIn(obj.GetNsol,varargin{:});
            
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                % Por alguna razón misteriosa en octave hay que definir la
                % variable 'u' y pasarla despues a la funccion addu
                u=vectU(obj.elems{ielem}.Conex(end,1:3));
                obj.elems{ielem}.addu(u,iSol);
            end
        end
        
        function   u = GetVectU(obj, varargin)
            % Esta funcion solo se usa para sacar resultados, para operar
            % debe usarse GetVectUAmp que devuelve las componetes de u
            % ordenadas segun la matriz de conexiones
            
            iSol=chkIndex(obj.GetNsol,varargin{:});
            
            %fprintf('GetVectU_new.iSol=%d\n',iSol);
            u=[];
            if iSol
                nelem = obj.GetNelems;
                for ielem = 1 : nelem
%                    u((ielem-1)*3+1:ielem*3)=obj.elems{ielem}.VectU{nsol};
                                                 
                    u=[u;obj.elems{ielem}.GetVectU(iSol)];
                end
%                u=u';
            end
        end
        
        function   u = GetVectUKO(obj, varargin)
            % Esta funcion solo se usa para sacar resultados, para operar
            % debe usarse GetVectUAmp que devuelve las componetes de u
            % ordenadas segun la matriz de conexiones
            
            nsol=chkIndex(obj.GetNsol,varargin{:});
            fprintf('GetVectU_original.iSol=%d\n',nsol);
            u=[];
            if nsol
                nelem = obj.GetNelems;
                for ielem = 1 : nelem
                    u((ielem-1)*3+1:ielem*3)=obj.elems{ielem}.VectU{nsol};
%                    u=[u;obj.elems{ielem}.GetVectU(nsol)];
                end
                u=u';
            end
        end
     
        function   u = GetVectUAmp(obj, varargin)
            
            iSol=chkIndex(obj.GetNsol,varargin{:});
            
            if iSol
                nelem = obj.GetNelems;
                for ielem = 1 : nelem
                    %TODO TODO utilizar elems{ielem}.GetUAmp
                    iu = cat(1,obj.elems{ielem}.MatJU{iSol}, ...
                             obj.elems{ielem}.VectU{iSol}');
                    ic = obj.elems{ielem}.Conex;
                    icl= ic>0;
                    u(ic(icl))=iu(icl);

                    %u((ielem-1)*3+1:ielem*3)=obj.elems{ielem}.VectU{iSol};
                end
                u=u';
            end
        end
           
        function       adds(obj,vectS, varargin)
            obj.SetVectS(vectS, varargin{:});  
        end
        
        function       Old_SetVectS(obj, vectS, varargin)
%             if nargin == 2
%                 nsol=[]; % Se añade la solucion en la pos. de la ultima u
%             else
%                 nsol=nSol;
%             end

            % Si se ha incluido previamente VectU, VectS se colocara una
            % posicion 'mas a la derecha', pues GetNsol se calcula a partir
            % de VectU
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            
            
            % Debe haberse definido previamente ConeS
            % Falta try
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                
               %cs=obj.elems{ielem}.ConeS;
               %obj.elems{ielem}.adds(vectS(cs(cs~=0)),nsol);
               cs=obj.elems{ielem}.GetConeS;
               ivectS=[];
               ivectS(cs~=0)=vectS(cs(cs~=0));
               obj.elems{ielem}.adds(ivectS',nsol);
               %obj.elems{ielem}.adds(vectS(cs),nsol);
            end
        end
        
        function       SetVectS(obj, vectS, varargin)

            % Si se ha incluido previamente VectU, VectS se colocara una
            % posicion 'mas a la derecha', pues GetNsol se calcula a partir
            % de VectU
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            
            
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                
               % %cs=obj.elems{ielem}.ConeS;
               % %obj.elems{ielem}.adds(vectS(cs(cs~=0)),nsol);
               % cs=obj.elems{ielem}.GetConeS;
               % ivectS=[];
               % ivectS(cs~=0)=vectS(cs(cs~=0));
               % obj.elems{ielem}.adds(ivectS',nsol);
               % %obj.elems{ielem}.adds(vectS(cs),nsol);
               obj.elems{ielem}.adds(vectS,nsol);
            end
        end
        

       
        function       OldSetVectE(obj, vectE, varargin)
            
%             if nargin == 2
%                 nsol=[]; % Se añade la solucion en la pos. de la ultima u 
%             else
%                 nsol=nSol;
%             end
            % Si se ha incluido previamente VectU, VectS se colocara una
            % posicion 'mas a la derecha', pues GetNsol se calcula a partir
            % de VectU
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            
            % Debe haberse definido previamente ConeS
            % Falta try
            nelem = obj.GetNelems;
            for ielem = 1 : nelem 
                %cs=obj.elems{ielem}.ConeS;
                %obj.elems{ielem}.adde(vectE(cs(cs~=0)),nsol);
                cs=obj.elems{ielem}.GetConeS;
                obj.elems{ielem}.adde(vectE(cs),nsol);
            end
        end
        
        function       adde(obj, vectE, nsol, varargin)
            obj.SetVectE(vectE,nsol,varargin{:})
        end
        
        function       SetVectE(obj, vectE, varargin)
            
%             if nargin == 2
%                 nsol=[]; % Se añade la solucion en la pos. de la ultima u 
%             else
%                 nsol=nSol;
%             end
            % Si se ha incluido previamente VectU, VectS se colocara una
            % posicion 'mas a la derecha', pues GetNsol se calcula a partir
            % de VectU
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            
            % Debe haberse definido previamente ConeS
            % Falta try
            nelem = obj.GetNelems;
            for ielem = 1 : nelem 
                %fprintf('adde  ielem=%d de %d\n', ielem, nelem);
                %cs=obj.elems{ielem}.ConeS;
                %obj.elems{ielem}.adde(vectE(cs(cs~=0)),nsol);
                %cs=obj.elems{ielem}.GetConeS;
                obj.elems{ielem}.adde(vectE,nsol);
            end
        end
        
        function   e = GetVectE(obj, varargin)
            
            nsol=chkIndex(obj.GetNsol,varargin{:});
            
            if nsol
                e=[];
                nelem = obj.GetNelems;
                for ielem = 1 : nelem 
                    %cs=obj.elems{ielem}.ConeS;
                    %e(cs(cs~=0))=obj.elems{ielem}.VectE{nsol};
                    cs=obj.elems{ielem}.GetConeS;
                    e(cs)=obj.elems{ielem}.VectE{nsol};
                end
                e=e';
            end
        end
                   
        function   e = GetVectEULM(obj, varargin)
            % Comun para LM y pequeños movimientos
            % TODO TODO
            % Hay que intentar la funcion sin necesidad de definir iSol, 
            % GetEULM debe devolver [] en caso de que iSol no este
            % definido...
            
            iSol=chkIndex(obj.GetNsol,varargin{2:end});
            
            if iSol
                e=[];
                nelem = obj.GetNelems;
                for ielem = 1 : nelem
                    %aux=obj.elems{ielem}.GetELM(iSol);
                    aux=obj.elems{ielem}.GetEULM(varargin{:});
                    aux=reshape(aux',size(aux,1)*size(aux,2),1);
                    e(end+1:end+size(aux,1)) = aux;
                end
                e=e';
            end
        end        
        
        function   e = GetVectEBu(obj, varargin)
            iSol=chkIndex(obj.GetNsol,varargin{2:end});
            %[isLM, iSol, scal] = obj.GetParamULM(varargin{:})
            
            if iSol
                e=[];
                nelem = obj.GetNelems;
                for ielem = 1 : nelem
                    %aux=obj.elems{ielem}.GetELM(iSol);
                    aux=obj.elems{ielem}.GetEBu(varargin{:});
                    e(end+1:end+size(aux,1)) = aux;
                end
                e=e';
            end
        end
        
        function   e = KO_GetVectEm(obj, varargin)
            % Calculo 'manual' del vector e. 
            % Se utiliza como 'plantilla'
            % para escribir GetVectENL en ArcoTSAM_ModeloNL
            % Las dos funciones son my parecidas y sería muy sencillo
            % unificarlas.
            section('GetVectEm obsoleto: sustituir por GetVectEULM(false,isol)')
            section('GetVectEm obsoleto: sustituir por GetVectEULM(false,isol)')
            section('GetVectEm obsoleto: sustituir por GetVectEULM(false,isol)')
            wobinichTamino
            % Para el calculo tiene que haberse introducido u. 
            nsol=chkIndex(obj.GetNsol,varargin{:});
            
            if nsol
                e=[];
                nelem = obj.GetNelems;
                for ielem = 1 : nelem
                    aux=obj.elems{ielem}.GetE(nsol);
                    aux=reshape(aux',size(aux,1)*size(aux,2),1);
                    %e(end+1:end+size(aux,1)) = aux;
                    e(obj.elems{ielem}.ConeS) = aux;
                end
                e=e';
            end
        end   
               
        function   e = KO_GetVectEm_1(obj, varargin)
            % Calculo 'manual' del vector e. 
            % Se utiliza como 'plantilla'
            % para escribir GetVectENL en ArcoTSAM_ModeloNL
            % Las dos funciones son my parecidas y sería muy sencillo
            % unificarlas.
section('GetVectEm_1 obsoleto: sustituir por ¿¿¿¿GetVectEULM????')
            % Para el calculo tiene que haberse introducido u. 
            iSol=chkIndex(obj.GetNsol,varargin{:});
            
            if iSol
                e=[];
                nelem = obj.GetNelems;
                for ielem = 1 : nelem
                    %aux=obj.elems{ielem}.GetELM_1(iSol, false);
                    
                    aux=obj.elems{ielem}.GetELM_1(true, iSol);
                    %aux1=obj.elems{ielem}.GetEULM(true, iSol,1, iSol-1)
                    disp('-----^^^^^^^^^^^^')
                    aux=reshape(aux',size(aux,1)*size(aux,2),1);
                    %e(end+1:end+size(aux,1)) = aux;
                    e(obj.elems{ielem}.ConeS) = aux;
                end
                e=e';
            end
        end   
              
        function       old_SetMatJU(obj, vectU, varargin)
            
%             if nargin == 2
%                 nsol=[]; % Se añade la solucion en la pos. de la ultima u 
%             else
%                 nsol=nSol;
%             end
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                conex = obj.elems{ielem}.Conex; 
                 %   conex = obj.elems{ielem}.GetConex; 
                %[ni nj] = size(conex);
                ni = obj.elems{ielem}.GetNJuntas;
                nj = obj.elems{ielem}.nGdlxJ;
                %TODO TODO: se puede hacer sin for
                for i=1:ni
                    for j=1:nj
                        if conex(i, j) == 0
                            u(i,j) = 0;
                        else                   
                            u(i,j) = vectU(conex(i,j));
                        end
                    end
                end
                obj.elems{ielem}.old_addju(u,nsol);
            end
        end 
        
        function       SetMatJU(obj, vectU, varargin)
            
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            
            nelem = obj.GetNelems;
            for ielem = 1 : nelem;
                obj.elems{ielem}.addju(vectU,nsol);
            end
        end
        
        function addju(obj, vectU, nsol, varargin)
            obj.SetMatJU(vectU,nsol);
        end
        
        function updateGeome(obj,ihip)
            obj.H=[];
            for ielem = 1 : numel(obj.elems)     
                obj.elems{ielem}.updateGeome(obj.elems{ielem}.VectU{ihip});
            end
        end
        
        %% LP
        function   c = GetCFoHdir(obj, elem, ijunt, alpha)
            % vector c de la funcion objetivo, fo=ct*s, cuando se calcula 
            % el empuje en la direccion d (h_d segun notacion de articulo, 
            % aqui sustituido por h_dir para evitar confusión con 'de 
            % calculo'.  fo=hdir; hdir=ct*s           
            
            %elem=obj.elems{ielem};
            % TODO-> sparse
            coneSApoyo=elem.GetConeSjunta(ijunt);
            sdir = elem.GetSdir(ijunt, alpha);                  
            
            c = zeros(obj.GetNs,1);
            c(coneSApoyo) = sdir; 
        end
        
        % TODO TODO: Es posible que no se utilice       
        function   c = KO_GetCFoHdirULM(obj, ielem, ijunt, alpha, varargin)
            % vector c de la funcion objetivo, fo=ct*s, cuando se calcula 
            % el empuje en la direccion d (h_d segun notacion de articulo, 
            % aqui sustituido por h_dir para evitar confusión con 'de 
            % calculo'.  fo=hdir; hdir=ct*s           
            
            elem=obj.elems{ielem};
            coneSApoyo=elem.GetConeSjunta(ijunt);
            sdir = elem.GetSdirULM(ijunt, alpha, varargin{:});                  
            
            c = zeros(obj.GetNs,1);
            c(coneSApoyo) = sdir; 
        end
        
        function hdm = GethdirMinLPP(obj, ielem, ijunt, alpha, gammau, ...
                varargin)
            % Calculo del empuje minimo en la direccion d (h_d segun la
            % notacion articulo).
            
            if size(obj.H)==[0 0]
                obj.GetH;
            end
            % TODO TODO, si se pasa el numero de la hotesis ya calculada G,
            % se podría omitir aquí el cálculo de G. Podría definirse una 
            % propiedad (nHipG)que indicase cual es esta hipotesis, 
            % asignarse en la funcion SetG y hacer lo mismo que con H.  
            nHipG=obj.GetNHipts + 1;     
            obj.SetG(nHipG);
            
            % Ver comentario de LPD
            if nargin == 5 || isempty(varargin) || isempty(varargin{1})
                nHipG=obj.GetNHipts + 1;
                obj.SetG(nHipG);
                f = obj.Getf(nHipG);
            else
                f = 0;
            end
            f = chkArg(f, varargin{:});           
            c = gammau*chkArg(obj.GetCFoHdir(ielem, ijunt, alpha), ...
                varargin{2:end});
            %f = obj.Getf(nHipG);
            %c = gammau*obj.GetCFoHdir(ielem, ijunt, alpha);
            
            if(amImatlab)
                %TODO TODO pasar parametros a la funcion
                alg='interior-point-legacy';
                options = optimoptions('linprog','Algorithm',alg, ...
                    'Display', 'iter', 'MaxIterations', 1000);
                options = optimoptions('linprog','Algorithm','dual-simplex');
                [ss, fo, status, extra, lambda ] = linprog( ...
                    c, ...
                    [],[], ...
                    obj.H, -f, ...
                    obj.GetLb, ...
                    obj.GetUb, options);
            else
                % TODO TODO pasar parametros a la funcion
                % lpsolver=1 parece que converge al máximo, no al mínimo.
                % Alucina, vecina.
                param.lpsolver=2;
                param.msglev=0;
                [ss, fo, status, extra ] = glpk( ...
                    c, ...
                    obj.H, -f, ...
                    obj.GetLb, ...
                    obj.GetUb, ...
                    [],[],1,param);
            end
            if(amImatlab)
                e=lambda.lower+lambda.upper;
                u=lambda.eqlin;
            else
                e=-extra.redcosts;
                u=-extra.lambda;
            end
            
             % El último en actualizarse debe ser VectU, pues de otro modo
             % GetNsol (que se calcula a partir de VectU) aumenta y VectS, 
             % MatJU se añadirian en una columna diferente a la de VectU
            obj.SetVectS(ss);
            obj.SetMatJU(u);
            obj.SetVectE(e);
            obj.SetVectU(u);
            
            hdm=fo;
            %TODO TODO borrar la hipotesis de carga que se ha generado
            
        end  
        
        function gammaf = GetMaxGammaLPP(obj, vectQ, varargin)
            % Ver GetMaxGammaLPD
            if size(obj.H)==[0 0]
                obj.GetH;
            end
            conesN = obj.GetConeSNP;
            conesV = obj.GetConeSNA;
            %H_N=B(:,conesN);
            %H_V=B(:,conesV);
            %% Posible parametro opcional vectG
            if nargin == 2 || isempty(varargin) || isempty(varargin{1})
                nHipG=obj.GetNHipts + 1;
                obj.SetG(nHipG);
                vectG = obj.Getf(nHipG);
            else
                vectG = 0;
            end
            vectG = chkArg(vectG, varargin{:});
            %%
            c = chkArg([zeros(obj.GetNs,1); 1], varargin{2:end});
            %c_N = c(conesN);
            %c_V = [c(conesV); c(end)];
            %% LP
            if(amImatlab)
                %TODO TODO pasar parametros a la funcion
                alg='interior-point-legacy';
                options = optimoptions('linprog','Algorithm',alg, ...
                    'Display', 'iter', 'MaxIterations', 1000);
                options = optimoptions('linprog','Algorithm','dual-simplex', ...
                    'Display', 'none');

                [ss, gammaf, status, extra, lambda ] = linprog( ...
                    -c, ...
                    [], [], ...
                    cat (2, obj.H, vectQ) , -vectG, ...
                    [obj.GetLb; -Inf], ...
                    [obj.GetUb; Inf], options);
            else
                param.lpsolver=2;
                param.msglev=0;
                [ss, gammaf, status, extra ] = glpk( ...
                    -c, ...
                    cat (2, obj.H, vectQ), -vectG, ...
                    [obj.GetLb; -Inf], ...
                    [obj.GetUb; Inf], ...
                    [],[],1,param);
            end
            gammaf=-gammaf;
            if(amImatlab)
                e=lambda.lower+lambda.upper;
                u=lambda.eqlin;
            else
                e=-extra.redcosts;
                u=-extra.lambda;
            end
            
             % El último en actualizarse debe ser VectU, pues de otro modo
             % GetNsol (que se calcula a partir de VectU) aumenta y VectS, 
             % MatJU se añadirian en una columna diferente a la de VectU
            obj.SetVectS(ss);
            obj.SetMatJU(u);
            obj.SetVectE(e);
            obj.SetVectU(u);

            
        end
        function gammaf = GetMaxGammaLPD(obj, vectQ, varargin)
            % Calculo del maximo factor de carga. Formulacion dual 
            % notacion articulo).
            % wobinichTamino;
            
            if size(obj.H)==[0 0]
                obj.GetH;
            end
            B=obj.H';
            
            conesN = obj.GetConeSNP;
            conesV = obj.GetConeSNA;
            B_N=B(conesN,:);
            B_V=B(conesV,:);
            
            % Si se pasa un parametro opcional se cambia vectG por
            % dicho parametro. El procedimiento es un poco burdo porque
            % en cualquier caso se calcula vectG, pero como no son
            % procedimientos costosos se prima sencillez de programacion
            % frente a eficiencia. Analogamente para el vector c que define
            % la funcion objetivo (si se pasa un segundo parametro opcional
            % se sustituye por dicho valor)
            % El if siguiente mejora algo el problema anterior
            if nargin == 2 || isempty(varargin) || isempty(varargin{1})
                nHipG=obj.GetNHipts + 1;
                obj.SetG(nHipG);
                vectG = obj.Getf(nHipG);
            else
                vectG = 0;
            end
            vectG = chkArg(vectG, varargin{:});
            % c = [0...0,1]. El ultimo termino multiplica a gamma en el 
            % primal. Como gamma no esta a cotado se agrupa con c_V a
            % continuacion
            c = chkArg([zeros(obj.GetNs,1); 1], varargin{2:end});
            c_N = c(conesN);
            c_V = [c(conesV); c(end)];
            
            
            if(amImatlab)
                %TODO TODO pasar parametros a la funcion
                alg='interior-point-legacy';
                options = optimoptions('linprog','Algorithm',alg, ...
                    'Display', 'iter', 'MaxIterations', 1000);
                options = optimoptions('linprog','Algorithm','dual-simplex', ...
                    'Display', 'none');
                % Sobre los signos
                % En el primal H*s+vectQ*Gamma =-vectG, luego, el vector de
                % coeficientes de la F.O. aquí sera -vectG, y  habra
                % que max(-vectGt*u), como matlab calcula min se cambia el
                % signo de vectGt. Si se hace el cambio de variable 
                % gamma=-Gamma se escribe H*s-vectQ*gamma=-vectG, en el
                % primal min(gamma*s) = max(-gamma*s)= max(Gamma*s) y el
                % valor de la F.O. que se obtiene es el buscado (es decir,
                % no hay que cambiar el signo de F.O).
                %
                % Segun el articulo B_n>c_n, pero como
                % matlab trata B_N<c_N, se cambia el signo de B_N y c_N.
                [u, gammaf, status, extra, lambda ] = linprog( ...
                    vectG, ...
                    -B_N, -c_N, ...
                    cat (1, B_V, -vectQ') , c_V, ...
                    [], ...
                    [], options);
            else
                %TODO TODO pasar parametros a la funcion
                param.lpsolver=2;
                param.msglev=0;
                ctype=83*ones(1,obj.GetNs);  % char(83)=S => Bu=c
                ctype(conesN)=76*ones(1,size(conesN,2));  %char(85)=L Bu>c
                %ctype(conesN)=85*ones(1,size(conesN,2)) %char(85)=U Bu<c
                ctype=char(ctype);
                %Se añade la condicion asociada a gamma (normalizacion)
                ctype(end+1)='S';
                LB = -Inf*ones(obj.GetNGdl,1);
                [u, gammaf, status, extra ] = glpk( ...
                    vectG, ...
                    cat(1, B, -vectQ'), c, ...
                    LB, ...
                    [], ...
                    ctype,[],1,param);
            end
            %fo = -fo;
            if(amImatlab)
                % Se prescinde de la ultima componente de eqlin: es gammaf
                ss(conesV)=lambda.eqlin(1:end-1);
                ss(conesN)=-lambda.ineqlin;
                ss=ss';
            else
                %e=-extra.redcosts;
                %u=-extra.lambda;
                % Se prescinde de la ultima componente de eqlin: es gammaf
                ss=-extra.lambda(1:end-1);
            end
            
            % El último en actualizarse debe ser VectU, pues de otro modo
            % GetNsol (que se calcula a partir de VectU) aumenta y VectS,
            % MatJU se añadirian en una columna diferente a la de VectU
            obj.SetVectS(ss);
            % Se calcula 'manualmente' el vector e
            % e = obj.GetVectEm;
            % e = obj.H'*u;
            % disp '-------------ArcoTsam_Modelo.GethdirMinLPD, e, Ht*u, e-Ht*u--------'
            % cat(2,e,obj.H'*u, e-obj.H'*u)
            % obj.SetVectE(obj.H'*u, obj.GetNsol);
            obj.SetVectE(obj.H'*u);
            obj.SetMatJU(-u);
            obj.SetVectU(-u);
            
            %hdm=fo;
            %TODO TODO borrar la hipotesis de carga que se ha generado
            
            %chequeo (solo para fase de depuracion, despues comentar)
            %aux=obj.H*ss+f;
            %cat(2, obj.H*ss, f)
            %chk(abs(sum(sum(aux)))<0.00001, 'chkEQU en ArcoTSAM_Modelo.GethdirMinLPD'); 
        end
    
        function hdm = GethdirMinLPD(obj, ielem, ijunt, alpha, gammau, ...
                varargin)
            % Calculo del empuje minimo en la direccion d (h_d segun la
            % notacion articulo).
            % wobinichTamino;
            
            if size(obj.H)==[0 0]
                obj.GetH;
            end
            B=obj.H';
            
            conesN = obj.GetConeSNP;
            conesV = obj.GetConeSNA;
            B_N=B(conesN,:);
            B_V=B(conesV,:);
            
            %             % TODO TODO, si se pasa el numero de la hotesis ya calculada G,
            %             % se podría omitir aquí el cálculo de G. Podría definirse una
            %             % propiedad (nHipG)que indicase cual es esta hipotesis,
            %             % asignarse en la funcion SetG y hacer lo mismo que con H.
            %             nHipG=obj.GetNHipts + 1;
            %             rho=1; %TODO TODO, pasar el valor de rho a la funcion
            %             obj.SetG(nHipG,rho);
            %             f = obj.Getf(nHipG);
            
            % Si se pasan parametros opcionales f y c se sustituyen por
            % dichos parametros. El procedimiento es un poco burdo porque
            % en ambos casos se calcula f y c, pero como no son
            % procedimientos costosos se prima sencillez de programacion
            % frente a eficiencia.
            % El if siguiente mejora algo el problema anterior
            if nargin == 5 || isempty(varargin) || isempty(varargin{1})
                nHipG=obj.GetNHipts + 1;
                obj.SetG(nHipG);
                f = obj.Getf(nHipG);
            else
                f = 0;
            end
            f = chkArg(f, varargin{:});
%fprintf ('ArcoTSAM_Modelo.GethdirMinLPD f(8)=%f',f(8));            
            c = gammau*chkArg(obj.GetCFoHdir(ielem, ijunt, alpha), ...
                varargin{2:end});
            % wobinichTamino
%             c'
%             f'
%             size(obj.H)
%             sum(sum(obj.H))
%            obj.H
            c_N = c(conesN);
            c_V = c(conesV);
            
            if(amImatlab)
                %TODO TODO pasar parametros a la funcion
                alg='interior-point-legacy';
                options = optimoptions('linprog','Algorithm',alg, ...
                    'Display', 'iter', 'MaxIterations', 1000);
                options = optimoptions(@linprog,'Algorithm','dual-simplex', 'Display', 'none');
                % Sobre los signos@
                % En el primal H*s=-f, luego aqui, el vector de
                % coeficientes de la funcion objetivo seria -f, y  habria
                % max (-ft*u), como matlab calcula min habra que cambiar
                % el signo de ft. Según el articulo B_n>c_n, pero como
                % matlab trata B_N<c_N, se cambia el signo de B_N y c_N
                [u, fo, status, extra, lambda ] = linprog( ...
                    f, ...
                    -B_N, -c_N, ...
                    B_V, c_V, ...
                    [], ...
                    [], options);
            else
                %TODO TODO pasar parametros a la funcion
                %param.lpsolver=1;  %simplex
                param.lpsolver=2;  %interior point
                param.msglev=0;
                %param.lpsolver=1;
                ctype=83*ones(1,obj.GetNs);  % char(83)=S => Bu=c
                ctype(conesN)=76*ones(1,size(conesN,2));  %char(85)=L Bu>c
                %ctype(conesN)=85*ones(1,size(conesN,2)) %char(85)=U Bu<c
                ctype=char(ctype);
                LB = -Inf*ones(obj.GetNGdl,1);
                [u, fo, status, extra ] = glpk( ...
                    f, ...
                    B, c, ...
                    LB, ...
                    [], ...
                    ctype,[],1,param);
            end
            fo = -fo;
            if(amImatlab)
                ss(obj.GetConeSNA)=lambda.eqlin;
                ss(obj.GetConeSNP)=-lambda.ineqlin;
                ss=ss';
            else
                %e=-extra.redcosts;
                %u=-extra.lambda;
                ss=-extra.lambda;
            end
            
            % El último en actualizarse debe ser VectU, pues de otro modo
            % GetNsol (que se calcula a partir de VectU) aumenta y VectS,
            % MatJU se añadirian en una columna diferente a la de VectU
%u            
            obj.SetVectS(ss);
            obj.SetMatJU(-u);
            obj.SetVectU(-u);
            % Se calcula 'manualmente' el vector e
            % e = obj.GetVectEm;
            % e = obj.H'*u;
            % disp '-------------ArcoTsam_Modelo.GethdirMinLPD, e, Ht*u, e-Ht*u--------'
            % cat(2,e,obj.H'*u, e-obj.H'*u)
            obj.SetVectE(obj.H'*u, obj.GetNsol);
            
            hdm=fo;
            %TODO TODO borrar la hipotesis de carga que se ha generado
            
            %chequeo (solo para fase de depuracion, despues comentar)
            %aux=obj.H*ss+f;
            %cat(2, obj.H*ss, f)
            %chk(abs(sum(sum(aux)))<0.00001, 'chkEQU en ArcoTSAM_Modelo.GethdirMinLPD'); 
        end
  
        
        function   l = isEQU(obj, varargin)
            l=true;
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                laux=obj.elems{ielem}.isEQU(varargin{:});
                for il = 1 : size(laux,1)
                    l=l && laux(il);
                end
            end
        end
        
        function   l = isEQUi(obj, varargin)
            l=[];
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                l=cat(1,l,obj.elems{ielem}.isEQU(varargin{:})); 
            end
        end
        
        function fHs = chkEQU(obj,varargin)
            nelem = obj.GetNelems;
            fHs=[];
            for ielem = 1 : nelem
                fHs=cat(1,fHs,obj.elems{ielem}.chkEQU(varargin{:})); 
            end
            
        end
        
        function fHs = chkHEQU(obj,varargin)
            % chkEQU con la H 'actual'
            % TODO TODO ajustar varargin.
            % Actualmente sólo se comprueba la última iteración
            fHs = obj.H*obj.GetVectS()+obj.Getf;
        end 
        
        function   l = isHEQUi(obj,varargin)
            % isEQUH con la H 'actual'
            % TODO TODO ajustar varargin.
            % Actualmente sólo se comprueba la última iteración
            l = abs(obj.chkHEQU()) < obj.epsEQU;
        end
        
        function   l = isHEQU(obj,varargin)
            % isEQUH con la H 'actual'
            % TODO TODO ajustar varargin.
            % Actualmente sólo se comprueba la última iteración
            l=true;
            li=obj.isHEQUi();
            ns = size(li,1);
            for is = 1 : ns
                l=l && li(is);
            end
        end

                         
                 
         function  lb = GetLb(obj)
             
             nelem = obj.GetNelems;
             nS    = obj.GetNs;
             
             lb=zeros(nS,1);
             %insG=0;
             for ielem = 1 : nelem
                 ilb = obj.elems{ielem}.GetLb;
                 %iconeS = obj.elems{ielem}.ConeS;
                 %lb(iconeS(iconeS~=0)) = ilb(iconeS~=0);
                 iconeS = obj.elems{ielem}.GetConeS;
                 iconeSl =  obj.elems{ielem}.GetConeSl;
                 lb(iconeS(iconeSl~=0)) = ilb(iconeSl~=0);
                 %lb(iconeS) = ilb(iconeSl);
             end
         end
         
                 
        function  ub = GetUb(obj)  
            
            nelem = obj.GetNelems;
            nS    = obj.GetNs;
            
            ub=zeros(nS,1);
            %insG=0;
            for ielem = 1 : nelem
%                 if (strcmp(class(obj.elems{ielem}),'ArcoTSAM_Rst'))
%                     fprintf ('empiezan los problemas\n');
%                 end
                iub = obj.elems{ielem}.GetUb;
                %iconeS = obj.elems{ielem}.ConeS;
                %ub(iconeS(iconeS~=0)) = iub(iconeS~=0);
                iconeS = obj.elems{ielem}.GetConeS;
                iconeSl = obj.elems{ielem}.GetConeSl;
%  fprintf('ArcoTSAM_RBs.GetUb (%s-%s) obj(%s->%s)  iub(%d), iconeS(%d), iconeSl(%d) \n', ...
%               obj.name,obj.elems{ielem}.name, class(obj), class(obj.elems{ielem}), numel(iub), numel(iconeS),  numel(iconeSl));               
                %iconeSl
               
                %iconeS(iconeSl~=0)
                %ub(iconeS) = iub(iconeSl);
                ub(iconeS(iconeSl~=0)) = iub(iconeSl~=0);
            end 
        end
        
        
        %% TODO
        
        %function x=GetConeSjunta(obj, ijun)
        %    x=1;
        %end    
        %function x=GetSdir(obj, ijun, alpha)
        %    x=0;
        %end
         %% plots                
%         function   g = plot(obj)
%             nelem = obj.GetNelems;
%             for ielem = 1 : nelem
%                 g = obj.elems{ielem}.plot;
%             end     
%         end     
        
%         function   g = plotConex(obj)
%             nelem = obj.GetNelems;
%             for ielem = 1 : nelem
%                 g = obj.elems{ielem}.plotConex;
%             end     
%         end
        
%         function   g = plotuLM(obj, varargin)
%                  
%             scal = chkArg(1, varargin{3:end});
%             iSol = chkIndex(obj.GetNsol,varargin{2:end});
%             isLM   = chkArg(true, varargin{1:end});
%             
%             nelem = obj.GetNelems;
%             for ielem = 1 : nelem
%                 g = obj.elems{ielem}.plotu(isLM, iSol, scal);
%             end
%             
%         end  
                         
%         function   g = plotu(obj,  varargin)
%                          
%             % Lo que sigue, mas eficiente, no funciona en octave
%             % g = obj.plotuLM(false,varargin{2:end})
%             if ~isempty(varargin)
%                 varargin(1)=[];
%             end
%             g = obj.plotuLM(false,varargin{:});
%                         
%         end 
          
%         function   g = plotj(obj) 
%             hold on
%             nelem = obj.GetNelems;
%             for ielem = 1 : nelem
%                 g = obj.elems{ielem}.plotj;
%             end
%             
%         end
        
%         function   g = plotujLM(obj, varargin)
% 
%             %scal = chkArg(1, varargin{:});
%             %iSol = chkIndex(obj.GetNsol, varargin{2:end});
%             %LM   = chkArg(true, varargin{3:end});
%             
%             
%             nelem = obj.GetNelems;
%             for ielem = 1 : nelem
%                 g = obj.elems{ielem}.plotuj(varargin{:});
%             end
%             
%         end 
       
%         function   g = plotuj(obj, varargin)
% 
%             % Lo que sigue, mas eficiente, no funciona en octave
%             % g = obj.plotujLM(false, varargin{2:end});
%             if ~isempty(varargin)
%                 varargin(1)=[];
%             end
%             g = obj.plotujLM(false,varargin{:});
%             
%         end 
         
%         function   g = plotf(obj, varargin) 
%             hold on
%             
%             scal=chkArg(1, varargin{:});
%             iHip=chkArg(obj.GetNHipts, varargin{2:end});
%             
%             nelem = obj.GetNelems;
%             for ielem = 1 : nelem
%                 if (obj.elems{ielem}.GetNHipts >= iHip)
%                     g = obj.elems{ielem}.plotf(scal,iHip);
%                     %g = obj.elems{ielem}.Hipts{iHip}.plotR(scal);
%                 end
%             end
%             
%         end
        
%         function   g = plotRjULM(obj, varargin)
%             % Dibuja la posicion de la resultante de las fuerzas en cada
%             % junta
%             
%             scaf = chkArg(1, varargin{1:end});
%             isLM = chkArg(false, varargin{2:end});
%             iSol = chkIndex(obj.GetNsol, varargin{3:end});
%             scal = chkArg(1, varargin{4:end});
%             
%             for ielem = 1: obj.GetNelems
%                 %fprintf('junta %d\n',ijun)
%                 g=obj.elems{ielem}.plotRjULM(scaf, isLM, iSol, scal);
%             end
%         end
    end
    
end