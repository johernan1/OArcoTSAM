%% DOLMEN
% Calculo de min(h_dir) para LM
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

ndov =3;
MRB=mpl2RB210(geomEscarzano(10,5,1,ndov), topoRebajado(ndov));
% Apoyos
MRB.elems{1}.Conex(1,:)=[0 0 0];
MRB.elems{ndov}.Conex(2,:)=[0 0 0];

%% Chequeo GDL
iniFigureArcoTSAM(1);
MRB.plot;
MRB.plotConex;

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 

subsection('SetConeS')
MRB.SetConeS;

%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas

subsection('GetH')
H = MRB.GetH;
chk('H',sum(sum(H)),6);


%% 1  CALCULO DEL EMPUJE MINIMO
% Se comprueba que el resultado es el mismo que el de la seccion 1

iniFigureArcoTSAM (21);

subsection ('min hd (tercer calculo)')
minhdir=-7.15;  % Solución obtenida en testRB210c.m
%ielem=2;
%ijunt=1;
%alpha=pi;
%gammau=1.1;
ielem=MRB.GetNelems;
ijunt=2;
alpha=pi*0;
gammau=.9;
minhdirD3=MRB.GethdirMinLPP(ielem, ijunt, alpha, gammau)


%% CORRECCION NL AJUSTANDO B Y POSICION DE f
% Se ajusta e=E(u) usando la aproximacion e=Bu, donde B es la del origen 
% (u=0) en la primera iteracion y en las siguientes iteraciones la 
% correspondiente a la iteración anterior (metodo NR). En cada iteracion se
% ajusta el vector f lo cual por lo que en la última iteracion se satisface 
% e=E(u) y las condiciones de equilibrio.
% La convergencia es significativamente mas lenta, incluso puede no
% converger el algoritmo. Parece mas eficiente utilizar el metodo de NR
% modificado, ajustando B cada cierto numero de iteraciones.

for i=1:21 
    MRB.plotuLM(MRB.GetNsol);
    MRB.plotf(.1);
    % Se actualiza H
    if (mod(i,7)==0)
        fprintf('Se actualiza H\n')
        fprintf('SUM(SUM(H))=%f; sum(Er)=%f\n', sum(sum(full(MRB.H))) ,sum(MRB.GetVectEr))
        HULM{i}=MRB.GetHULM;
        fprintf('SUM(SUM(H))=%f; sum(Er)=%f\n', sum(sum(full(MRB.H))) ,sum(MRB.GetVectEr))
    end
    HULM{i}=MRB.H;
    hdir=MRB.GetCFoHdir(ielem, ijunt, alpha);
    hdirIter{i}=hdir;
    minhdirDiterEr(i)=MRB.GethdirMinLPDLMf(ielem,ijunt,alpha, gammau, hdir);
    minhdirDiter(i) =  gammau*hdir'*MRB.GetVectS;
    fprintf ('hLM(%2d) = %12.6f (fo) -> %12.6f (hdir)\n', i, ...
        minhdirDiterEr(i), minhdirDiter(i));
end
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
iiter=21;
subsection ('update geome')
MRBc.updateGeome(iiter);

%% Se borran hipotesis y soluciones de MRBc
MRBc.clearSol;
MRBc.clearHipts;

%% Geometria de MRBc
iniFigureArcoTSAM(30);
MRBc.plot;


%MRBc.SetConeS;

%% Calculo con la nueva geometria

MRBc.SetG(1);
f = MRBc.Getf;

%% Se comprueba que H es la misma utilizada en el proceso iterativo
MRBc.GetH;
chk('MRB.H=MRBc.H',full(sum(sum(MRBc.H-HULM{iiter}))),0)

%% Funcion objetivo de min (hdir) y la modificada segun NR
c0 = MRBc.GetCFoHdir(ielem, ijunt, alpha);
MRB.H=HULM{iiter};
c = gammau*c0 - MRB.GetVectEr(iiter);

%% Solucion para la funcion objetivo 'modificada' 
minhdirD4=MRBc.GethdirMinLPD(ielem, ijunt, alpha, 1, f, c)
s4=MRBc.GetVectS;
MRBc.plotu;

pauseOctaveFig

%% Solucion para la funcion objetivo min(hdir)
minhdirD0=MRBc.GethdirMinLPD(ielem, ijunt, alpha, gammau, f, c0)
s0=MRBc.GetVectS;
MRBc.plotu;

%% Chequeo de las dos soluciones obtenidas con la geometria deformada 
% El vector S obtenido 

chk('minhdir4=c*s4',minhdirD4, c'* s4);
chk('minhdir0=c0*s0',minhdirD0, gammau*c0'* s0);

chk('s0=s4 (MRBc.GetVectS{1}=MRBc.GetVectS{2})',s0, s4);

chk('MRB.GetVectS=MRBc.GetVectS', MRB.GetVectS, MRBc.GetVectS);

%% Comparacion de los resultados anteriores con los obtenidos iterando
%chk(sprintf('minhdir4=minhdirDiterEr(%d)', iiter),minhdirD4, minhdirDiterEr(iiter));

chk(sprintf('MRBc.U(1)=MRB.U(%d)', iiter),MRBc.GetVectU(1), MRB.GetVectU(iiter));

disp 'Interpretacion:'
disp 'El movimento del modelo deformado coincide con el movimento con '
disp 'el que se determina dicho estado deformado. La interpretacion '
disp 'es la misma que la del analisis de segundo orden'