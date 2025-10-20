classdef ArcoTSAM_RB210 < ArcoTSAM_RB
    %ArcoTSAM_RB210 Summary of this class goes here
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
                
        function  obj = ArcoTSAM_RB210(geomConex)
          obj.nGdlxJ=3;
          obj.nSxJ=3;
          if ~nargin
              % the default constructor. Needed for array creation
          else
              % only take care of the array part for simplicity:
              if iscell(geomConex) 
                %[elem(1:length(GeomConex)).GeomConex] = deal(GeomConex{:});
                for ielem = 1: length(geomConex)
                    disp '-----NO CHEQUEADO. Constructor ArcoTSAM_RB210---------'
                    obj(ielem).geomConex=geomConex{ielem};
                end
              else
                % Las tres ultimas componentes son las conex del solido
                GeomConex=geomConex(1:end-3);
                GeomConex=reshape(GeomConex,7,size(GeomConex,2)/7);
                njunt=size(GeomConex,2);
                obj.Geome = (reshape(GeomConex(1:4,:),2,2*njunt))';
                obj.Junta = (reshape(1:2*njunt,2,njunt))';
                obj.Conex = [GeomConex(5:7,:)'; geomConex(end-2:end)];
              end
          end
        end
        
        function ngdl = GetNGdl(elem)
            njunt = GetNJuntas(elem);
            ngdl = elem.nGdlxJ*njunt+3;
        end 
             
        % Ver GetNsAmp. Devuelve Ns incluidos "reacciones/enlaces"
        function   ns = GetNs(elem)
            njunt = GetNJuntas(elem);
            ns = elem.nGdlxJ*njunt;
        end 
        
        function   iH = GetH(elem)
  
            njunt = GetNJuntas(elem);
            ngdl  = GetNGdl(elem);
            ns    = GetNs(elem);
  
            iH = zeros(ngdl, ns);
            % A continuación se añade la matriz identidad para incluir las
            % 'reacciones' y los enlaces 
            % TODO ¿No será mas eficiente crear un 'elemento' para las
            % los enlaces.
            % Es posible, hay una tentativa en 200603, pero no se concluyó
            % pues dejarían de funcionar, por ejemplo, las
            % funciones de chequeo del equilibrio. De este modo queda 
            % detro de cada elemento todos sus resultados
            iH= cat(2, iH, eye(ngdl)); 
            for ijunt = 1 : njunt
                %[v,n] = elem.GeteVeNijunta(ijunt);
                [v,n] = elem.GeteVeNijuntaULM(ijunt, false, 0, 0);
                xi = elem.Geome(elem.Junta(ijunt,1),1);
                zi = elem.Geome(elem.Junta(ijunt,1),2);
                xj = elem.Geome(elem.Junta(ijunt,2),1);
                zj = elem.Geome(elem.Junta(ijunt,2),2); 
                % EQU junta i ---------------------------------------------
                ih = [n(1)            n(1)            v(1);
                      n(2)            n(2)            v(2);
                      n(1)*zi-n(2)*xi n(1)*zj-n(2)*xj v(1)*zi-v(2)*xi];
%
%                lx = xj-xi;
%                lz = zj-zi;
%                l = sqrt(lx*lx+lz*lz); 
%                c =  lx/l;
%                s = -lz/l; 
%                
%                % EQU junta i ---------------------------------------------
%                ih = [ s          s         c;
%                       c          c        -s;
%                       s*zi-c*xi  s*zj-c*xj c*zi+s*xi];
%                 ih = [-s         -s         c;
%                        c          c         s;
%                       -s*zi-c*xi -s*zj-c*xj c*zi-s*xi];
                icolH = elem.nSxJ*(ijunt-1)+1;
                jcolH = elem.nSxJ*(ijunt-1)+3;
                iH(icolH:jcolH,icolH:jcolH)  = -ih;
                % EQU elem ------------------------------------------------
                iH(ngdl-2:ngdl, icolH:jcolH) = ih;
                % ligaduras de las juntas ---------------------------------
                % Se incluye "el momento" de las ligaduras (sobre la matriz
                % identidad que se ha añadido a la de equilibrio)
                iH(jcolH,jcolH + 3*njunt - 2)=(zi+zj)/2;
                iH(jcolH,jcolH + 3*njunt - 1)=-(xi+xj)/2;
%                fprintf('%d,%d->%f\n',jcolH,jcolH + 3*ijunt - 2,(xi+xj)/2);
%                fprintf('%d,%d->%f\n',jcolH,jcolH + 3*ijunt - 1,(zi+zj)/2);
            end

            % A continuación se incluye "el momento" de la ligadura del
            % sólido
            xz=elem.GetCdg;
            iH(end,end-2)= xz(2);
            iH(end,end-1)=-xz(1);


        end 
             
        function   lb = GetLb(elem)
            njunt = GetNJuntas(elem);
            lb = [];
            for ijunt = 1 : njunt  
                       %    N    N    V
                lb = [lb -Inf -Inf -Inf];
            end
            % A continuación las "reacciones/enlaces"
            nreac = size(elem.ConeS,2)-size(lb,2);
            lb = [lb -Inf*ones(1,nreac)];
        end
        
        function   ub = GetUb(elem)
            njunt = GetNJuntas(elem);
            ub = [];
            for ijunt = 1 : njunt  
                       %    N    N    V      
                ub = [ub    0    0  Inf];
            end 
            % A continuación las "reacciones/enlaces"
            nreac = size(elem.ConeS,2)-size(ub,2);
            ub = [ub Inf*ones(1,nreac)];   
        end
        
        % TODO TODO
        % Esta funcion y la siguiente deben unificarse
        function    c = GetSdir(elem, ijunt, alpha)
            % Proyección de las componentes del vector s de la ijunt sobre
            % la direccion alpha: h=ct*s;
            % [eV, eN]=elem.GeteVeNijunta(ijunt);
            %
            % Si ijunt > GetNjuntas => reacciones
            
            if (ijunt <= elem.GetNJuntas)
                [eV, eN]=elem.GeteVeNijuntaULM(ijunt, false, 0, 0);
                v=[cos(alpha) -sin(alpha)];
                
                c(1)=v*eN';
                c(2)=v*eN';
                c(3)=v*eV';
            else
                c(1)= cos(alpha);
                c(2)=-sin(alpha);
                c(3)=0;
            end
        end
              
        % TODO TODO: Es posible que no se utilice
        function    c = GetSdirULM(elem, ijunt, alpha, varargin)
            % Proyección de las componentes del vector s de la ijunt sobre
            % la direccion alpha: h=ct*s;
            % [eV, eN]=elem.GeteVeNijunta(ijunt);
            [eV, eN]=elem.GeteVeNijuntaULM(ijunt, varargin{:});
            v=[cos(alpha) -sin(alpha)];
            
            c(1)=v*eN';
            c(2)=v*eN';
            c(3)=v*eV';
        end
        
        function    f = GetRijun(elem, ijunt, iSol)
            % Resultante de las componentes del vector s de la ijunt sobre
            % la geometria inicial.
            scal=0;  
            %iSol=0;
            isLM=false;
            f = elem.GetRijunULM(ijunt,isLM,iSol, scal);
        end
              
        function    f = GetRijunULM(elem, ijunt, varargin)
            % Resultante de las componentes del vector s de la ijunt sobre
            % la geometria final.
            % 
            % Parámetros
            % ijunt - número de la junta
            %
            % Parámetros opcionales:
            % isLM - Grandes movimientos, true por defecto
            % iSol - Solucion que se dibuja, obj.GetNsol por defecto 
            % scal - Escala de la deformada, 1 por defecto
            
            % wobinichTamino
            
            [isLM, iSol, scal] = elem.GetParamULM(varargin{:});
            
            [eV, eN]=elem.GeteVeNijuntaULM(ijunt,varargin{:});
            geome = elem.GetGeomeU(elem.Geome,elem.VectU{iSol},varargin{:});
            geome = geome(elem.Junta(ijunt,:),:);
            P1=geome(1,:);
            P2=geome(2,:);
            vectS = elem.VectS{iSol}(1+(ijunt-1)*3:3*ijunt)';
            
            f=ArcoTSAM_f([P1 vectS(1)*eN(1,:) 0])+ ...
              ArcoTSAM_f([P2 vectS(2)*eN(1,:) 0])+ ...
              ArcoTSAM_f([P1 vectS(3)*eV(1,:) 0]);
            m = f.Comp(3);
            n = vectS(1)+vectS(2);
            Ljun=sqrt((P2-P1)*(P2-P1)');
            if (m~=0 && n ~= 0 && Ljun~=0) 
                e = -m/n/Ljun;
                % Sin tracciones 1<e<-1. Se toma un límite razonable
                if (abs(e)>10)
                    e=0.5;
                end
                f.Comp=f.GetComp(P2*(e)+P1*(1-e));
                f.Punt=P2*(e)+P1*(1-e);
            end
        end
        
        function   g = plotSULM(elem, varargin)
            warn( 'Obsoleto ArcoTSAM_RB210.plotSULM , -> plotVectSULM');
        end
        
        function   g = plotVectSULM(elem, varargin)
            % Dibuja las componentes de s de cada junta
            
            scaf = chkArg(1, varargin{1:end});
            [isLM, iSol, scal] = elem.GetParamULM(varargin{2:end});          
           
            
            if ~isempty(varargin)
                varargin(1)=[];
            end
            for ijunt = 1: elem.GetNJuntas   
 
                [eV, eN]=elem.GeteVeNijuntaULM(ijunt,isLM, iSol, scal);
                geome = elem.GetGeomeU(elem.Geome,elem.VectU{iSol},isLM, iSol, scal);
                geome = geome(elem.Junta(ijunt,:),:);
                P1=geome(1,:);
                P2=geome(2,:);
                vectS = elem.VectS{iSol}(1+(ijunt-1)*3:3*ijunt)';
            
                N1=ArcoTSAM_f([P1 vectS(1)*eN(1,:) 0]);
                N2=ArcoTSAM_f([P2 vectS(2)*eN(1,:) 0]);   
                V=ArcoTSAM_f([(P1+P2)/2 vectS(3)*eV(1,:) 0]);              
                g=N1.plot(scaf);          
                g=N2.plot(scaf);      
                g=V.plot(scaf);
            end
        end  
    
%     function   g = plotVectEULM(elem, varargin)
%             % Dibuja las componentes de s de cada junta
%             
%             scaf = chkArg(1, varargin{1:end});
%             [isLM, iSol, scal] = elem.GetParamULM(varargin{2:end});          
%            
%             
%             if ~isempty(varargin)
%                 varargin(1)=[];
%             end
%             for ijunt = 1: elem.GetNJuntas   
%  
%                 [eV, eN]=elem.GeteVeNijuntaULM(ijunt,isLM, iSol, scal);
%                 geome = elem.GetGeomeU(elem.Geome,elem.VectU{iSol},isLM, iSol, scal);
%                 geome = geome(elem.Junta(ijunt,:),:);
%                 P1=geome(1,:);
%                 P2=geome(2,:);
%                 vectS = elem.VectE{iSol}(1+(ijunt-1)*3:3*ijunt)';
%             
%                 N1=ArcoTSAM_f([P1 vectS(1)*eN(1,:) 0]);
%                 N2=ArcoTSAM_f([P2 vectS(2)*eN(1,:) 0]);   
%                 V=ArcoTSAM_f([(P1+P2)/2 vectS(3)*eV(1,:) 0]);              
%                 g=N1.plot(scaf);          
%                 g=N2.plot(scaf);      
%                 g=V.plot(scaf);
%             end
%         end  
    end   
    %methods (Static)
    %end
end

