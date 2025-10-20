classdef ArcoTSAM_ModeloNL < ArcoTSAM_Modelo
    %ARCOTSAM_MODELONL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        
        %GetVectELM obsoleto: sustituir por GetVectEULM(true,isol)         
        function   e = GetVectELM(obj, varargin)
            % Para el calculo tiene que haberse introducido u. 
            section('GetVectELM obsoleto: sustituir por GetVectEULM(true,isol)')
            section('GetVectELM obsoleto: sustituir por GetVectEULM(true,isol)')
            section('GetVectELM obsoleto: sustituir por GetVectEULM(true,isol)')
            wobinichTamino
            iSol=chkIndex(obj.GetNsol,varargin{:});
            
            if iSol
                e=[];
                nelem = obj.GetNelems;
                for ielem = 1 : nelem
                    %aux=obj.elems{ielem}.GetELM(iSol);
                    aux=obj.elems{ielem}.GetEULM(true, iSol);
                    aux=reshape(aux',size(aux,1)*size(aux,2),1);
                    e(end+1:end+size(aux,1)) = aux;
                end
                e=e';
            end
        end        
     
        function  er = GetVectEr(obj, varargin)
            iSol=chkIndex(obj.GetNsol,varargin{:});

            er = obj.H'*obj.GetVectUAmp(iSol);
            er1= obj.GetVectEULM(true, iSol);
            
            er(1:size(er1,1)) = er(1:size(er1,1))+er1;      
            er(size(er1,1)+1: end) = 0;
          
        end      
 
        function   [e,u] = GetLargeM2(obj, ielem, ijunt, alpha, gammau)
            B=obj.H';
            er=obj.GetVectEr(obj.GetNsol)
            c = gammau*obj.GetCFoHdir(ielem, ijunt, alpha) - er;
            disp('er y s, c y vectE');
            cat(2,er,obj.GetVectS, c, obj.GetVectE)
            S0=diag(obj.GetVectS);
%             nS0=0
%             for is = 1: size(s0,1)
%                 if s0(is,is)~=0
%                 if nS0 == 0
%                     S0=s0(is,:);
%                     nS0=1;
%                 else
%                     S0=cat(1,S0,s0(is,:));
%                 end
%                 end
%             end
            
             x=(B'*B)^-1;
             xx=(B'*S0'*S0*B)^-1;
 
             u = -(B'*S0'*S0*B)\(B'*S0'*(obj.GetVectE-er));
%             %u=-pinv(full(B'*S0*B))*(B'*S0*(obj.GetVectE-er));
%             %u=-pinv(full(B'*S0*B))*(B'*S0*(obj.GetVectE-c));
             cat(2, u, obj.GetVectUAmp)
%             %    (B'*S0*B)\(B'*S0*(obj.GetVectE-er))
             %u = u';
             e = B*u+er
             disp ('--------S0*e=0 (espero)---------------')
             S0*e
             disp ('--------fin S0*e---------------------')
            
            [ns,nu]=size(B);
%[nsr,x]=size(S0);
            M=cat(1, ...
                 cat(2,eye(ns),-B), ...
                 cat(2,S0,zeros(ns,nu)));
            disp('---------size(IBS0)---------')
            
            size(M)
            soeo = S0*obj.GetVectE;
            er1=cat(1,zeros(size(er,1),1),soeo);
            er1=cat(1,-er,-soeo);
            %eu=IBS0\er1;
            eu2 = pinv(full(M'*M))*M'*er1;
            eu=pinv(full(M))*er1;
            
            cat(2,eu,eu2,cat(1,e,u))
            
            %e=eu(1:numel(e));
            %u=eu(numel(e)+1:end);
            
            %cat(2, eu, eu, e1',obj.GetVectS, obj.GetVectE, S0*e1')
            %cat(2,IBS0*eu',er1)
        end
        
        function hdm = GethdirMinLPDLM(obj, ielem, ijunt, alpha, gammau)
            %TODO TODO hay que bautizar a esta funcion
            %TODO TODO hay que bautizar a esta funcion
            % Y unificarla con siguiente
            nHipG=obj.GetNHipts + 1;     
            
            
            % NO se actualiza la posicion de las cargas
            obj.SetG(nHipG);    
            f = obj.Getf(nHipG);
            
            er=obj.GetVectEr(obj.GetNsol); %El anterior
            
            c = gammau*obj.GetCFoHdir(ielem, ijunt, alpha) - er;
            %disp 'GetLargeM: er'
            %cat(2,er,c)
            
            % Y ahora gammau=1 pues ya esa incluido en c
            hdm = GethdirMinLPD(obj, ielem, ijunt, alpha, 1, f, c);
        end
        
        function hdm = GethdirMinLPDLMf(obj, ielem, ijunt, alpha, gammau, varargin)
            nHipG=obj.GetNHipts + 1;     
            
            % Se actualiza la posicion de las cargas
            obj.SetGUNL(nHipG);    
            f = obj.Getf(nHipG);
            
            er=obj.GetVectEr(obj.GetNsol); %El anterior
            
            % TODO TODO: Es posible que no se utilice varargin
            c = gammau*chkArg(obj.GetCFoHdir(ielem, ijunt, alpha), varargin{:})- er;
            %chequeo (solo para fase de depuracion, despues comentar)
            %disp '-------ArcoTSAM_ModeloNL.GetLageMf------------'
            %c'
            %disp '-------ArcoTSAM_ModeloNL.GetLageMf------------'
            % Y ahora gammau=1 pues ya esa incluido en c
            hdm = GethdirMinLPD(obj, ielem, ijunt, alpha, 1, f, c);
        end
        
    end
end

