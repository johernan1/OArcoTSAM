classdef ArcoTSAM_RB < handle
    %ArcoTSAM_RB Summary of this class goes here
    %   Detailed explanation goes here
    
    % TODO size->numel
    
    properties %(SetAccess = protected)
      name='';
      nGdlxJ = 0;  % Numero de Gdl por Junta
      nSxJ   = 0;  % Numero de eSfuerzos por Junta
      rho    = 25; % kN/m3
      b      = 0.4;% m
      
      % Geome - coordenadas de los vertices: [NumeroVertices x 2] double.
      % Coordenadas del iver: XY=Geome(iver,:);
      % XY es [1x2] double
      %
      % See also  plot, GetNVerti,  set.Geome,
      %     GetGeomeU (geometria deformada)
      Geome
      
      % Junta - Vertices de las juntas: [NumeroJuntas x 2] double. 
      % Vertices de la junta ijun: IJ=Junta(ijun,:)
      %
      % See also plotj, GetNJuntas, set.Junta, GeteVeNijuntaULM
      Junta
      
      % Conex - Gdl globales de las juntas y el RB
      % [NumeroJuntas+1 x 3] double.
      % Gdl de la iJunt: obj.Conex(ijun,:)
      % Gdl del solido: obj.Conex(NumeroJuntas+1,:)
      %
      % See also plotConex, GetMaxConex, MoveConex
      Conex 
      ConeS
      ConeR        % Reacciones y/o enlaces;
                   % TODO: ¿para los enlaces falta un factor?
                   % ConeR no se utiliza
      
      % Hipts - Hipotesis de carga del RB
      % [1 x numero de hipotesis] cell array.
      % Cada cell (obj.Hips{iHips}) es un objeto ArcoTSAM_fsis
      %     
      % See also  GetNHipts, plotf
      Hipts = {};  
       
      % VectU - Vectores u (soluciones) del RB
      % [1 x numero de soluciones] cell array. 
      % Cada cell (obj.VectU{iVectU}) en un [1 x 3] double
      % TODO: Seria mas coherente que fuese [3 x 1] double
      % See also  plotu, addu, delu, clearu
      VectU = {};
      
      % VectUy - Solo se utiliza en 2.5D
      % Abscisas y valores de uy (perp al plano) para interpolar
      % linealmente los valores de uy de todos los puntos de Geome.
      % No es necesario ordenar las abscisas
      % {[x1 uy1 ux1], [x2 uy2 ux2] ... }
      % Para cada hipótesis de carga se define el valor del desplazamiento
      % de una abscisa.
      % Solo tendrá componentes si alguna junta del elemento es un apoyo o
      % si el elemento forma parte de una restricción. En otro caso VectUy
      % esta vacio.
      % Esta propiedad podría definirse 'dinamicamente' con 
      % Class: dynamicprops, pero no está implementada en octave   
      VectUy = {}; % Solo se utiliza en 2.5D
      
      
      % MatJU - [1 x numero de soluciones] cell array.
      % Cada cell (obj.MatJU{iMatJU}) en un
      % [NumeroJuntas x 3] double
      % TODO: Seria mas coherente [3 x NumeroJuntas] double
      MatJU = {};
      
      % VectS - [1 x numero de soluciones] cell array.
      % Cada cell (obj.VectS{iVectS} en un [GetNs x 1] double.
      % GetNs depende de cada RB particular. Se determina en
      % los objetos que heredan ArcoTSAM_RB
      VectS = {};  
      
      % VectE - [1 x numero de soluciones] cell array.
      % Cada cell (obj.VectS{iVectE} en un [GetNs x 1] double.
      % GetNs depende de cada RB particular. Se determina en
      % los objetos que heredan ArcoTSAM_RB
      VectE = {};  
      epsEQU = 10^-6;
    end
      
    methods  
        
        function obj = set.Geome(obj, geome)
            if mod(size(geome,2),2)  ~= 0  
                error('set.Geome: El numero de componentes debe ser par')
            else
                obj.Geome = geome;
            end
        end
           
        function obj = set.Junta(obj, juntas)
            if max(max(juntas)) > obj.GetNVerti
                error('set.Junta: max(juntas) > obj.GetNVerti\n %f > %f .\n', ...
                    max(max(juntas)), obj.GetNVerti) 
            elseif mod(size(juntas,2),2)  ~= 0  
                error('set.Juntas: El numero de componetes debe ser par')
            else
                obj.Junta = juntas;
            end
        end
                   
        function obj = set.Conex(obj, conex)
                                                %+1 solido
            if sum(size(conex) ~= [obj.GetNJuntas+1 obj.nGdlxJ]) > 0  
                error('set.Conex: Wrong number of input arguments')
            end
            obj.Conex = conex;
        end
        
        function nsf = SetConeS(obj,ns0)
            nsf       = ns0+obj.GetNs;
            obj.ConeS = [ns0+1:nsf];
        end
        
        function       SetG(obj, iHip) %Peso propio (accion G)   
            G = obj.GetG; 
            obj.addf(G,iHip)   
        end
        
        function obj = set.ConeR(obj, coneR)
                                                %+1 solido
            if sum(size(coneR) ~= [obj.GetNJuntas+1 obj.nGdlxJ]) > 0  
                error('set.Conex: Wrong number of input arguments')
            else
                obj.ConeR = coneR;
            end
            
        end
        
        % matlab.mixin.Copyable no funciona en octave
        function newObj = copy(obj) 
            %wobinichTamino;
            newObj = eval(class(obj));
            % props = properties(obj); No implementado en octave
            % props = fieldnames(obj); Imprime un warnig en octave
            % Dependiendo del orden de props pueden aparecer errores con
            % los set.
            % En suma, que se escriben explicitamentelas props que se
            % copian
            props={'nGdlxJ', 'nSxJ', 'rho', 'b', 'Geome', 'Junta', ...
                'Conex', 'ConeS', 'ConeR', 'Hipts', 'VectU', 'MatJU', ...
                'VectS', 'VectE', 'epsEQU'};
            for iprop = 1 : numel(props)
                thisprop = props{iprop};
                thisprop_value = obj.(thisprop);
                if ~isempty(thisprop_value)
                    if strcmp(thisprop, 'Hipts')
                        for ihip = 1 : numel(thisprop_value)
                            newHip =  thisprop_value{ihip}.copy;
                            %newObj.addf(newHip,ihip)
                            newObj.Hipts{ihip}=newHip;
                        end
                    else
                        newObj.(thisprop)=thisprop_value;
                    end
                end
            end
        end
        
        function  nj = GetNJuntas(elem)
            nj = size(elem.Junta,1);
        end 
        
        function  nh = GetNHipts(elem)
            nh = size(elem.Hipts,2);
        end 
        
        function  ns = GetNsol(elem)
            % Numero de soluciones
            % Aunque cada elemento tiene varias propiedades que se refieren
            % a posibles soluciones del problema, se toma como propiedad
            % mas significativa el vectU para evaluar el número de
            % soluciones del elemento
            ns = size(elem.VectU,2);
        end 
        
        function  nv = GetNVerti(elem)
            nv = size(elem.Geome,1);
        end    
                  
        function   m = GetMaxConex(obj)
            m = max(max(obj.Conex));
        end
          
        function   m = GetMaxConeS(obj)
            m = max(max(obj.ConeS));
        end
        
        function   c = GetConex(obj)
            c = obj.Conex;
            c = reshape(c',1, size(c,1)*size(c,2));
        end;    
        
        function   c = GetConexf(obj)
            c = obj.Conex(end,1:3);
        end;
        
        function  ns = GetNsAmp(obj)
            ns = size(obj.ConeS,2);
            %ns = sum(obj.GetConeSl);
        end
          
%         function   m = GetMaxConeR(obj)
%             if isempty(obj.ConeR)
%                 m=0;
%             else
%                 m = max(max(obj.ConeR));
%             end
%         end
        
        function obj = MoveConex(obj, desp)
            % Se suma 'desp' a cada una de las RB.Conex
            
            % TODO: eliminar los for
            for j = 1 : size(obj.Conex,2)
                for i = 1 : size (obj.Conex,1)
                    if obj.Conex(i,j)~= 0
                        obj.Conex(i,j) = obj.Conex(i,j) + desp;
                    end
                end
            end
        end
        
        function   a = GetArea(obj)
            a = 0;
            nv =  obj.GetNVerti;
            for i = 3: nv
                d = cat(2, obj.Geome([1 i-1 i],:),  [1; 1; 1]);
                a = a - 1/2*det(d);
            end
        end
        
        function   f = Getf(obj,iHip)
            f = obj.Hipts{iHip}.GetComp;
        end
        
        function cdg = GetCdg(obj)
            
            %TODO TODO debarian unificarse esta funcion y GetCdgULM
            %            cdg = GetCdgULM(1,false)
            a = 0;
            cdg = [0 0];
            nv =  obj.GetNVerti;
            for i = 3: nv
                d = cat(2, obj.Geome([1 i-1 i],:),  [1; 1; 1]);
                ai = - 1/2*det(d);
                cdg = cdg + ai*sum( obj.Geome([1 i-1 i],:))/3;
                a = a + ai;
            end
            cdg = cdg /a;
        end
      
        function [isLM, iSol, scal] = GetParamULM(obj, varargin)
            % Faltan trys
            isLM = chkArg(true, varargin{1:end});
            iSol = chkIndex(obj.GetNsol,varargin{2:end});
            scal = chkArg(1, varargin{3:end});
        end
        
        function cdg = GetCdgULM(obj, varargin)
            
            [isLM, iSol, scal] = obj.GetParamULM(varargin{:});
            
            geome=obj.Geome;
            vectUSol=obj.VectU{iSol};
            
            geome=obj.GetGeomeU(geome, vectUSol, varargin{:});
            
            a = 0;
            cdg = [0 0];
            nv =  obj.GetNVerti;
            for i = 3: nv
                d = cat(2, geome([1 i-1 i],:),  [1; 1; 1]);
                ai = - 1/2*det(d);
                cdg = cdg + ai*sum( geome([1 i-1 i],:))/3;
                a = a + ai;
            end
            cdg = cdg /a;
        end
        
        function [eV,eN] = GeteVeNijuntaULM (obj, ijunta, varargin)
            % Versor normal y tangencial a la junta.
            %
            % Para calcular los de la geometría incial deben pasarse los
            % paremetros isLM = false y scal = 0, lo cual proporcionaría el
            % mismo resultado independientemente del valor de iSol.
            % Aunque es tentador pasar iSol = 0 esta opción
            % carece de sentido, pues GetParamULM se ha definido de manera
            % que se pueden definir indices negativos para iSol del modo 
            % habitual en distintos entornos de programacion (incluido
            % el indice 0, que hace refencia al último indice del vector)
            
            % wobinichTamino
	    
            [isLM, iSol, scal] = obj.GetParamULM(varargin{:});
            % 1 < iSol < GetNsol 
            
            if (isLM==false  && scal==0)
                geome = obj.Geome;
            else    
                geome = obj.GetGeomeU(obj.Geome,obj.VectU{iSol}, ...
                        varargin{:});
            end
            
            eV = diff(geome(obj.Junta(ijunta,:),:));
            mod= sqrt(eV(1)*eV(1)+eV(2)*eV(2));
            eV = eV/mod;
            eN = [-eV(2),eV(1)];
        end 
        
        function [eV,eN] = GeteVeNijunta(obj, ijunta)
            % versor normal y tangencial a la junta
            
            %eV = diff(obj.Geome(obj.Junta(ijunta,:),:));
            %mod= sqrt(eV(1)*eV(1)+eV(2)*eV(2));
            %eV = eV/mod;
            %eN = [-eV(2),eV(1)];
            section('GeteVeNijunta obsoleta: sustituir por GeteVeNijuntaULM(ijunta, false, 0, 0)')
            section('GeteVeNijunta obsoleta: sustituir por GeteVeNijuntaULM(ijunta, false, 0, 0)')
            section('GeteVeNijunta obsoleta: sustituir por GeteVeNijuntaULM(ijunta, false, 0, 0)')
            section('GeteVeNijunta obsoleta: sustituir por GeteVeNijuntaULM(ijunta, false, 0, 0)')
            wobinichTamino
            [eV,eN] = obj.GeteVeNijuntaULM(ijunta, false, 0, 0);
        end
       
        function [eV,eN] = GeteVeNijunta_1(obj, ijunta, varargin)
            % TODO TODO
            % Unificar esta y la anterior. 
            % versor normal y tangencial a la junta
            
            wobinichTamino
            section('obsoleto GeteVeNijunta_1: sustituir por GeteVeNijuntaULM(ijun, 1, isol, true')
            section('obsoleto GeteVeNijunta_1: sustituir por GeteVeNijuntaULM(ijun, 1, isol, true')
            section('obsoleto GeteVeNijunta_1: sustituir por GeteVeNijuntaULM(ijun, 1, isol, true')
            section('obsoleto GeteVeNijunta_1: sustituir por GeteVeNijuntaULM(ijun, 1, isol, true')
            iSol=chkIndex(obj.GetNsol,varargin{:});
            %obj.Geome(obj.Junta(ijunta,:),:)
            %geome = obj.GetGeomeU(obj.Geome,obj.VectU{iSol},1,0,true);
            geome = obj.GetGeomeU(obj.Geome,obj.VectU{iSol},true,0,1);
            %fprintf ('------ArcoTSAM_RB.GeteVeNijunta_1.GetGeomeU(vectU{isol})-------isol=%d, vectU=%f %f %f--------\n', iSol, obj.VectU{iSol})
            
            eV = diff(geome(obj.Junta(ijunta,:),:));
            mod= sqrt(eV(1)*eV(1)+eV(2)*eV(2));
            eV = eV/mod;
            eN = [-eV(2),eV(1)];
        end 
        
        function  na = GetConeSNAl(obj)
          % Componentes de s no acotadas (normalmente los cortantes)
          lb = obj.GetLb;
          ub = obj.GetUb;
          na = ub==Inf & lb==-Inf;
        end
        
        function  na = GetConeSNA(obj)
          % Componentes de s no acotadas (normalmente los cortantes)
          % na = obj.ConeS(obj.GetConeSNAl);
          
          na = obj.ConeS(obj.GetConeSNAl);
          na = na(na~=0);
        end     
        
        function  np = GetConeSNPl(obj)
          % Componentes de s no positivas (normalmente los axiles)
          lb = obj.GetLb;
          ub = obj.GetUb;
          np = ub==0 & lb==-Inf;
        end  
        
        function  np = GetConeSNP(obj)
          % Componentes de s no positivas (normalmente los axiles)
          np = obj.ConeS(obj.GetConeSNPl);
        end
        
        function   c = GetConeSjunta(obj, ijunt)
            c = obj.ConeS(obj.nSxJ*(ijunt-1)+1: obj.nSxJ*ijunt);
        end
        
%         function   r =GetConeR(obj)
%            r = obj.ConeR;
%            if ~isempty(r)
%               r = reshape(r',1, size(r,1)*size(r,2)); 
%            end
%         end

        function c = GetConeSl(obj)
            c = obj.ConeS~=0;
        end

        function c = GetConeS(obj)
            %c = obj.ConeS(obj.GetConeSl);
            c = obj.ConeS;
        end
        
        
        function   g = plot(obj)
            % Se puede modificar color, transparencia, etc. una vez 
            % dibujado el RB si se le ha asignado un nombre:
            % plt = RB.plot;
            % set(plt,'facealpha',.0)
            % set(plt,'facecolor','r')
            global ucs; 
            
            geome=obj.Geome;
            
            g = fill3([geome(:,1)*cos(ucs.alpha)+ucs.x0], ...
                      [geome(:,1)*sin(ucs.alpha)+ucs.y0],...
                      [geome(:,2)]+ucs.z0,'c'); 
%             g = fill3([geome(:,1); geome(1,1)], ...
%                      [zeros(size(geome,1),1);0],...
%                      [geome(:,2); geome(1,2)],'c');            
           % g = fill([obj.Geome(:,1); obj.Geome(1,1)], ...
           %          [obj.Geome(:,2); obj.Geome(1,2)], 'c');
        end
 
        function   g = plotij(obj,ijunt)
            global ucs;
            
            geome=obj.Geome;
            junta=obj.Junta(ijunt,:);
            g = plot3(geome(junta,1)*cos(ucs.alpha)+ucs.x0, ...
                geome(junta,1)*sin(ucs.alpha)+ucs.y0, ...
                geome(junta,2)+ucs.z0, ...
                'b','LineWidth',2);
            
            %             for ijunt = 1 : obj.GetNJuntas
            %                 g = plot(obj.Geome(obj.Junta(ijunt,:),1), ...
            %                          obj.Geome(obj.Junta(ijunt,:),2), ...
            %                          'b','LineWidth',2);
            %             end
        end
        
        function   g = plotj(obj)
            for ijunt = 1 : obj.GetNJuntas
                g = obj.plotij(ijunt);
            end
        end
             
        function   g = plota(obj) %plot apoyos
            %TODO por ahora solo plotea apoyos 0,0,0
            g=[];
            for ijunt = 1 : obj.GetNJuntas
                if obj.Conex(ijunt,:)==0
                    g = obj.plotij(ijunt);
                    set(g,'color','r');

                end
            end
        end
       
        function   g = plotnv(obj,n) %imprime numero de vertices
            for iv=1 : obj.GetNVerti
                t = sprintf('%d', iv);
                g=obj.plotSver(iv, t);
            end
        end 
        
        function   g = plotn(obj,n) %imprime numero de elemento de un MRB
            g=obj.plotScdg(n);
        end
        
        function   g = plotname(obj,n) %imprime numero de elemento de un MRB
            g=obj.plotScdg(n);
        end
        
        function   g = plotScdg(obj,str)  %Imprime un texto cualquiera en cdg
            global ucs;
         
            xz = obj.GetCdg;
            x=xz(1)*cos(ucs.alpha)+ucs.x0; 
            y=xz(1)*sin(ucs.alpha)+ucs.y0; 
            z=xz(2)+ucs.z0;
            %str=sprintf('%s', str);
            g = text(x, y, z, str,'HorizontalAlignment', 'center');
        end
        
        function   g = plotSjunt(obj,ijunt, str)  %Imprime un texto cualquiera en junt
            global ucs;
            
            x=sum(obj.Geome(obj.Junta(ijunt,:),1))/2*cos(ucs.alpha)+ucs.x0;
            y=sum(obj.Geome(obj.Junta(ijunt,:),1))/2*sin(ucs.alpha)+ucs.y0;
            z=sum(obj.Geome(obj.Junta(ijunt,:),2))/2+ucs.z0;
            g = text(x, y, z, str,'HorizontalAlignment', 'center');
            
        end
        
        function g = plotSver(obj,iv, str)  %Imprime un texto cualquiera un vertice
            global ucs;
            
            x=obj.Geome(iv,1)*cos(ucs.alpha)+ucs.x0;
            y=obj.Geome(iv,1)*sin(ucs.alpha)+ucs.y0;
            z=obj.Geome(iv,2)+ucs.z0;
            g = text(x, y, z, str,'HorizontalAlignment', 'center');
            
        end
        
        function   g = plotConexOld(obj)
            global ucs;
            for ijunt = 1 : obj.GetNJuntas
                x=sum(obj.Geome(obj.Junta(ijunt,:),1))/2*cos(ucs.alpha)+ucs.x0;
                y=sum(obj.Geome(obj.Junta(ijunt,:),1))/2*sin(ucs.alpha)+ucs.y0;
                z=sum(obj.Geome(obj.Junta(ijunt,:),2))/2+ucs.z0;
                str=sprintf('%d, %d, %d', obj.Conex(ijunt,1), ...
                    obj.Conex(ijunt,2),obj.Conex(ijunt,3));
                g = text(x, y, z, str,'HorizontalAlignment', 'center');
            end
            ijunt=ijunt+1;
            xz = obj.GetCdg;
            x=xz(1)*cos(ucs.alpha)+ucs.x0; 
            y=xz(1)*sin(ucs.alpha)+ucs.y0; 
            z=xz(2)+ucs.z0;
            str=sprintf('%d, %d, %d', obj.Conex(ijunt,1), ...
                obj.Conex(ijunt,2),obj.Conex(ijunt,3));
            g = text(x, y, z, str,'HorizontalAlignment', 'center');
        end
           
        function   g = plotConex(obj)
            %global ucs;
            for ijunt = 1 : obj.GetNJuntas
                
                str=sprintf('%d, %d, %d', obj.Conex(ijunt,1), ...
                    obj.Conex(ijunt,2),obj.Conex(ijunt,3));
                g = obj.plotSjunt(ijunt, str);
            end
            ijunt=ijunt+1;
            str=sprintf('%d, %d, %d', obj.Conex(ijunt,1), ...
                obj.Conex(ijunt,2),obj.Conex(ijunt,3));
            g = obj.plotScdg(str);
        end 
        
        function   g = plotCones(obj)
            %global ucs;
            for ijunt = 1 : obj.GetNJuntas
                
                str=sprintf('%d, %d, %d', obj.ConeS(1,(ijunt-1)*3+1), ...
                    obj.ConeS(1,(ijunt-1)*3+2),obj.ConeS(1,(ijunt-1)*3+3));
                g = obj.plotSjunt(ijunt, str);
            end
        end
        
        function       addf(obj, f, nhip)
            %if size(obj.Hipts,2)<nhip
            if obj.GetNHipts<nhip
                obj.Hipts{nhip} = ArcoTSAM_fsis;
                for ihip=1 : nhip-1
                    if ~strcmp(class(obj.Hipts{ihip}), 'ArcoTSAM_fsis')
                        obj.Hipts{ihip} = ArcoTSAM_fsis;
                    end
                end
            end
            obj.Hipts{nhip}.addf(f)
        end
        
        function       delf(obj, nhip, varargin)
            obj.Hipts{nhip}.delf(varargin{:})
        end
        
        function       delHipts(obj, varargin)
            icell=chkIndex(obj.GetNHipts,varargin{:});
            if icell
                obj.Hipts(icell) = [];
            end
        end
        
        function     clearHipts(obj, varargin)
            obj.Hipts = {};
        end
        
        function       addu(obj, vectU, varargin)
            %
            
            % TODO TODO
            % Faltaría un try para comprobar que u [3x1] 
%             if nargin == 2 || size(nSol,2) == 0 
%                 nsol=obj.GetNsol+1; % Se añade a continuacion de la ultima
%             else
%                 nsol=nSol;
%             end
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            u=vectU(obj.Conex(end,1:3));
            obj.VectU{nsol}=u;
        end
        
        function       Oldaddu(obj, u, varargin)
            %
            
            % TODO TODO
            % Faltaría un try para comprobar que u [3x1]
            %             if nargin == 2 || size(nSol,2) == 0
            %                 nsol=obj.GetNsol+1; % Se añade a continuacion de la ultima
            %             else
            %                 nsol=nSol;
            %             end
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            obj.VectU{nsol}=u;
        end
        
        function       delu(obj, varargin)
            icell=chkIndex(obj.GetNsol,varargin{:});
            if icell
                obj.VectU(icell) = [];
            end
        end 
               
        function     clearu(obj)
            obj.VectU = {};
        end
        
        function       addju(obj, vectU, varargin)
            % Vectores u de las juntas del elemento
            % TODO
            % Faltaria un try para comprobar coherencia de u
            
            % Si no se pasa varargin se incluye u en la columna GetNsol+1,
            % donde GetNsol se obtiene a partir de obj.VectU. Hallada una
            % solucion, para incluir MatJU en la misma 'columna' que VectU 
            % debe añadirse en segundo lugar VectU. 
            
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
                conex = obj.Conex; 
                 
                ni = obj.GetNJuntas;
                nj = obj.nGdlxJ;
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
            obj.MatJU{nsol}=u;
        end
        function       old_addju(obj, u, varargin)
            % Vectores u de las juntas del elemento
            % TODO
            % Faltaria un try para comprobar coherencia de u
            
            % Si no se pasa varargin se incluye u en la columna GetNsol+1,
            % donde GetNsol se obtiene a partir de obj.VectU. Hallada una
            % solucion, para incluir MatJU en la misma 'columna' que VectU 
            % debe añadirse en segundo lugar VectU. 
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            obj.MatJU{nsol}=u;
         end
        
        function       delju(obj, varargin)
            icell=chkIndex(obj.GetNsol,varargin{:});
            if icell
                obj.MatJU(icell) = [];
            end
        end
        
        function     clearju(obj)
            obj.MatJU = {};
        end
        
        function       oldadds(obj, s, varargin)
            % TODO
            % Faltaría un try para comprobar consistencia de s
            
%             if nargin == 2 || size(nSol,2) == 0 
%                 nsol=obj.GetNsol; % Se añade en la posicion de la ultima u
%             else
%                 nsol=nSol;
%             end

            % Si no se pasa varargin se incluye s en la columna GetNsol+1,
            % donde GetNsol se obtiene a partir de obj.VectU. Hallada una
            % solucion, para incluir VectS en la misma 'columna' que VectU 
            % debe añadirse en segundo lugar VectU. 
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            obj.VectS{nsol}=s;
        end       


        function       adds(obj, vectS, varargin)
            % TODO
            % Faltaría un try para comprobar consistencia de s
            
%             if nargin == 2 || size(nSol,2) == 0 
%                 nsol=obj.GetNsol; % Se añade en la posicion de la ultima u
%             else
%                 nsol=nSol;
%             end

            % Si no se pasa varargin se incluye s en la columna GetNsol+1,
            % donde GetNsol se obtiene a partir de obj.VectU. Hallada una
            % solucion, para incluir VectS en la misma 'columna' que VectU 
            % debe añadirse en segundo lugar VectU. 
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            cs=obj.GetConeS;
            ivectS=[];
            ivectS(cs~=0)=vectS(cs(cs~=0));
            % obj.elems{ielem}.adds(ivectS',nsol);
            obj.VectS{nsol}=ivectS';
        end
        
        function       dels(obj, varargin)
            icell=chkIndex(obj.GetNsol,varargin{:});
            if icell
                obj.VectS(icell) = [];
            end
        end
        
        function     clears(obj, varargin)
            obj.VectS = {};
        end
        
        function       oldadde(obj, e, varargin)
            % TODO
            % Faltaría un try para comprobar consistencia de e
%             if nargin == 2 || size(nSol,2) == 0 
%                 nsol=obj.GetNsol; % Se añade en la posicion de la ultima u
%             else
%                 nsol=nSol;
%             end
            % Si no se pasa varargin se incluye e en la columna GetNsol+1,
            % donde GetNsol se obtiene a partir de obj.VectU. Hallada una
            % solucion, para incluir VectE en la misma 'columna' que VectU 
            % debe añadirse en segundo lugar VectU. 
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            obj.VectE{nsol}=e;
        end
        
              
        function       adde(obj, vectE, varargin)
            % Si no se pasa varargin se incluye e en la columna GetNsol+1,
            % donde GetNsol se obtiene a partir de obj.VectU. Hallada una
            % solucion, para incluir VectE en la misma 'columna' que VectU 
            % debe añadirse en segundo lugar VectU. 
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            cs=obj.GetConeS;
            cs=cs(cs~=0);
            obj.VectE{nsol}=vectE(cs);
        end
        
        function       dele(obj, varargin)
            icell=chkIndex(obj.GetNsol, varargin{:});
            if icell
                obj.VectE(icell) = [];
            end
        end
        
        function     cleare(obj)
            obj.VectE = {};
        end
           
        function       delSol(obj, varargin)   
            icell=chkIndex(obj.GetNsol,varargin{:});    
            if icell
                obj.dele(icell)
                obj.delju(icell)
                obj.dels(icell)
                % El ultimo u, pues a partir de el se calcula GetNsol.
                obj.delu(icell)
            end
        end
        
        function     clearSol(obj)
            obj.cleare;
            obj.clearju;
            obj.clears;
            obj.clearu;
        end
        
        function   e = KO_GetE_obsoleta(obj, varargin)
            % Calculo manual del vector e. Sirve como comprobación para el 
            % analisis NL.
            %
            % vectUSol: Vector u del solido (ux uz theta)
            % vectUJunt: Vector u de la junta (ux uz theta)
            % [ev en]: Versores tang. y normal a la junta (estado inicial) 
            % vectPosSol: Vector posicion de un extremo del solido
            % vectPosJunta: Vector posicion del mismo extremo de la junta
            % eN: proyección del vector que une el extremo de la 
            % junta y el del solido sobre el versor normal (en) a la junta.
            % eV: proyección del vector que une el extremo de la 
            % junta y el del solido sobre el versor tang. (eV) a la junta.
            %
            % Se calcula en cada extremo de la junta el valor de eN y eV. 
            % Es claro que en un analisis de pequeños movimientos los dos 
            % eV son identicos, pero no así necesariamente en un analisis
            % NL. 
            % 
            % Devuelve los eN en cada extremo de la junta y uno de los dos 
            % eV
            
%             if nargin < 2
%                 nsol=1;
%             else
%                 nsol=nSol;
%             end
            isol=chkIndex(obj.GetNsol,varargin{:});
            
            geome=obj.Geome;
            vectUSol=obj.VectU{isol};
            C=1;
            S=vectUSol(3);
            
            for ijunta=1 : obj.GetNJuntas
                vectUJunt=obj.MatJU{isol}(ijunta, :);
                CJ=1;
                SJ=vectUJunt(3);
                [ev, en] = obj.GeteVeNijunta(ijunta);
                for iv=1 : 2 % Los vertices de la junta

                    iver=obj.Junta(ijunta,iv);
                    vectPosSol=[vectUSol(1) vectUSol(2)]+ ...
                        [geome(iver,1) geome(iver,2)]*[[C -S]
                                                       [S  C]];
                    vectPosJunta=[vectUJunt(1) vectUJunt(2)]+ ...
                        [geome(iver,1) geome(iver,2)]*[[CJ -SJ]
                                                       [SJ  CJ]];
                    eN(iv) =  -(vectPosSol - vectPosJunta) *en';     
                    eV(iv) =  -(vectPosSol - vectPosJunta) *ev';                            
                end
                e(ijunta,:)=[eN eV(1)];
            end  
        end  
            
        function   e = KO_GetELM(obj, varargin)
            section('GetELM obsoleta: Usar GetEULM(true,iSol)')
            section('GetELM obsoleta: Usar GetEULM(true,iSol)')
            section('GetELM obsoleta: Usar GetEULM(true,iSol)')
            section('GetELM obsoleta: Usar GetEULM(true,iSol)')
            wobinichTamino
            % Calculo del vector e (para LM o pequeños movimientos)
            % LP proporciona (casi siempre) el vector e para pequeños
            % movimientos.
            %
            % vectUSol: Vector u del solido (ux uz theta)
            % vectUJun: Vector u de la junta (ux uz theta)
            % [ev en]: Versores tang. y normal a la junta (estado inicial) 
            % vectPosSol: Vector posicion de un extremo del solido
            % vectPosJun: Vector posicion del mismo extremo de la junta
            % eN: proyección del vector que une el extremo de la 
            % junta y el del solido sobre el versor normal (en) a la junta.
            % eV: proyección del vector que une el extremo de la 
            % junta y el del solido sobre el versor tang. (eV) a la junta.
            %
            % Es claro que en un analisis de pequeños movimientos los dos 
            % eV son identicos, pero no así necesariamente en un analisis
            % LM. Se elige como eV el correspondiente al eN minimo 
            % 
            % Devuelve los eN en cada extremo de la junta y el valor de eV 
            % 
            
            isol = chkIndex(obj.GetNsol,varargin{:});
            isLM = chkArg(true, varargin{2:end});
            
            geome=obj.Geome;
            vectUSol=obj.VectU{isol};
            for ijunta=1 : obj.GetNJuntas
                vectUJun=obj.MatJU{isol}(ijunta, :);
                [ev, en] = obj.GeteVeNijunta(ijunta);
                for iv=1 : 2 % Los vertices de la junta
                    iver=obj.Junta(ijunta,iv);
                    vectPosSol=obj.GetGeomeU(geome(iver,1:2), vectUSol, ...
                        isLM, 0, 1);
                    vectPosJun=obj.GetGeomeU(geome(iver,1:2), vectUJun, ...
                        isLM, 0, 1);
                    eN(iv) =  -(vectPosSol - vectPosJun) *en';     
                    eV(iv) =  -(vectPosSol - vectPosJun) *ev';                            
                end
                if eN(1)<eN(2)
                    eV1=eV(1);
                else
                    eV1=eV(2);
                end
                e(ijunta,:)=[eN eV1];
            end  
        end  
                   
        function   e = GetEULM(obj, varargin)
            % Calculo del vector e (para LM o pequeños movimientos).
            % LP proporciona (casi siempre) el vector e para pequeños
            % movimientos, o se calcula inmediatemente: e=Bu
            %
            % vectUSol: Vector u del solido (ux uz theta) medido desde el
            % estado inicial
            % vectUJun: Vector u de la junta (ux uz theta) medido desde el
            % estado inicial
            % [ev en]: Versores tang. y normal a la junta (del estado 
            % inicial o el final, -el iSolj si se pasa varargin4-) 
            % vectPosSol: Vector posicion de un extremo del solido para el
            % vector de movimiento vectUSol
            % vectPosJun: Vector posicion del mismo extremo de la junta 
            % para el vector de movimiento vectUJun
            % eN: proyección del vector que une el extremo de la 
            % junta y el del solido sobre el versor normal (en) a la junta.
            % eV: proyección del vector que une el extremo de la 
            % junta y el del solido sobre el versor tang. (eV) a la junta.
            %
            % Es claro que en un analisis de pequeños movimientos los dos 
            % eV son identicos, pero no es así necesariamente en un
            % analisis LM. Se elige como eV el correspondiente al eN minimo 
            % 
            % Devuelve los eN en cada extremo de la junta y el valor de eV 
            % 
            % wobinichTamino
            
            [isLM, iSol]=obj.GetParamULM(varargin{:});
            iSolj = chkArg(0, varargin{4:end}); 
            info = chkArg(false, varargin{5:end});
            % iSolj: geometría que se utiliza para calcular el versor 
            % [ev, en] de la junta sobre el que se estiman las
            % deformaciones.
            % Si no se pasa el parametro 4 iSolj = 0 y se calculan las
            % deformaciones sobre la geometría inicial
            
            % Geometria inicial
            geoIn=obj.Geome;
            vectUSol=obj.VectU{iSol};
            
            % Parametros para GeteVeNijuntaULM
            if iSolj == 0     % Junta 'original'
                isLMjunta = false; 
                escJunta  = 0; 
            else              % Junta del estado (solucion) iSolj
                isLMjunta = isLM;  
                escJunta = 1;
            end
            for ijunta=1 : obj.GetNJuntas
                vectUJun=obj.MatJU{iSol}(ijunta, :);
                [ev, en] = obj.GeteVeNijuntaULM(ijunta, isLMjunta, ... 
                                                iSolj, escJunta);
                for iv=1 : 2 % Los vertices de la junta
                    % Como el vector u se refiere a la geometria original
                    % para calcular la posicion de los vertices de la junta
                    % y del solido se debe usar dicha geometria inicial
                    iver=obj.Junta(ijunta,iv);
                    vectPosSol=obj.GetGeomeU(geoIn(iver,1:2), vectUSol, ...
                        isLM, 0, 1);
                    vectPosJun=obj.GetGeomeU(geoIn(iver,1:2), vectUJun, ...
                        isLM, 0, 1);
                    eN(iv) =  -(vectPosSol - vectPosJun) *en';     
                    eV(iv) =  -(vectPosSol - vectPosJun) *ev';
                    if (info) 
                        obj.infoEULM0( isLM, iSol, iSolj, ...
                            geoIn, vectUSol, ...
                            ijunta, vectUJun, ev, en, ...
                            iv, iver, vectPosSol, vectPosJun, eN, eV);
                         if (info>1)
                             obj.plotEULM0( isLM, iSol, iSolj, ...
                                 geoIn, vectUSol, ...
                                 ijunta, vectUJun, ev, en, ...
                                 iv, iver, vectPosSol, vectPosJun, eN, eV);
                             
                         end
                    end                            
                end
                if eN(1)<eN(2)
                    eV1=eV(1);
                else
                    eV1=eV(2);
                end
                e(ijunta,:)=[eN eV1];
            end
        end  
    
        function infoEULM(obj , varargin)
            [isLM, iSol, scal]=obj.GetParamULM(varargin{:});
            iSolj = chkArg(0, varargin{4:end});
            obj.GetEULM(isLM, iSol, scal, iSolj, true);
        end   
        
        function infoEULM0(obj, isLM, iSol, iSolj, ...
                           geoIn, vectUSol, ...
                           ijunta, vectUJun, ev, en, ...
                           iv, iver, vectPosSol, vectPosJun, eN, eV)
            subsection(' ',0,0,' ');
            subsection2(sprintf('Vector de movimientos del RB'));
            subsection2(sprintf('vectUSol=%9.6f, %9.6f, %9.6f', vectUSol),1);
            subsection2(sprintf('Junta: %d', ijunta));
            subsection2(sprintf('Vector de movimientos de la junta'));
            subsection2(sprintf('vectUJun  =%9.6f, %9.6f, %9.6f', vectUJun),1);
            subsection2(sprintf('Versores normal y tangencial de la junta en la posicion'))
            subsection2(sprintf('"de la iteracion" %d. Se evalua e=E(u) proyectando', iSolj))
            subsection2(sprintf('sobre ellos el movimieto relativo del solido y la junta'))
            subsection2(sprintf('ev        =%9.6f, %9.6f', ev),1);
            subsection2(sprintf('en        =%9.6f, %9.6f', en),1);
            subsection2(sprintf('Vertice: %d->(%9.6f, %9.6f)', iv, geoIn(iver,1:2)));
            subsection2(sprintf('Posicion final del vertice (solido y junta; isLM=%d)', isLM));
            c=1;s=vectUSol(3);
            if (isLM)
                c=cos(vectUSol(3));
                s=sin(vectUSol(3));
            end
            subsection2(sprintf('%9.6f + [ %9.6f %9.6f ] * %9.6f ', vectUSol(1),  c, s, geoIn(iver,1)),1)   
            subsection2(sprintf('%9.6f + [ %9.6f %9.6f ] * %9.6f ', vectUSol(2), -s, c, geoIn(iver,2)),1)   
            subsection2(sprintf('vectPosSol=%9.6f, %9.6f', vectPosSol),1);
            c=1;s=vectUJun(3);
            if (isLM)
                c=cos(vectUJun(3));
                s=sin(vectUJun(3));
            end
            subsection2(sprintf('%9.6f + [ %9.6f %9.6f ] * %9.6f ', vectUJun(1),  c, s, geoIn(iver,1)),1)   
            subsection2(sprintf('%9.6f + [ %9.6f %9.6f ] * %9.6f ', vectUJun(2), -s, c, geoIn(iver,2)),1) 
            subsection2(sprintf('vectPosJun=%9.6f, %9.6f', vectPosJun),1);
            subsection2(sprintf('Movimiento Relativo de la junta respecto del solido'));
            subsection2(sprintf('vectPosJun-vectPosSol=%9.6f, %9.6f', vectPosJun-vectPosSol),1);
            subsection2(sprintf('Proyeccion del MR anterior sobre los versores en y vn'))
            subsection2(sprintf('[ %9.6f %9.6f ] * [ %9.6f %9.6f ]^t', vectPosJun-vectPosSol, en),1)
            subsection2(sprintf('eN=%9.6f', eN(iv)),1);
            subsection2(sprintf('[ %9.6f %9.6f ] * [ %9.6f %9.6f ]^t', vectPosJun-vectPosSol, ev),1)
            subsection2(sprintf('eV=%9.6f', eV(iv)),1);
        end
         
        function plotEULM(obj , varargin)
            [isLM, iSol, scal]=obj.GetParamULM(varargin{:});
            iSolj = chkArg(0, varargin{4:end});
            obj.plot;
            obj.plotu(varargin{:});
            obj.plotuj(varargin{:});
            obj.GetEULM(isLM, iSol, scal, iSolj, 2);
        end
        
        function plotEULM0(obj, isLM, iSol, iSolj, ...
                geoIn, vectUSol, ...
                ijunta, vectUJun, ev, en, ...
                iv, iver, vectPosSol, vectPosJun, eN, eV)

            
            %'Posicion final del vertice (solido y junta; isLM=%d)', isLM));
            c=1; s=vectUSol(3);
            if (isLM)
                c=cos(vectUSol(3));
                s=sin(vectUSol(3));
            end
         
            quiver(vectPosSol(1), vectPosSol(2), ev(1), ev(2), ... 
                   0,'m','LineWidth',1);
            quiver(vectPosSol(1), vectPosSol(2), en(1), en(2), ... 
                   0,'m','LineWidth',1);
            quiver(vectPosSol(1), vectPosSol(2), ...
                   vectPosJun(1)-vectPosSol(1), vectPosJun(2)-vectPosSol(2), ... 
                   0,'m','LineWidth',1);         
            quiver(vectPosSol(1), vectPosSol(2), eV(iv)*ev(1), eV(iv)*ev(2), ... 
                   0,'m','LineWidth',4);                
            str=sprintf('%0.3f', eV(iv));   
            text(vectPosSol(1)+eV(iv)*ev(1)/2, vectPosSol(2)+eV(iv)*ev(2)/2, ...
                   str,'HorizontalAlignment', 'center');
            quiver(vectPosSol(1), vectPosSol(2), eN(iv)*en(1), eN(iv)*en(2), ... 
                   0,'m','LineWidth',4);
            str=sprintf('%0.3f', eN(iv));   
            text(vectPosSol(1)+eN(iv)*en(1)/2, vectPosSol(2)+eN(iv)*en(2)/2, ...
                   str,'HorizontalAlignment', 'center'); 
        end
                       
        function  er = GetEr(obj, varargin)
            iSol= chkArg(obj.GetNsol, varargin{1:end}); 
            iSolj = chkArg(0, varargin{2:end}); 
            
            Bu=obj.GetEULM(0,iSol,1,iSolj);
            E=obj.GetEULM(1,iSol,1,iSolj);
            er=E-Bu;
            
        end
        
        function   u = GetVectUAmp(obj, varargin)
            [isLM, iSol, scal] = obj.GetParamULM(varargin{:});
            u = cat(1,obj.MatJU{iSol}, obj.VectU{iSol}');
        end
        
        function u=GetVectU(obj, varargin)
            
            iSol=chkIndex(obj.GetNsol,varargin{:});
            u =  obj.VectU{iSol};
        end
        
        function s=GetVectS(obj, varargin)
            
            iSol=chkIndex(obj.GetNsol,varargin{:});
            s =  obj.VectS{iSol};
        end
        
        function   e = GetEBu(obj, varargin)
            %[isLM, iSol, scal] = obj.GetParamULM(varargin{:});
            [isLM, ~, ~] = obj.GetParamULM(varargin{:});
            
            ua = obj.GetVectUAmp(varargin{:});
            ua = reshape(ua',size(ua,1)*size(ua,2),1);
            if isLM
                e=(obj.GetHULM(varargin{:}))'*ua;
            else
                e=(obj.GetH)'*ua;
            end
        end
        
        function   e = KO_GetE(obj, varargin)
            section('GetE obsoleta: Sustituir por GetEULM(false,iSol)');
            section('GetE obsoleta: Sustituir por GetEULM(false,iSol)');
            section('GetE obsoleta: Sustituir por GetEULM(false,iSol)');
            wobinichTamino;
            isol=chkIndex(obj.GetNsol,varargin{:});
            %e = obj.GetELM(isol, false);
            e = obj.GetEULM(false, isol);
        end
       
        function   e = KO_GetELM_1(obj, varargin)
            % Calculo del vector e (para LM o pequeños movimientos) medido
            % sobre la junta en la posicion t-1
            % LP proporciona (casi siempre) el vector e para pequeños
            % movimientos.
            %
            % vectUSol: Vector u del solido (ux uz theta)
            % vectUJun: Vector u de la junta (ux uz theta)
            % [ev en]: Versores tang. y normal a la junta (estado inicial) 
            % vectPosSol: Vector posicion de un extremo del solido
            % vectPosJun: Vector posicion del mismo extremo de la junta
            % eN: proyección del vector que une el extremo de la 
            % junta y el del solido sobre el versor normal (en) a la junta.
            % eV: proyección del vector que une el extremo de la 
            % junta y el del solido sobre el versor tang. (eV) a la junta.
            %
            % Es claro que en un analisis de pequeños movimientos los dos 
            % eV son identicos, pero no así necesariamente en un analisis
            % LM. Se elige como eV el correspondiente al eN minimo 
            % 
            % Devuelve los eN en cada extremo de la junta y el valor de eV 
            % 
            
            disp ('obsoleto GetELM_1: sustituir por GetEULM(isLM,iSol,1,iSol-1)');
            disp ('obsoleto GetELM_1: sustituir por ...?');
            disp ('obsoleto GetELM_1: sustituir por ...?');
            disp ('obsoleto GetELM_1: sustituir por ...?');
            wobinichTamino
            %isol = chkIndex(obj.GetNsol,varargin{:});
            %isLM = chkArg(true, varargin{2:end});
            [isLM, iSol]=obj.GetParamULM(varargin{:});
            
            geome0=obj.Geome;
            geome=obj.GetGeomeU(obj.Geome,obj.VectU{iSol},true,0,1);
            vectUSol=obj.VectU{iSol};
            
            for ijunta=1 : obj.GetNJuntas
                vectUJun=obj.MatJU{iSol}(ijunta, :);
                %TODO TODO
                %Deberia poder ajustarse el estado de referencia (ahora es
                %t-1. Habria que verificar que existe.
                [ev, en] = obj.GeteVeNijuntaULM(ijunta,1,iSol,true);
                    disp('xxxxxxxxx_1')
                    islm=1
                    isolj=iSol-1
                    disp('xxxxxxxxx_1')
                for iv=1 : 2 % Los vertices de la junta
                    iver=obj.Junta(ijunta,iv);
                    vectPosSol=obj.GetGeomeU(geome0(iver,1:2), vectUSol, ...
                        isLM, 0, 1);
                    disp ('yyyy calculo vectPosSol-geome=-------------------y');
                    geome0(iver,1:2)
                    vectUSol
                    isLM
                    disp ('yyyyyyyyyyyyyyyy--------------------y');
                    vectPosJun=obj.GetGeomeU(geome0(iver,1:2), vectUJun, ...
                        isLM, 0, 1);
                    eN(iv) =  -(vectPosSol - vectPosJun) *en';     
                    eV(iv) =  -(vectPosSol - vectPosJun) *ev';                            
                end
                if eN(1)<eN(2)
                    eV1=eV(1);
                else
                    eV1=eV(2);
                end
                e(ijunta,:)=[eN eV1];
            end 
            obj.Geome
            e
            vectUJun
            vectUSol
            [ev, en]
            e1=obj.GetEULM(isLM,iSol,1,iSol-1)
            e2=obj.GetEULM
        end
        
        function   g = plotf(obj, sc, iHip)
            g = obj.Hipts{iHip}.plot(sc);
        end
        
        function   g = plotfR(obj, sc, iHip)
            g = obj.Hipts{iHip}.plotR(sc);
        end
        
        function updateGeome(obj, vectU, varargin)
            newGeome = obj.GetGeomeU(obj.Geome, vectU, varargin{:});
            obj.Geome = newGeome;
        end
        
        function geome = GetGeomeU (obj, geome, vectU, varargin)
            % Transforma las coordenadas de los vertices de geome para el 
            % vector de movimientos vectU 
            %
            % Parámetros:
            % geome - coordenadas de los vértices, en el formato de la
            %         propiedad Geome. El parámetro geome no es la 
            %         necesariamente la propiedad Geome.
            % vectU - Vectores u (soluciones) del RB. El parámetro vectU no 
            %         es la propiedad VectU, ni tiene que ser una de sus
            %         componentes VectU{i}
            %
            % Ni geome, ni vectU son las propiedades Geome y VectU, 
            % por eso se pasan al método como parámetros (aunque 
            % seguramente son componentes de Geome, VectU y/o MatJU). De
            % este modo el método es comun para los RB y sus juntas (como
            % en plotu y plotju)
            %
            % Parámetros opcionales:
            % isLM - Grandes movimientos, true por defecto
            % iSol - este parámetro no se utiliza (se pasa vectU)
            % scal - Escala de la deformada, 1 por defecto
            %
            % Teoria de pequeños movimientos:
            % se aproxima cos(theta)=1, sen(theta)=theta.
            %
            % Si isLM=true el factor de escala se ajusta a la unidad.
            %
            %
            % Esta funcion no es un 'method' del objeto, podría definirse
            % fuera del mismo (matlab muestra un warning indicando que el
            % argumento obj no se utiliza si se usan las tres lineas 
            % siguientes  equivalentes a GetparamULM) 
            %            
            % scal = chkArg(1, varargin{3:end});
            % iSol = chkIndex(obj.GetNsol, varargin{2:end});
            % isLM = chkArg(false, varargin{1:end});
            
            [isLM, ~ , scal] = obj.GetParamULM(varargin{:});
            if isLM
                C=cos(vectU(3));
                S=sin(vectU(3));
                scal = 1;
            else
                C = 1;
                S = scal*vectU(3);
            end
            for iver = 1: size(geome,1)
                geome(iver,:)= ...
                    [scal*vectU(1) scal*vectU(2)]+ ...
                    [geome(iver,1) geome(iver,2)]*[[C -S]
                                                   [S  C]];
            end
        end
        
        function   g = plotu(obj, varargin)
            % Dibujo de la geometría y topología del elemento RB para un 
            % vector de movimientos.
            %
            % Parámetros opcionales:
            % isLM - Grandes movimientos, true por defecto
            % iSol - Solucion que se dibuja, obj.GetNsol por defecto 
            % scal - Escala de la deformada, 1 por defecto
            %
            % Teoria de pequeños movimientos:
            % se aproxima cos(theta)=1, sen(theta)=theta.
            %
            % Si isLM=true el factor de escala se ajusta a la unidad.
            
            global ucs;

            [~, iSol, scal] = obj.GetParamULM(varargin{:});
            geome=obj.GetGeomeU(obj.Geome, obj.VectU{iSol}, varargin{:});
            global interplUy; %2.5D
            if not(isempty(interplUy)) && size(interplUy,1)>1
%                 fprintf ('ArcoTSAMRP.plotu -> interplUy=%f\n', interplUy); interplUy
%                 size(interplUy)
%                 size(interplUy,1)
                % La primera componente de interplUy es la abscisa del
                % punto y la tercera su desplazamiento horizontal
                uy = interp1(interplUy(:,1)+interplUy(:,3)*scal, ...
                    interplUy(:,2), geome(:,1), 'linear', 'extrap');
            else
                uy=zeros(obj.GetNVerti,1);
            end
            %iSol = chkIndex(obj.GetNsol, varargin{2:end});
            g = fill3([geome(:,1)*cos(ucs.alpha)+uy(:)*scal*sin(ucs.alpha)+ucs.x0], ...
                      [geome(:,1)*sin(ucs.alpha)-uy(:)*scal*cos(ucs.alpha)+ucs.y0],...
                      [geome(:,2)]+ucs.z0,'c'); 
%             g = fill([geome(:,1); geome(1,1)], ...
%                      [geome(:,2); geome(1,2)], 'c');
        end
             
        function   g = plotuj(obj, varargin)
            % Dibujo de las juntas en la posición deformada
            % See also plotu (las opciones son las mismas)
            
            global ucs;
            global interplUy; %2.5D
            % Ha que comprobar que esta definido obndj.Vectu
            % Falta try
            %iSol = chkIndex(obj.GetNsol, varargin{2:end});
            [isLM, iSol, scal] = obj.GetParamULM(varargin{:});
            for ijun = 1: obj.GetNJuntas
                geome = obj.Geome(obj.Junta(ijun,:),:);


                matJU=obj.MatJU{iSol};
                vectU=matJU(ijun,:);
                %geome=obj.GetGeomeUJ(ijun, geome varargin{:});   
                geome=obj.GetGeomeU(geome, vectU, varargin{:});  
                if not(isempty(interplUy)) && size(interplUy,1)>1
                    % La primera componente de interplUy es la abscisa del
                    % punto y la tercera su desplazamiento horizontal
                    uy = interp1(interplUy(:,1)+interplUy(:,3)*scal, ...
                        interplUy(:,2), geome(:,1), 'linear', 'extrap');
                    %                     uy = interp1(interplUy(:,1),interplUy(:,2), ...
                    %                         geome(:,1), 'linear', 'extrap');
                else
                    uy=zeros(2,1);
                end 
%                 g = plot3([geome(:,1)*cos(ucs.alpha)+ucs.x0], ...
%                           [geome(:,1)*sin(ucs.alpha)+ucs.y0], ...
%                           [geome(:,2)+ucs.z0],'b','LineWidth',2); 
                g = plot3([geome(:,1)*cos(ucs.alpha)+uy(:)*scal*sin(ucs.alpha)+ucs.x0], ...
                          [geome(:,1)*sin(ucs.alpha)-uy(:)*scal*cos(ucs.alpha)+ucs.y0], ...
                          [geome(:,2)+ucs.z0],'b','LineWidth',2);
            end
        end
        
        % Quiza las tres siguientes se puedan unificar
    

        function   g = plotRj(obj, varargin)
            % Dibuja la posicion de la resultante de las fuerzas en cada
            % junta
            
            warning('¿plotRj obsoleta?, sustituir por plotRjULM'); 
            
            scal = chkArg(1, varargin{:});
            iSol = chkIndex(obj.GetNsol, varargin{2:end});
            %iSol = chkIndex(obj.GetNsol, varargin{2:end});
            %isLM = chkArg(false, varargin{3:end});
            
            for ijun = 1: obj.GetNJuntas
                %fprintf('junta %d\n',ijun)
                g = obj.GetRijun(ijun, iSol).plot(scal);
            end
        end
             
        function   g = plotRjULM(obj, varargin)
            % Dibuja la posicion de la resultante de las fuerzas en cada
            % junta
            %
            % Parámetros opcionales:
            % scaf - Escala de la resultante, 1 por defecto
            % isLM - Grandes movimientos, true por defecto
            % iSol - Solucion que se dibuja, obj.GetNsol por defecto 
            % scal - Escala de la deformada, 1 por defecto
            
            scaf = chkArg(1, varargin{1:end});
            
            % Lo que sigue, mas eficiente, no funciona en octave
            % for ijun = 1: obj.GetNJuntas
            %     g=obj.GetRijunULM(ijun, varargin{2:end}).plot(scaf);
            % end
            
            if ~isempty(varargin)
                % Se elimina el primer parámetro de varargin (scaf) para
                % utilizar posteriormente GetRijunULM del modo habitual
                varargin(1)=[];
            end
            for ijun = 1: obj.GetNJuntas
                g=obj.GetRijunULM(ijun, varargin{:}).plot(scaf);
            end
        end
        
        
        function  iH = infoH(obj)
            obj.infoHULM(false,0);
        end
        
        function  iH = infoHULM(obj, varargin)
            % Funcion auxiliar. Imprime las filas/columnas activas
            % (esto es, aquellas cuyas conex/coneS son no nulas)
            section ('');
            fprintf ('%s\n\n%s\n%s\n%s %s\n%s\n%s\n%s\n', ...
                'infoH, infoHULM(isLM, iSol)', ...
                'Primera fila: ConeS', ...
                'Primera columna: Conex', ...
                'Debe haberse asignado Conex y ConeS para que el', ...
                'resultado tenga sentido', ...
                'obj.GetH imprime la matriz H "completa"', ...
                'obj.GetHULM idem con LM');
            
            idConex = obj.Conex;
            idConex = reshape(idConex',1, size(idConex,1)*size(idConex,2));
            lConex = idConex~=0;
            lConeS = obj.GetConeSl;
            
            
            iH=obj.GetHULM(varargin{:});
            iH=iH(lConex,lConeS);
            iH=cat(1,obj.GetConeS,iH);
            iH=cat(2,(cat(2,[0],idConex(lConex)))',iH)
        end
        
        function  iH = GetHULM(obj, varargin)
            
            %isol = chkIndex(obj.GetNsol,varargin{:});
            %isLM = chkArg(true, varargin{2:end});
            [isLM, iSol] = obj.GetParamULM(varargin{:});
            
            geome=obj.Geome;
            if iSol > 0
                vectUSol=obj.VectU{iSol};
                %class(obj)
                clon = eval(class(obj));
                %fprintf('----ArcoTSAM_RB.GetHLM-------LM=%d----\n', isLM);
                clon.Geome=obj.GetGeomeU(geome, vectUSol, isLM, 0, 1);
                clon.Junta=obj.Junta;
                %clon.Conex=obj.Conex;
                %clon.ConeS=obj.ConeS;
                iH = clon.GetH; 
            else
                iH = obj.GetH;  
            end
            iH;
        end
        
        function   f = GetG(obj)
            f = ArcoTSAM_f([obj.GetCdg 0 ...
                            obj.GetArea*obj.b*obj.rho 0]);
        end
        
        function   f = GetGULM(obj)
            f = ArcoTSAM_f([obj.GetCdgULM 0 ...
                            obj.GetArea*obj.b*obj.rho 0]);
        end
        
        function   l = isEQU(obj, varargin)
            l = abs(obj.chkEQU(varargin{:})) < obj.epsEQU;
        end
        
        function fHs = chkEQU(obj, varargin)            
            [isLM, iSol, ~] = obj.GetParamULM(varargin{:});
            iHip = chkIndex(obj.GetNHipts,varargin{4:end});
            
            if isLM
                iH = obj.GetHULM(isLM, iSol);
            else
                iH = obj.GetH;
            end
            vectS=obj.VectS{iSol};
            vectS=vectS( obj.GetConeSl);
            Hs = iH(:, obj.GetConeSl)*vectS;
            fHs = Hs(end-2:end)+obj.Hipts{iHip}.GetComp';
        end
        
        function addUyReacc(obj,varargin)
            % 2.5D Se asigna el valor VectUy=0 
            %
            
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            xz=obj.GetCdgReacc;
            if not(isempty(xz))
                obj.VectUy{nsol}=[xz(1) 0 0];
            end;
        end
        
        function xuy=GetVectUy(obj,varargin)
            nsol=chkIndexIn(obj.GetNsol-1,varargin{:});
            xuy=[];
%            warning('Tenemos un problema en RB.GetVectUy');
%            fprintf('nsol=%d, se comprueba isempty(obj.VectUy) %s %s\n', nsol, class(obj), obj.name);
            if not(isempty(obj.VectUy)) % && nsol<numel(obj.VectUy)
%                fprintf('No está vacio\n');
%                celldisp(obj.VectUy)
                xuy=obj.VectUy{nsol};
            end
        end
        
 %       function     SetUy(obj,xv,varargin)
 %           isol=chkIndexIn(obj.GetNsol-1,varargin{:});
 %           obj.Geome;
 %           %vq1 = interpl(xv(:,1),xv(:,2),obj.Geome(:,1),'linear','extrap');
 %           
 %           obj.VectUY{isol}=interp1(xv(:,1),xv(:,2),obj.Geome(:,1), ...
 %                                    'linear','extrap');
 %       end
        
        function cdg=GetCdgReacc(obj)
            % TODO. Por ahora solo esta programado para Conex=[0,0,...,0]
            % Si se desarrolla lo anterior, esta función debe 
            % particularizarse para cada tipo de element que se defina
            cdg=[];
            for ijunt = 1 : obj.GetNJuntas
               if (sum(obj.Conex(ijunt,:))==0)
                   cdg=[cdg, sum(obj.Geome(obj.Junta(ijunt,:),:))/2];
               end
            end
        end
        
        function cdg=GetCdgJunt(obj)
            cdg=[];
            for ijunt = 1 : obj.GetNJuntas
                cdg=[cdg; sum(obj.Geome(obj.Junta(ijunt,:),:))/2];
            end
        end        
        
        function cdg=GetCdgAris(obj)
            cdg=[];
            for iv = 1 : obj.GetNVerti-1
                cdg=[cdg; (obj.Geome(iv,:)+obj.Geome(iv+1,:))/2];
            end
            cdg=[cdg; (obj.Geome(iv+1,:)+obj.Geome(1,:))/2];
        end     
        
        function L=GetLAris(obj)
             L=[];
             for iv = 1 : obj.GetNVerti-1
                 va=obj.Geome(iv,:)-obj.Geome(iv+1,:);
                 L=[L; sqrt(va(1)^2+va(2)^2)];
             end
             va=obj.Geome(1,:)-obj.Geome(iv+1,:);
             L=[L; sqrt(va(1)^2+va(2)^2)];
        end
        
        function L=GetLJunta(obj)
            L=[];
            for iv = 1 : obj.GetNJuntas
                va=obj.Geome(obj.Junta(iv,1),:)-obj.Geome(obj.Junta(iv,2),:);
                L=[L; sqrt(va(1)^2+va(2)^2)];
            end
        end
        
        function [verticesComunesObj, verticesComunesRB] = isInContactWith(obj, RB)
            % Filas comunes de Geom entre obj y RB
            [verticesComunesObj, verticesComunesRB] = ismembertol_row(obj.Geome, RB.Geome);
            if (nnz(verticesComunesObj)~=2) % Localizada junta. SOLO SI HAY UNA ARISTA COMUN
                verticesComunesObj= false;
                verticesComunesRB=false;
                return
            end
            verticesComunesObj(verticesComunesObj == 0) = [];
            verticesComunesRB(verticesComunesRB == 0) = [];
            verticesComunesRB=flip(verticesComunesRB);
        end

        function joinIfisInContactWith(obj, RB)
            % Filas comunes de Geom entre obj y RB
            [verticesComunesObj, verticesComunesRB] = isInContactWith(obj, RB);
            if ~isequal(verticesComunesObj,  false)
                 if (verticesComunesObj(1)==1 && verticesComunesObj(2)==size(obj.Geome,1)) % junta definida por el último vertice y el primero
                     verticesComunesObj(1)=verticesComunesObj(2);
                     verticesComunesObj(2)=1;
                 end
                 % si Junta=[] o la nueva junta ya esta definida se añade
                 if isempty(obj.Junta) || ~ismember(verticesComunesObj', obj.Junta, 'row')
                    obj.Junta = [obj.Junta; verticesComunesObj']; % Añadida junta
                 end

                 % Lo mismo para RB
                 idx = find(verticesComunesRB);
                 if (verticesComunesRB(1)==1 && verticesComunesRB(2)==size(RB.Geome,1)) % junta definida por el último vertice y el primero
                     verticesComunesRB(1)=verticesComunesRB(2);
                     verticesComunesRB(2)=1;
                 end
                 % si Junta=[] o la nueva junta ya esta definida se añade
                 if isempty(RB.Junta) || ~ismember(verticesComunesRB', RB.Junta, 'row')
                    RB.Junta = [RB.Junta; verticesComunesRB'];
                 end
            end
        end
    end       

    %methods (Static)
    %end
end

