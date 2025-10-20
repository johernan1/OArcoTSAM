classdef ArcoTSAM_f
    %ARCOTSAM_F Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Punt
        Comp
    end
    
    methods
        
        function obj = ArcoTSAM_f (PuntComp)
          if ~nargin
              % the default constructor. Needed for array creation
          else
                obj.Punt = PuntComp(1:2);
                obj.Comp = PuntComp(3:5);
          end
        end
        
        function com = GetComp(obj, varargin)
            if size(obj.Comp)==[0 0]
                com = [0 0 0];
            else
                P=chkArg([0,0], varargin{:});
                com = obj.Comp + [0,0, (P(1)-obj.Punt(1))*obj.Comp(2) - ...
                    (P(2)-obj.Punt(2))*obj.Comp(1)];
            end
        end
        
        function sum = plus(f1, f2)
            sum = ArcoTSAM_f;
            sum.Punt = f1.Punt;
            sum.Comp = f1.Comp + f2.GetComp(sum.Punt);
        end
        
        function pro = mtimes(a, f2)
            pro = ArcoTSAM_f;
            pro.Punt = f2.Punt;
            pro.Comp = a*f2.Comp;
        end
        
        function res = minus(f1,f2)
            res = f1+(-1*f2);
        end
        
        function  tf = eq(f1,f2)
            if f1.GetComp([0,0]) == f2.GetComp([0,0])
                tf = true;
            else
                tf = false;
            end
        end
%         
%         function   g = plot(f1,varargin)
%             % TODO: dibujar el momento
%             % TODO: dibujar como poligono similar a ArcoTSAM.maple
%             % TODO: dibujar un texto, el módulo, las componentes,...
%             scal=chkArg(1,varargin{:});
%             g=quiver(f1.Punt(1)-f1.Comp(1)*scal, ...
%                 f1.Punt(2)-f1.Comp(2)*scal, ...
%                 f1.Comp(1)*scal, ...
%                 f1.Comp(2)*scal,0,'m','LineWidth',4);
%         end
%
        function   g = plot(f1, varargin)
            global ucs
            % TODO: dibujar el momento
            % TODO: dibujar como poligono similar a ArcoTSAM.maple
            % TODO: dibujar un texto, el módulo, las componentes,...
            scal=chkArg(1,varargin{:});
            Px=f1.Punt(1)*cos(ucs.alpha)+ucs.x0;
            Py=f1.Punt(1)*sin(ucs.alpha)+ucs.y0;
            Pz=f1.Punt(2)+ucs.z0;
            Cx=scal*f1.Comp(1)*cos(ucs.alpha);
            Cy=scal*f1.Comp(1)*sin(ucs.alpha);
            Cz=scal*f1.Comp(2);
            
            g=quiver3(Px-Cx, Py-Cy, Pz-Cz, ...
                Cx, Cy, Cz ...
                ,0,'m','LineWidth',4);
        end
        
    end
    
end

