classdef ArcoTSAM_Rst < ArcoTSAM_RBs
    %ArcoTSAM_rst Summary of this class goes here
    %   Detailed explanation goes here   
    
    properties
        RstAng;
        % Ver las explicaciones de ArcoTSAM_RB
        ConeS
        Conex
        VectU={};
        VectS={};
        VectE={};

    end
    
    
    methods
        % RstAng - 'coordenadas' de las ligaduras: [NL x 2] double.
        % 'Coordenadas' del iRstAng: iRstAng=RstAng(iNL,:);
        % iRstAng [1x2] double
        % Cada RB esta constituido por varios elementos: las juntas
        % y el propio RB
        % iRstAng(1): entero que indica el elemento ligado (ijunta o RB)
        % iRstAng(2): angulo que forma en planta el RB
        %
        % See also
        function obj = set.RstAng(obj, rstAng)
            if mod(size(rstAng,2),2)  ~= 0
                error('set.NsCoeff: El numero de componentes debe ser par')
            else
                obj.RstAng = rstAng;
            end
        end
        
        function   ns = GetNs(obj)
            nelem=obj.GetNelems;
            ns=0;
            for ielem = 1 : nelem                 % +1 solido
                ns = ns+(obj.elems{ielem}.GetNJuntas+1)*3;
            end
        end
        
        function nsf = SetConeS(obj,ns0)
            % 3*GetNelems es el número de ConeS activas
            % Por cada sólido/elemento de la restricción/clave se 
            % introducen tres nuevos 'esfuerzos/fuerzas interiores'.
            % En GetH se establece el equilibrio de la 'clave', es decir se 
            % establece el equilibrio de todos los elementos que definen la 
            % en función de los 'esfuerzos/fuerzas interiores' anteriores.
            %
            % GetNs devuelve todas las Ns, incluidas las 'no activas'
            % Cada RB estaba formado por juntas y un solido, como se pueden
            % ligar juntas o sólidos habrá componentes de 's' no activas
            
            obj.ConeS = zeros(1,obj.GetNs);
            iConeS=0;
            nelem=obj.GetNelems;
            for ielem = 1 : nelem
                njunt=obj.elems{ielem}.GetNJuntas;

                nsf =  ns0+3;
                iRst=obj.RstAng(ielem,1);
                % En RB.GetH se introducen primero las juntas y después
                % el sólido. Para que al incluir las condiciones en RstAng
                % si el primer termino es 1 se enlace RB 8y no las juntas),
                % se 'decala' iRst
                
                iRst=mod(iRst+njunt-1,njunt+1)+1;
                icones=3*(iRst-1);
                iconesfinal=3*njunt+3+iConeS;
                iConeS=iConeS+icones;
                obj.ConeS(iConeS+1:iConeS+3) = [ns0+1:nsf];
                obj.elems{ielem}.ConeS(icones+1+3*njunt: ...
                    icones+3+3*njunt) = [ns0+1:nsf];
                ns0=nsf;
                iConeS=iconesfinal;
            end
        end

        function obj = set.Conex(obj, conex)
            obj.Conex = conex;
        end   
        
        function   c = GetConeS(obj)
            c=obj.ConeS;
        end
        
        function   c = GetConeSNAl(obj)
            c=obj.ConeS~=0;
        end
        
        function   c = GetConeSNPl(obj)
            c=obj.ConeS==0;
        end
        
        function   c = GetConex(obj)
            c=obj.Conex;
        end
               
        function   c = GetConexf(obj)
            c=[];
        end
        
        function  nc = GetMaxConex(obj)
            nc=max(obj.Conex);
        end
        
        function   iH = GetH(obj)
            iH=[];
            nelem=obj.GetNelems;
            for ielem = 1 : nelem
                njunt = obj.elems{ielem}.GetNJuntas;
                % El siguiente for hasta njunt+1 pues se plantea el
                % equilibrio de las juntas y el solido. Recordar que
                % Cada RB esta constituido por varios elementos: las juntas
                % y el propio RB.
                % Será coneS quien determina que columnas de iH estén
                % activas.
                c = cos(obj.RstAng(ielem,2));
                s = sin(obj.RstAng(ielem,2));
                for ijunt = 1: njunt+1
                    % Primera y segunda fila equx, equy
                    % Tercera fila equz
                    % cuarta y quinta fila equMx, equMy
                    %
                    % Primera columna Sx (en plano MRB)
                    % Segunda columna Sz (eje z)
                    % Tercera columna Sm (momento en plano MRB)
                    ih = [-c           0          0;
                          -s           0          0;
                           0          -1          0;
                           0           0          s;
                           0           0         -c];
                    iH=[iH,ih];
                end
            end
        end;
        
        
        function  ns = GetNsAmp(obj)
            ns = obj.GetNs;
        end
        
        function  n = GetNGdl(obj)
            n = 5;
        end
        
        function   f = Getf(obj, varargin)
            f=zeros(1,5);
        end
        
        function    SetG(obj, iHip)
        end
        
        function   m = GetMaxConeS(obj)
            m = max(obj.ConeS);
        end
        
        function   l = GetConeSl(obj)
            l =  obj.GetConeS~=0;
        end
        
        function   ub = GetUb(obj)
            ub = Inf*obj.GetConeSl;
        end
        
        function   lb = GetLb(obj)
            lb = -Inf*obj.GetConeSl;
        end
        
        function  ns = GetNsol(obj)
            ns = numel(obj.VectU);
        end
        
        function       adds(obj,vectS, varargin)
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            cs=obj.GetConeS;
            ivectS=[];
            ivectS(cs~=0)=vectS(cs(cs~=0));
            obj.VectS{nsol}=ivectS';
        end
        
        function       addju(obj, vectU, varargin)
        end   
        

        
        function       addu(obj, vectU, varargin)
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            %wobinichTamino;fprintf('nsol=%d\n', nsol);
            % u es el vector de movimientos del cdg del solido/junta en el
            % plano xy (en planta)
            u=vectU(obj.Conex);
            obj.VectU{nsol}=u;
            
            % Se asigna uy (desplazamiento en el plano perpendicular al
            % plano) a los elementos de la restricción       
            nelem=obj.GetNelems;
            for ielem = 1 : nelem               
                iRst=obj.RstAng(ielem,1);
                if iRst==1 % Se ha ligado el cdg de sólido  
                    % uElem es el vector de movimientos del solido ielem 
                    % (no el de la restricción que es el u ya definido)
                    uElem=obj.elems{ielem}.VectU{nsol};
                    xz=obj.elems{ielem}.GetCdg;
                    x=xz(1); z=xz(2);
                    % iux es la componente del movimiento del cdg del 
                    % sólido sobre el eje x
                    iux=uElem(1)+uElem(3)*z;
                else       % Se ha ligado una junta
                    % uElem es el vector de movimientos del solido ielem 
                    % (no el de la restricción que es el u ya definido)
                    uElem=obj.elems{ielem}.MatJU{nsol};
                    xz=obj.elems{ielem}.GetCdgJunt;
                    x=xz(iRst-1,1); z=xz(iRst-1,2);
                    % iux es la componente del movimiento del cdg de la 
                    % junta sobre el eje x
                    iux=uElem(iRst-1,1)+uElem(iRst-1,3)*z;
                end
                iuy = u(1)*sin(obj.RstAng(ielem,2)) - ...
                     u(2)*cos(obj.RstAng(ielem,2));
                 
                obj.elems{ielem}.VectUy{nsol}=[x,iuy, iux];
            end
        end
        
        function       adde(obj, vectE, nsol, varargin)
            % Con las condiciones actuales siempre debe ser cero
            nsol=chkIndexIn(obj.GetNsol,varargin{:});
            cs=obj.GetConeS;
            cs=cs(cs~=0);
            obj.VectE{nsol}=vectE(cs);
        end
        
        function addUyReacc(obj, varargin)
        end
        function xuy = GetVectUy(obj, varargin)
            xuy=[];
        end
        
        
        function g = plot(obj, varargin)
            global ucs2D
            if ucs2D
                g=plot@ArcoTSAM_RBs(obj, varargin{:});
            else
                % En ArcoTSAM_RBs ucs[AXYZ] es el del conjunto de elementos
                % Aquí se reinterpreta y es un(os) vector(es) con el ucs
                % de cada uno de los elemntos de la ligadura
                % Si el numero de lementos de la ligadura no es igual que
                % el de ucs[AXYZ] no se dibuja nada. Esto pude ocurrir
                % cuando se ligan 'a mano' elementos. Las funciones
                % clave.m y clavej.m que crean automaticamente las
                % ligaduras definen estas ucs de forma coherente
                nelem=numel(obj.elems);
                if  numel(obj.ucsA)== nelem && ...
                        numel(obj.ucsX)== nelem && ...
                        numel(obj.ucsY)== nelem && ...
                        numel(obj.ucsZ)== nelem
                    global ucs;
                    olducs=ucs;
                    g = [];
                    for ielem = 1 : nelem
                        ucs.alpha=obj.ucsA(ielem);
                        ucs.x0=obj.ucsX(ielem);
                        ucs.y0=obj.ucsY(ielem);
                        ucs.z0=obj.ucsZ(ielem);
                        g = union (g, obj.elems{ielem}.plot);
                    end
                    ucs=olducs;
                else
                    fprintf ('ArcoTSAM_rst.plot. No definido ucs\n');
                    fprintf ('ArcoTSAM_rst.plot. name=%s\n', obj.name);
                    g = [];
                end
            end
        end
        
        function g = plotn(obj, varargin)
            global ucs2D
            if ucs2D
                g=plotn@ArcoTSAM_RBs(obj, varargin{:});
            else
                g = [];
            end
        end
      
        function g = plotname(obj, varargin)
            global ucs2D
            if ucs2D
                g=plotname@ArcoTSAM_RBs(obj, varargin{:});
            else
                g = [];
            end
        end  
        
        function g = plotj(obj, varargin)
            % TODO: Añadiendo una condicion se debe dibujar
            % plotu@ArcoTSAM_RB(obj, varargin{:})
            g = [];
        end
        
        function g = plotu(obj, varargin)
            % TODO: Añadiendo una condicion se debe dibujar
            % plotu@ArcoTSAM_RB(obj, varargin{:})
            g = [];
        end
        function g = plotuj(obj, varargin)
            % TODO: Añadiendo una condicion se debe dibujar
            % plotu@ArcoTSAM_RB(obj, varargin{:})
            g = [];
        end
        function   g = plotRjULM(obj, varargin)
            % TODO: Añadiendo una condicion se debe dibujar
            % plotu@ArcoTSAM_RB(obj, varargin{:})
            g = [];
        end
        function   g = plotf(obj, varargin)
            % TODO: Añadiendo una condicion se debe dibujar
            % plotu@ArcoTSAM_RB(obj, varargin{:})
            g = [];
        end
    end
end

