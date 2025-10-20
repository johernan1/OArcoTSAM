%% DOLMEN
% Calculo de min(h_dir) para LM
% Indice
%   1. Metodo de NR. En cada iteracion se aproxima e=E(u) por e=B_{t-1}·u

clear all;

%% GEOMETRIA Y TOPOLOGIA
%

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('Datos/');
wobinichTamino;
iniMatlabOctave();

ndov = 3;
[elem222, ~, elem210] = datos_dolmen; 

RB1 = ArcoTSAM_RB210NL(elem210{1});
RB2 = ArcoTSAM_RB210NL(elem210{2});
RB3 = ArcoTSAM_RB210NL(elem210{3});

MRB = ArcoTSAM_ModeloNL();
MRB.Adds(RB1);
MRB.Adds(RB2);
MRB.Adds(RB3);

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 

subsection('SetConeS')
MRB.SetConeS;

%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas

subsection('GetH')
H = MRB.GetH;
chk('H',sum(sum(H)),37);


%% 1  CALCULO DEL EMPUJE MINIMO
% Se comprueba que el resultado es el mismo que el de la seccion 1

iniFigureArcoTSAM (21);

subsection ('min hd (tercer calculo)')
minhdir=-7.15;  % Solución obtenida en testRB210c.m
apoyoAsiento=MRB.elems{2};
ijunt=1;
alpha=pi;
gammau=1.1;
minhdirD3=MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau);
%chk('LPD3, min hd', minhdirD3, minhdir);
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

for i=1:20 
    MRB.plotuLM(MRB.GetNsol);
    MRB.plotf(.1);
    % Se actualiza H
    HULM{i}=MRB.GetHULM;
    hdir=MRB.GetCFoHdir(apoyoAsiento, ijunt, alpha);
    %hdir'
    minhdirDiterEr(i)=MRB.GethdirMinLPDLMf(apoyoAsiento,ijunt,alpha, gammau, hdir);
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
iiter=20;
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

%% Funcion objetivo de min (hdir) y la modificada segun NR
c0 = MRBc.GetCFoHdir(apoyoAsiento, ijunt, alpha);
MRB.H=HULM{iiter};
c = gammau*c0 - MRB.GetVectEr(iiter);

%% Solucion para la funcion objetivo 'modificada' 
minhdirD4=MRBc.GethdirMinLPD(apoyoAsiento, ijunt, alpha, 1, f, c)
MRBc.plotu;

pauseOctaveFig

%% Solucion para la funcion objetivo min(hdir)
minhdirD0=MRBc.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau, f, c0)
MRBc.plotu;

%% Chequeo de las dos soluciones obtenidas con la geometria deformada 
% El vector S obtenido 
s4=MRBc.GetVectS;
chk('minhdir4=c*s4',minhdirD4, c'* s4);

s0=MRBc.GetVectS;
chk('minhdir0=c0*s0',minhdirD0, gammau*c0'* s0);

chk('s0=s4',s0, s4);

%% Comparacion de los resultados anteriores con los obtenidos iterando
chk(sprintf('minhdir4=minhdirDiterEr(%d)', iiter),minhdirD4, minhdirDiterEr(iiter));

chk(sprintf('MRBc.U(1)=MRB.U(%d)', iiter),MRBc.GetVectU(1), MRB.GetVectU(iiter));
[MRBc.GetVectU(1), MRB.GetVectU(iiter)]
disp 'Interpretacion:'
disp 'El movimento del modelo deformado coincide con el movimento con '
disp 'el que se determina dicho estado deformado. La interpretacion '
disp 'es la misma que la del analisis de segundo orden'