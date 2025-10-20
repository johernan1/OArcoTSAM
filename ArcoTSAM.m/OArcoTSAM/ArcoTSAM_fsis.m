classdef ArcoTSAM_fsis < handle
    %ARCOTSAM_FSIS Summary of this class goes here
    %   Sistema de fuerzas
    %
    
    properties
        Punt;
        Comp;
        fsis = {};
    end
    
    methods
            
        function newObj = copy(obj) 
            %wobinichTamino;
            newObj = eval(class(obj));
            for f = obj.fsis
                %class(f{:})
                newObj.addf(f{:});
            end
        end
        
        function   n = GetNf(obj)
            n = size(obj.fsis,2);
        end
        
        function       update(obj)
            % Seguramente esta funcion debia declararse privada
            nfor=obj.GetNf;
            if nfor>=1
                R = obj.fsis{1};
                for ifor = 2 : nfor
                    R = R + obj.fsis{ifor};
                end
                obj.Comp = R.Comp;
                obj.Punt = R.Punt;
            else
                obj.Punt=[];
                obj.Comp=[];
                obj.fsis={};
            end
        end
        
        function       addf(obj, f)
            if ~strcmp(class(f), 'ArcoTSAM_f')
                error('Error. \nInput must be a ArcoTSAM_f, not a %s.', ...
                    class(f))
            end
            obj.fsis{end+1} = f;
            obj.update;
        end
        
        function       delf(obj, varargin)
            %disp '-----ArcoTSAM_fsis'
            %varargin
            nfor=obj.GetNf;
            ifor=chkIndex(nfor,varargin{:});
            obj.fsis(ifor) = [];
            obj.update;
        end
               
        function com = GetComp(obj, varargin)
 %           if size(obj.fsis)==[0 0]
            if obj.GetNf == 0
                com = [0 0 0];
            else
                P=chkArg([0,0], varargin{:});
                com = obj.Comp + [0,0, (P(1)-obj.Punt(1))*obj.Comp(2) - ...
                    (P(2)-obj.Punt(2))*obj.Comp(1)];
            end
        end
            
        function sum = plus(fsis1, fsis2)
            sum = ArcoTSAM_fsis;
            sum.Punt = fsis1.Punt;
            sum.Comp = fsis1.Comp;
            sum.fsis = fsis1.fsis;
            for ifor = 1 : fsis2.GetNf
                sum.addf(fsis2.fsis{ifor});
            end
        end
        
        function pro = mtimes(a, fsis2)
            pro = ArcoTSAM_fsis;
            for ifor = 1 : fsis2.GetNf
                pro.addf(a*fsis2.fsis{ifor});
            end
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
        
        function  tf = ne(f1,f2)
            tf = ~f1.eq(f2);
        end
        
        function   g = plotR(f1,varargin)
            % TODO. Falta dibujar momento
            if f1.GetNf > 0
                scal=chkArg(1,varargin{:});
                g=quiver(f1.Punt(1)-f1.Comp(1)*scal, ...
                    f1.Punt(2)-f1.Comp(2)*scal, ...
                    f1.Comp(1)*scal, ...
                    f1.Comp(2)*scal,0, 'm','LineWidth',4);
            else
                g = plot(0);
            end
        end
            
        function   g = plot(f1, varargin)
            if f1.GetNf > 0
                scal=chkArg(1,varargin{:});
                for ifor = 1 : f1.GetNf
                    g = f1.fsis{ifor}.plot(scal);
                end
            else
                g = plot(0);
            end
        end
    end
    
end

