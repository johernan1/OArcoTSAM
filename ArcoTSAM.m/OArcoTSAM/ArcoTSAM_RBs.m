classdef ArcoTSAM_RBs < handle
    %ArcoTSAM_RBs Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name;
        elems = {}; % Cell of ArcoTSAM_RB, ArcoTSAM_RBs,... 
        
        % ucs user coordinate system (copiado de Acad)
        ucsA=0;
        ucsX=0;
        ucsY=0;
        ucsZ=0;
        % 
        % ¿Esta propiedad tiene que venir aquí o en las clases heredadas
        % que la utilicen?
        VectUy = {};
    end
    
    
    methods
        
        function obj = Adds(obj,RB)
            obj.elems{size(obj.elems,2)+1} = RB;
        end

        function  nc = GetNConex(obj)
            nc = 0;
            for ielem = 1: obj.GetNelems
                nc = max(nc, obj.elems{ielem}.GetNConex);
            end
        end

        function delJuntas(obj)
            for e = 1:numel(obj.elems)
                obj.elems{e}.delJuntas();
            end
        end

        function obj = joinIfisInContactWith(obj, RBs, nconex)

            if nargin < 3
                nconex = 1+max(obj.GetNConex, RBs.GetNConex);  % valor inicial
            end
            % --- Asegurar que RBs tiene elems ---
            if ~isprop(RBs, 'elems')
                error('El parámetro RBs no tiene la propiedad "elems".');
            end

            % --- Recorrer todos los elementos de obj ---
            for e = 1:numel(obj.elems)
                elemento = obj.elems{e};
                %fprintf("Procesando elemento obj.elems{%d} de tipo %s\n", e, class(elemento));

                % --- Recorrer todos los elementos de RBs ---
                for r = 1:numel(RBs.elems)
                    elementoRB = RBs.elems{r};
                    %fprintf("   Comparando con RBs.elems{%d} de tipo %s\n", r, class(elementoRB));

                    % --- Caso 1: Ambos son contenedores -> recursión ---
                    if isa(elemento, 'ArcoTSAM_RBs') && isa(elementoRB, 'ArcoTSAM_RBs')
                        elemento.joinIfisInContactWith(elementoRB, nconex);
                    % --- Caso 2: Ambos son RB básicos -> función base ---
                    elseif isa(elemento, 'ArcoTSAM_RB') && isa(elementoRB, 'ArcoTSAM_RB')
                        if elemento.joinIfisInContactWith(elementoRB, nconex);
                            nconex=nconex+3;
                        end
                    % --- Caso 3: Uno es RB y otro es contenedor ---
                    elseif isa(elemento, 'ArcoTSAM_RB') && isa(elementoRB, 'ArcoTSAM_RBs')
                        tempContainer = ArcoTSAM_RBs();  % crear contenedor temporal si lo necesitas
                        tempContainer.elems = {elemento};
                        tempContainer.joinIfisInContactWith(elementoRB, nconex);
                        elemento = tempContainer.elems{1};  % obtener RB combinado
                    % --- Caso 4: Uno es contenedor RB y otro es RB ---
                    elseif isa(elemento, 'ArcoTSAM_RBs') && isa(elementoRB, 'ArcoTSAM_RB')
                        MRB=ArcoTSAM_ModeloNL();
                        MRB.Adds(elementoRB);
                        elemento.joinIfisInContactWith(MRB, nconex); % si tienes constructor de contenedor a partir de RB
                    else
                        fprintf("   -> Tipos no compatibles: %s y %s. Se omite.\n", class(elemento), class(elementoRB));
                    end
                end
            end
        end

        function  ne = GetNelems(obj)
            ne = size(obj.elems,2);
        end
        
        function  nh = GetNHipts(obj)
            nh = 0;
            for ielem = 1: obj.GetNelems
                nh = max(nh, obj.elems{ielem}.GetNHipts);
            end
        end
        
        % Esta función puede ser innecesaria si se redefine  Getf
        % Se ha hecho una ñapa para que Getf funcione cuando un
        % elemento de elems{} es un ArcoTSAM_Modelo (normalmente será
        % un ArcoTSAM_RB
%         function   c = GetConexf(obj)
%             c = obj.GetConex;
%         end;

        
        %% plots
        function iniplot(obj)
            global ucs2D;
            global ucs;
            global olducs;
            olducs=ucs;
            if (ucs2D) 
                ucs.alpha=0;
                ucs.x0=0;
                ucs.y0=0;
                ucs.z0=0;
            else 
                ucs.alpha=obj.ucsA;
                ucs.x0=obj.ucsX;
                ucs.y0=obj.ucsY;
                ucs.z0=obj.ucsZ;
                                    
            end
        end;
        
         function endplot(obj)
             global olducs;
             global ucs;
             ucs=olducs;
         end
        
        function   g = plot(obj)
            obj.iniplot;
            
            nelem = obj.GetNelems;
            g = []; 
            for ielem = 1 : nelem
                g = union (g, obj.elems{ielem}.plot);
            end
            obj.endplot;
        end
 
  %      function g = plotf3(obj, varargin)
  %          g = obj.plotf(varargin{:})
  %      end
        
        
  
        function   g = plotf(obj, varargin)
            obj.iniplot;
            hold on
            
            scal=chkArg(1, varargin{:});
            iHip=chkArg(obj.GetNHipts, varargin{2:end});
            
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                if (obj.elems{ielem}.GetNHipts >= iHip)
                    g = obj.elems{ielem}.plotf(scal, iHip);
                    %g = obj.elems{ielem}.Hipts{iHip}.plotR(scal);
                end
            end
            obj.endplot
        end
        
        function   g = plotj(obj)
            obj.iniplot;
            hold on
            nelem = obj.GetNelems;
            g=[];
            for ielem = 1 : nelem
                g = obj.elems{ielem}.plotj();
            end  
            obj.endplot;
        end
                
        function   g = plotn(obj,  varargin)
            obj.iniplot;
            hold on
            
            n=chkArg('', varargin{:});
            
            nelem = obj.GetNelems;
            g=[];
            for ielem = 1 : nelem
                if strcmp(n,'')
                    t =  sprintf('%d', ielem);
                else
                    t = sprintf('%s.%d', n, ielem);
                end
                g = obj.elems{ielem}.plotn(t);
            end  
            obj.endplot;
        end
                    
        function   g = plotname(obj,  varargin)
            obj.iniplot;
            hold on
            
            n=chkArg('', varargin{:});
            
            nelem = obj.GetNelems;
            g=[];
            for ielem = 1 : nelem
                if strcmp(n,'')
                    t =  sprintf('%s', obj.elems{ielem}.name);
                else
                    t = sprintf('%s.%s', n, obj.elems{ielem}.name);
                end
                g = obj.elems{ielem}.plotname(t);
            end  
            obj.endplot;
        end
        
        function   g = plota(obj) %apoyos (de momento solo 0,0,0)
            obj.iniplot;
            hold on
            nelem = obj.GetNelems;
            g=[];
            for ielem = 1 : nelem
                g = obj.elems{ielem}.plota();
            end  
            obj.endplot;
        end
%        function g = plotu3(obj, varargin)
%            g = obj.plotu(varargin{:})
%        end
        
        function   g = plotu(obj, varargin)
            obj.iniplot;
            global interplUy; %2.5D
            interplUy=obj.GetVectUy(varargin{2:end});             
            % Lo que sigue, mas eficiente, no funciona en octave
            % g = obj.plotuLM(false,varargin{2:end})
            if ~isempty(varargin)
                varargin(1)=[];
            end
            g = obj.plotuLM(false, varargin{:});
            obj.endplot;
            interplUy=[];
        end 
        
 %       function g = plotuLM3(obj, varargin)
 %           g = obj.plotuLM(varargin{:})
 %       end
        
        function   g = plotuLM(obj, varargin)
            obj.iniplot;      
            scal = chkArg(1, varargin{3:end});
            iSol = chkIndex(obj.GetNsol,varargin{2:end});
            isLM   = chkArg(true, varargin{1:end});
            
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                g = obj.elems{ielem}.plotu(isLM, iSol, scal);
            end
            obj.endplot
        end  
     
        function   g = plotuj(obj, varargin)
            obj.iniplot;
            global interplUy; %2.5D
            interplUy=obj.GetVectUy(varargin{2:end});   
            % Lo que sigue, mas eficiente, no funciona en octave
            % g = obj.plotujLM(false, varargin{2:end});
            if ~isempty(varargin)
                varargin(1)=[];
            end
            g = obj.plotujLM(false,varargin{:});
            obj.endplot
            interplUy=[];
        end
        
        function   g = plotujLM(obj, varargin)
            obj.iniplot;
            %scal = chkArg(1, varargin{:});
            %iSol = chkIndex(obj.GetNsol, varargin{2:end});
            %LM   = chkArg(true, varargin{3:end});
            
            
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                g = obj.elems{ielem}.plotuj(varargin{:});
            end
           obj.endplot; 
        end 
        
 %       function   g = plotRjULM3(obj, varargin)
 %           g = obj.plotRjULM(varargin{:})
 %       end
        
        function   g = plotRjULM(obj, varargin)
            % Dibuja la posicion de la resultante de las fuerzas en cada
            % junta
            %
            % Parámetros opcionales:
            % scaf - Escala de la resultante, 1 por defecto
            % isLM - Grandes movimientos, true por defecto
            % iSol - Solucion que se dibuja, obj.GetNsol por defecto 
            % scal - Escala de la deformada, 1 por defecto
            
            obj.iniplot;
            scaf = chkArg(1, varargin{1:end});
            isLM = chkArg(false, varargin{2:end});
            iSol = chkIndex(obj.GetNsol, varargin{3:end});
            scal = chkArg(1, varargin{4:end});
            
            for ielem = 1: obj.GetNelems
                %fprintf('junta %d\n',ijun)
                g=obj.elems{ielem}.plotRjULM(scaf, isLM, iSol, scal);
            end
            obj.endplot;
        end        
        
        
        function   g = plotVectSULM(obj, varargin)
            % Dibuja las componentes de S en cada junta
            %
            % Parámetros opcionales:
            % scaf - Escala de la resultante, 1 por defecto
            % isLM - Grandes movimientos, true por defecto
            % iSol - Solucion que se dibuja, obj.GetNsol por defecto 
            % scal - Escala de la deformada, 1 por defecto
            
            obj.iniplot;
            scaf = chkArg(1, varargin{1:end});
            isLM = chkArg(false, varargin{2:end});
            iSol = chkIndex(obj.GetNsol, varargin{3:end});
            scal = chkArg(1, varargin{4:end});
            
            for ielem = 1: obj.GetNelems
                %fprintf('junta %d\n',ijun)
                g=obj.elems{ielem}.plotVectSULM(scaf, isLM, iSol, scal);
            end
            obj.endplot;
        end
        
        function   g = plotVectEULM(obj, varargin)
            % Dibuja la posicion de las componentes de E en cada junta
            %
            % Parámetros opcionales:
            % scaf - Escala de la resultante, 1 por defecto
            % isLM - Grandes movimientos, true por defecto
            % iSol - Solucion que se dibuja, obj.GetNsol por defecto 
            % scal - Escala de la deformada, 1 por defecto
            
            % Se utiliza la función plotSULM, para lo cual se copia el
            % vector e que quiere dibujarse en una nueva 'hipótesis' de s y
            % se dibuja esta 'hipótesis'. Posteriormente se borra 
            
            %obj.iniplot;
            scaf = chkArg(1, varargin{1:end});
            isLM = chkArg(false, varargin{2:end});
            iSol = chkIndex(obj.GetNsol, varargin{3:end});
            scal = chkArg(1, varargin{4:end});
            
            auxiS=obj.GetNsol+1;
            obj.SetVectS(obj.GetVectE(iSol), auxiS);
            obj.SetVectU(obj.GetVectUAmp(iSol), auxiS);
            
            g=obj.plotVectSULM(scaf, isLM, auxiS, scal);
            
%             for ielem = 1: obj.GetNelems
%                  %fprintf('junta %d\n',ijun)
%                  g=obj.elems{ielem}.plotVectSULM(scaf, isLM, auxiS, scal);
%             end
             
            % Pendiente de borrar el vector s extra
            obj.dels(auxiS);
            obj.delu(auxiS);
            %obj.endplot;
        end
               
        function   g = plotVectComoSULM(obj, ComoS, varargin)
            % Dibuja Un vector de las dimensiones de VectS en su posición
            %
            % Parámetros opcionales:
            % scaf - Escala de la resultante, 1 por defecto
            % isLM - Grandes movimientos, true por defecto
            % iSol - Solucion que se dibuja, obj.GetNsol por defecto 
            % scal - Escala de la deformada, 1 por defecto
            
            % Se utiliza la función plotSULM, para lo cual se copia el
            % vector e que quiere dibujarse en una nueva 'hipótesis' de s y
            % se dibuja esta 'hipótesis'. Posteriormente se borra 
            
            %obj.iniplot;
            scaf = chkArg(1, varargin{1:end});
            isLM = chkArg(false, varargin{2:end});
            iSol = chkIndex(obj.GetNsol, varargin{3:end});
            scal = chkArg(1, varargin{4:end});
            
            auxiS=obj.GetNsol+1;
            obj.SetVectS(ComoS, auxiS);
            obj.SetVectU(obj.GetVectUAmp(iSol), auxiS);
            
            g=obj.plotVectSULM(scaf, isLM, auxiS, scal);
            
%             for ielem = 1: obj.GetNelems
%                  %fprintf('junta %d\n',ijun)
%                  g=obj.elems{ielem}.plotVectSULM(scaf, isLM, auxiS, scal);
%             end
             
            % Pendiente de borrar el vector s extra
            obj.dels(auxiS);
            obj.delu(auxiS);
            %obj.endplot;
        end
        
        function   g = plotConex(obj)
            obj.iniplot;
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                g = obj.elems{ielem}.plotConex();
            end
            obj.endplot;
        end
         
         function   g = plotCones(obj)
             obj.iniplot;
             nelem = obj.GetNelems;
             for ielem = 1 : nelem
                 g = obj.elems{ielem}.plotCones();
             end     
             obj.endplot;
         end
         
        
         function       SetRho(obj, rho)
            nelem = obj.GetNelems;
            for ielem = 1 : nelem
                obj.elems{ielem}.rho=rho;
            end
         end  
         
         function       Setb(obj, b)
             nelem = obj.GetNelems;
             for ielem = 1 : nelem
                 obj.elems{ielem}.b=b;
             end
         end
         
         function       delSol(obj, varargin)
             nsol=chkIndex(obj.GetNsol,varargin{:});
             if nsol
                 nelem = obj.GetNelems;
                 for ielem = 1 : nelem
                     obj.elems{ielem}.delSol(nsol);
                 end
             end
         end
         
         function       delu(obj, varargin)
             nsol=chkIndex(obj.GetNsol,varargin{:});
             if nsol
                 nelem = obj.GetNelems;
                 for ielem = 1 : nelem
                     obj.elems{ielem}.delu(nsol);
                 end
             end
         end
         
  
         function       dels(obj, varargin)
             nsol=chkIndex(obj.GetNsol,varargin{:});
             if nsol
                 nelem = obj.GetNelems;
                 for ielem = 1 : nelem
                     obj.elems{ielem}.dels(nsol);
                 end
             end
         end
        
        function   s = GetVectS(obj, varargin)
            
            nsol=chkIndex(obj.GetNsol,varargin{:});

            if nsol
                nelem = obj.GetNelems;
                s=[];
                for ielem = 1 : nelem
                    %class(obj)
                    %fprintf('ArcoTSAM_modelo.GetVectS.ielem=%d,%d\n', ielem,nelem);
                    cs=obj.elems{ielem}.GetConeS;
                    %aux=obj.elems{ielem}.VectS{nsol};
                    %s(end+1:end+size(aux,1)) = aux;
                    %s(obj.elems{ielem}.ConeS) = ...
%                    vectS=obj.elems{ielem}.VectS{nsol};
                    vectS=obj.elems{ielem}.GetVectS(nsol);
                    s(cs(cs~=0)) = vectS(cs~=0);
                end
                s=s';
            end
        end

    end
    
end

