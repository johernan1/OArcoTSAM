classdef ArcoTSAM_RB210NL < ArcoTSAM_RB210
    %ARCOTSAM_RB210NL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
                                
        function obj = ArcoTSAM_RB210NL(geomconex)
            if ~nargin
                geomConex={};
            else
                geomConex=geomconex;
            end
            % Call superclass constructor before accessing object
            obj = obj@ArcoTSAM_RB210(geomConex);
        end
        
        function geo = GetGeomeUNL_obsoleta (obj, varargin) 
            iSol=chkIndex(obj.GetNsol,varargin{:});
            geo=obj.Geome;
            vectU=obj.VectU{iSol};
            C=cos(vectU(3));
            S=sin(vectU(3));
            for iver = 1: obj.GetNVerti
                geo(iver,:)= ... 
                     [vectU(1) vectU(2)]+ ...
                     [geo(iver,1) geo(iver,2)]*[[C -S] 
                                                [S  C]];
            end
        end
        
        function   g = plotuNL_obsoleta(obj, varargin) 
            % Esta función y plotu de ArcoTSAM_RB210 son casi identicas
            % Con un 'flag' podrían unificarse 
            
            nsol=chkIndex(obj.GetNsol,varargin{:});
            
            % Ha que comprobar que esta definido obj.VectU
            % Falta try
            geome=obj.GetGeomeUNL(varargin{:})
            g = fill([geome(:,1); geome(1,1)], ...
                     [geome(:,2); geome(1,2)], 'c');
        end
              
        function   g = plotujNL_obsoleta(obj, varargin)
            % Dibujo de las juntas en la posición deformada
            nsol=chkIndex(obj.GetNsol,varargin{:});
            
            % Ha que comprobar que esta definido obj.Vectu
            % Falta try
            MatJU=obj.MatJU{nsol};
            for ijun = 1: obj.GetNJuntas
                geome=obj.Geome(obj.Junta(ijun,:),:);
                vectU=MatJU(ijun,:);
                C=cos(vectU(3));
                S=sin(vectU(3));

                for iver = 1: 2 %Numero de vertices de cada junta
                    geome(iver,:)= ...
                        [vectU(1) vectU(2)]+ ...
                        [geome(iver,1) geome(iver,2)]*[[C -S]
                                                       [S  C]];
                end
                g = plot([geome(:,1); geome(1,1)], ...
                         [geome(:,2); geome(1,2)],'b','LineWidth',2);
            end
        end
        
        function   e = GetELM_obsoleto(obj, varargin)
            % Calculo manual del vector eNL.
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
            % NL. Se elige como eV el correspondiente al eN minimo 
            % 
            % Devuelve los eN en cada extremo de la junta el valor de eV 
            
            nsol=chkIndex(obj.GetNsol,varargin{:});
            
            geome=obj.Geome;
            vectUSol=obj.VectU{nsol};
            C=cos(vectUSol(3));
            S=sin(vectUSol(3));
            
            for ijunta=1 : obj.GetNJuntas
                vectUJunt=obj.MatJU{nsol}(ijunta, :);
                CJ=cos(vectUJunt(3));
                SJ=sin(vectUJunt(3));
                [ev en] = obj.GeteVeNijunta(ijunta);
                for iv=1 : 2 % Los vertices de la junta

                    iver=obj.Junta(ijunta,iv);
                    vectPosSol=[vectUSol(1) vectUSol(2)]+ ...
                        [geome(iver,1) geome(iver,2)]*[[C -S]
                                                       [S  C]];
                    vectPosJunta=[vectUJunt(1) vectUJunt(2)]+ ...
                        [geome(iver,1) geome(iver,2)]*[[CJ -SJ]
                                                       [SJ  CJ]];
                    eN(iv) =  -(vectPosSol- vectPosJunta) *en';     
                    eV(iv) =  -(vectPosSol- vectPosJunta) *ev';                            
                end
                if eN(1)<eN(2)
                    eV1=eV(1);
                else
                    eV1=eV(2);
                end
                e(ijunta,:)=[eN eV1];
            end      
        end
        
        % Esta funcion podria/deberia serlo de ArcoTSAM_RB
        function cdg = GetCdgULM_obsoleto(obj, varargin)
            
            %nsol=chkIndex(obj.GetNsol,varargin{:});
  
            %scal = chkArg(1, varargin{:});
            %iSol = chkIndex(obj.GetNsol, varargin{2:end});
            %isLM = chkArg(false, varargin{3:end}); 
            
            % Ha que comprobar que esta definido obj.Vectu
            % Falta try
            isol = chkIndex(obj.GetNsol,varargin{:});
            isLM = chkArg(true, varargin{2:end});
            
            geome=obj.Geome;
            vectUSol=obj.VectU{isol};
            
            geome=obj.GetGeomeU(geome, vectUSol, 1,0,isLM);
            
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
        
    end
    
end

