classdef ArcoTSAM_rst < ArcoTSAM_RBs
    %ArcoTSAM_rst Summary of this class goes here
    %   Detailed explanation goes here   
    
    properties
        NgdlCoeff;
        ConeS
        Conex
    end
    
    
    methods
        % NgdlCoeff - 'coordenadas' de las ligaduras: [NL x 2] double.
        % 'Coordenadas' del iNsCoeff: iNsCoeff=coeff(iNL,:);
        % iNsCoeff es [1x2] double
        %
        % See also
        function obj = set.NgdlCoeff(obj, ngdlCoeff)
            if mod(size(ngdlCoeff,2),2)  ~= 0
                error('set.NsCoeff: El numero de componentes debe ser par')
            else
                obj.NgdlCoeff = ngdlCoeff;
            end
        end
        
        function   activate(obj, ns0, nx0)
            obj.ConeS=[];
            for ielem = 1 : numel(obj.elems)
                %coneS=obj.elems{ielem}.ConeS;
                ns=obj.elems{ielem}.GetNs;
                ngdl=obj.elems{ielem}.GetNGdl;
                %newConeS=zeros(1,ngdl+ns)
                obj.elems{ielem}.ConeS(ngdl+ns-3+obj.NgdlCoeff(ielem,1))=ns0;
                obj.ConeS=[obj.ConeS,ns0];
                ns0=ns0+1;
            end
            obj.Conex=nx0;
        end
        
        function   c = GetConeS(obj)
            c=obj.ConeS;
        end
        %
        %         function   c = GetConeSNA(obj)
        %             c=obj.ConeS;
        %         end
        
        function   c = GetConeSNAl(obj)
            c=obj.ConeS~=0;
        end
        
        function   c = GetConeSNPl(obj)
            c=obj.ConeS==0;
        end
        
        %         %function   c = GetConeSNP(obj)
        %         %
        %         %end
        %
        function   c = GetConex(obj)
            c=obj.Conex;
        end
        
        function  nc = GetMaxConex(obj)
            nc=obj.Conex;
        end
        
        function   iH = GetH(obj)
            iH = obj.NgdlCoeff(:,2)';
        end;
        
        function  ns = GetNsAmp(obj)
            ns = obj.GetNelems;
        end
        
        function  n = GetNGdl(obj)
            n = 1;
        end
        
        function   f = Getf(obj, varargin)
            f=0;
        end
        
        function    SetG(obj, iHip)
        end
        
        function   m = GetMaxConeS(obj)
            m = max(obj.ConeS);
        end
        
        function   l = GetConeSl(obj)
            l =  obj.GetConeS~=0;
        end
        
        
        function  ns = GetNsol(obj)
            fprintf('ArcoTSAM_rst GetNsol: TODO -> cuando se defina VectU debe ser similar a la de ArcoTSAM_RB\n');
            ns = 0;
            for ielem = 1: obj.GetNelems
                ns = max(ns, obj.elems{ielem}.GetNsol);
            end
        end
        
        function       adds(obj,vectS, varargin)
            fprintf('ArcoTSAM_rst adds: TODO -> cuando se defina VectS debe ser similar a la de ArcoTSAM_RB\n');
            
            %obj.SetVectS(vectS, varargin{:});
        end
        
        function       addju(obj, vectU, varargin)
        end
        
        function       addu(obj, vectU, isol, varargin)
            fprintf('ArcoTSAM_rst addu: TODO -> cuando se defina VectU debe ser similar a la de ArcoTSAM_RB\n');
            
        end
        
        function       adde(obj, vectE, nsol, varargin)
            fprintf('ArcoTSAM_rst adde: TODO -> cuando se defina VectE debe ser similar a la de ArcoTSAM_RB\n');
            %obj.SetVectE(vectE,nsol,varargin{:})
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
    end
end

