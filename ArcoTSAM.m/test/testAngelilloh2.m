%% ARCO ANGELILLO
% Calculo de min(h_dir) para LM.
% Indice
%   1. Metodo de NR. En cada iteracion se aproxima e=E(u) por e=B_{t-1}·u

clear all;

%% GEOMETRIA Y TOPOLOGIA
%

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro');
wobinichTamino;
iniMatlabOctave();

ndov = 12;
r=5;
R=8;
MRB=mpl2RB210(geomEscarzano(2*r,r,R-r,ndov), topoRebajado(ndov));
% Apoyos
%MRB.elems{1}.Conex(1,:)=[0 0 0];
%MRB.elems{ndov}.Conex(2,:)=[0 0 0];

%% Chequeo GDL
iniFigureArcoTSAM(1);
MRB.plot;
MRB.plotConex;

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
%

subsection('SetConeS')
MRB.SetConeS;

%% Reacciones

MRB.elems{   1}.ConeS = cat(2, MRB.elems{   1}.ConeS, ...
    [MRB.GetNs+1,   MRB.GetNs+2, MRB.GetNs+3]);

MRB.GetNs;

MRB.elems{ndov}.ConeS = cat(2, MRB.elems{ndov}.ConeS, ...
    [0, 0, 0, MRB.GetNs+1, MRB.GetNs+2, MRB.GetNs+3]);

%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del
% origen de coordenadas

subsection('GetH')
H = MRB.GetH;
chk('H',sum(sum(H)),6);

%% 1  CALCULO DEL EMPUJE MINIMO
% Se comprueba que el resultado es el mismo que el de la seccion 1


subsection ('min hd (tercer calculo)')
minhdir=-7.15;  % Solución obtenida en testRB210c.m
ielem=ndov;
ijunt=2;
alpha=-pi/2;
gammauT=0.8*(2*r);
gammauI=gammauT/40;
gammauI=1/100*r;
minhdirD3=MRB.GethdirMinLPD(ielem, ijunt, alpha, gammauI);
paso=1;
iiter=1;
dbg_VectU=MRB.GetVectU;
dbg_VectS=MRB.GetVectS;
dbg_VectEr=MRB.GetVectEr;
for gammau0=gammauI: gammauI: gammauT
    gammau=gammau0;
    %chk('minhdirD3, min hd (solucion testRB210c.m', minhdirD3, minhdir);
    %minhdirP3=MRB.GethdirMinLPP(ielem, ijunt, alpha, gammau);
    %chk('LPP3, min hd', minhdirP3, minhdir);
    
    %chk('vectU LPP==LPD', sum(MRB.GetVectU-MRB.GetVectU(-1)), 0);
    %chk('vectS LPP==LPD', sum(MRB.GetVectS-MRB.GetVectS(-1)), 0);
    
    %% CORRECCION NL AJUSTANDO B Y POSICION DE f
    % Se ajusta e=E(u) usando la aproximacion e=Bu, donde B es la del origen
    % (u=0) en la primera iteracion y en las siguientes iteraciones la
    % correspondiente a la iteración anterior (metodo NR). En cada iteracion se
    % ajusta el vector f lo cual por lo que en la última iteracion se satisface
    % e=E(u) y las condiciones de equilibrio.
    % La convergencia es significativamente mas lenta, incluso puede no
    % converger el algoritmo. Parece mas eficiente utilizar el metodo de NR
    % modificado, ajustando B cada cierto numero de iteraciones.
    
    niter1 = 10;  % Cuantas veces se actualiza H
    niter0 = 20   % Cuantas veces se itera con cada H
    iniFigureArcoTSAM (21);
    minhdirDiter_1=0;
    LogicalStr = {'false', 'true'}; 
    for i=1: niter1
        
        MRB.plotuLM(MRB.GetNsol);
        MRB.plotf(.1);
        % Se actualiza H
        %HULM{i}=MRB.GetHULM;
        %HULM{i}=MRB.GetH;
        %disp '--------------------------------- iter='
        %i
        %sum(sum(HULM{i}))
        %sum(sum(H))
        %if (mod(i,niter1)==0 )
        fprintf('Se actualiza H\n')
        fprintf('SUM(SUM(H))=%f; sum(Er)=%f\n', sum(sum(full(MRB.H))) ,sum(MRB.GetVectEr))
        HULM{iiter}=MRB.GetHULM;
        %MRB.GetHULM;
        fprintf('SUM(SUM(H))=%f; sum(Er)=%f\n', sum(sum(full(MRB.H))) ,sum(MRB.GetVectEr))
        %end
        for j=1: niter0
            hdir=MRB.GetCFoHdir(ielem, ijunt, alpha);
            %hdir'
            hdiri{iiter}=hdir; 
            % Los que siguen se calculan dentro de la función siguiente.
            er{iiter}=MRB.GetVectEr(MRB.GetNsol); %El anterior
            ci{iiter} = gammau*MRB.GetCFoHdir(ielem, ijunt, alpha)- er{iiter};
            minhdirDiterEr(iiter)=MRB.GethdirMinLPDLMf(ielem,ijunt,alpha, gammau, hdir);   
            minhdirDiter(iiter) =  gammau*hdir'*MRB.GetVectS;
            
            dbg_hdir=hdir;
            dbg_hdirS(iiter)=minhdirDiter(iiter);
            dbg_ErS(iiter)=er{iiter}'*MRB.GetVectS;
            dbg_MinhdirDiterEr=minhdirDiterEr(iiter);
            dbg_VectS=cat(2,dbg_VectS,MRB.GetVectS);
            dbg_VectU=cat(2,dbg_VectU,MRB.GetVectU);
            dbg_VectEr=cat(2,dbg_VectEr,MRB.GetVectEr);
            
            gammaui(iiter)= gammau;
            fprintf ('gammau= %f; hLM(%2d) = %12.6f (fo) ->%12.6f (Er*s) ->%12.6f (%12.6f)\n', ...
                      gammau, iiter, minhdirDiterEr(iiter), ...
                      minhdirDiter(iiter), MRB.GetVectEr'*MRB.GetVectS, ...
                      minhdirDiter(iiter)-minhdirDiterEr(iiter));
            fprintf ('    (err hdir)->%15.15f (err u)->%15.15f (err s)->%15.15f\n', ...
                errMaxVect(minhdirDiter(iiter),minhdirDiter_1), ...
                errMaxVect(dbg_VectU(:,iiter),dbg_VectU(:,iiter+1)), ...
                errMaxVect(dbg_VectS(:,iiter),dbg_VectS(:,iiter+1))); 
            fprintf ('    isEQU=%s, isHEQU=%s\n', ...
                LogicalStr{MRB.isEQU + 1}, LogicalStr{MRB.isHEQU + 1});
            iiter=iiter+1;
 %           if (abs((minhdirDiter(iiter-1)-minhdirDiter_1)/minhdirDiter(iiter-1))<0.0000001)
 %               (MRB.isEQUHi)'
 %           end
            if (abs((minhdirDiter(iiter-1)-minhdirDiter_1)/minhdirDiter(iiter-1))<0.0000001 && MRB.isEQU)
                fprintf ('---------------------------------------cut\n');
                HULM{iiter-1}=MRB.GetHULM;
                break;
            end
            minhdirDiter_1=minhdirDiter(iiter-1);
        end
        fprintf ('-----------Aqui debería continuar cut---\n');
    end
    minddirDiterErPaso(paso)=minhdirDiterEr(iiter-1);
    minddirDiterPaso(paso)=minhdirDiter(iiter-1);
    gammauPaso(paso)=gammau;
    
    %chk('hLM', aux, -3.809666);
    
    pauseOctaveFig
    
    %% DIBUJO
    
    iniFigureArcoTSAM (25);
    %MRB.GetLargeMf(2,1,alpha, gammau)
    MRB.plotuLM(MRB.GetNsol);
    MRB.plotujLM(MRB.GetNsol);
    MRB.plotf(.1);
    MRB.plotRjULM(-.25, 1, MRB.GetNsol, true);
    
    pauseOctaveFig
    
    %% Se clona el MRB
    subsection ('MRBc=MRB.copy')
    MRBc=MRB.copy;
    
    %% Se ajusta la geometria al resultado de la iteracion iiter
    %iiter=niter0*paso;
    subsection ('update geome')
    MRBc.updateGeome(iiter-1);
    
    %% Se borran hipotesis y soluciones de MRBc
    MRBc.clearSol;
    MRBc.clearHipts;
    
    %% Geometria de MRBc
    iniFigureArcoTSAM(30);
    MRB.plotj;
    MRBc.plot;
    
    
    %MRBc.SetConeS;
    
    %% Calculo con la nueva geometria
    
    MRBc.SetG(1);
    f = MRBc.Getf;
    
    %% Funcion objetivo de min (hdir) y la modificada segun NR
    c0 = MRBc.GetCFoHdir(ielem, ijunt, alpha);
 %   MRB.H=HULM{iiter-1};  OJO OJO hay que reajustar esto
    c = gammau*c0 - MRB.GetVectEr(iiter-1);
    
    %% Solucion para la funcion objetivo 'modificada'
    minhdirD4=MRBc.GethdirMinLPD(ielem, ijunt, alpha, 1, f, c)
    MRBc.plotu;
    
    pauseOctaveFig
    
    %% Solucion para la funcion objetivo min(hdir)
    minhdirD0=MRBc.GethdirMinLPD(ielem, ijunt, alpha, gammau, f, c0)
    MRBc.plotu;
    
    %% Chequeo de las dos soluciones obtenidas con la geometria deformada
    % El vector S obtenido
    s4=MRBc.GetVectS;
    chk('minhdir4=c*s4',minhdirD4, c'* s4);
    
    s0=MRBc.GetVectS;
    chk('minhdir0=c0*s0',minhdirD0, gammau*c0'* s0);
    
    chk('s0=s4',s0, s4);
    %MRB=MRBc;
    paso=paso+1;
end
%% Comparacion de los resultados anteriores con los obtenidos iterando
chk(sprintf('minhdir4=minhdirDiterEr(%d)', iiter),minhdirD4, minhdirDiterEr(iiter));

chk(sprintf('MRBc.U(1)=MRB.U(%d)', iiter),MRBc.GetVectU(1), MRB.GetVectU(iiter), 0.00001);

disp 'Interpretacion:'
disp 'El movimento del modelo deformado coincide con el movimento con '
disp 'el que se determina dicho estado deformado. La interpretacion '
disp 'es la misma que la del analisis de segundo orden'

disp 'nu=10 vz /D'
10*gammau/(2*r)
disp 'fz/fz,0'
[minhdirD0/minhdirD3, minhdirD3/minhdirD0]
