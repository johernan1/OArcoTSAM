%% DOLMEN
% Maximo factor de carga.
% Empuje minimo
% Correccion NL del vector u (solo, sin chequear EQU)
clear all;

%% GEOMETRIA Y TOPOLOGIA
%

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('Datos/');
wobinichTamino;
iniMatlabOctave();

[elem222, elem210, elem210] = datos_dolmen; 

RB1 = ArcoTSAM_RB210NL(elem210{1});
RB2 = ArcoTSAM_RB210NL(elem210{2});
RB3 = ArcoTSAM_RB210NL(elem210{3});

MRB = ArcoTSAM_ModeloNL();
MRB.Adds(RB1);
MRB.Adds(RB2);
MRB.Adds(RB3);

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 

subsection ('SetConeS')
MRB.SetConeS;

%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas

subsection('GetH')
H = MRB.GetH;
chk('H', sum(sum(H))==37);

%% CALCULO DEL VECTOR DE ACCIONES PERMANENTES
% Se calcula G y se asigna a varias hipotesis del modelo. Se hacen algunas
% comprobaciones relativas a las hipotesis del modelo.
% Las comprobaciones solo son validas para una geometria y una posicion del 
% origen de coordenadas

subsection('SetG & GetG')
MRB.SetG(2);
vectG=MRB.Getf(1);
chk('Hipotesis no asignada', sum(vectG)==0)
vectG1=10*MRB.Getf(2);
chk('Hipotesis G, gamma=10', sum(vectG1),31500)
MRB.SetG(1);
vectG2=MRB.Getf(2);
vectG3=MRB.Getf(1);
chk('Hipotesis G, gamma=1', sum(vectG3), 3150)
chk('Suma de hipotesis', sum(vectG1+vectG2), 31500+3150)

%% CALCULO Y CHEQUEO DEL VECTOR DE ACCIONES VARIABLES vectQ 
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas

subsection ('SetQ & GetQ')
ihip=3;
iele=3;
MRB.SetQ(ihip, iele, [1 0 0])
vectQ=MRB.Getf(ihip);
chk('Hipotesis Q, gamma=1', sum(vectQ), -4.0)

%% CALCULO Y CHEQUEO DEL FACTOR DE CARGA DE COLAPSO PARA vectQ
% La comprobacion solo es valida para vectQ y una geometria

subsection('LP');
gammaQM = MRB.GetMaxGammaLPD(vectQ);
chk('LP', gammaQM, 196.957, 0.00003)

%% RESULTADOS
%

subsection('u')
u=MRB.GetVectUAmp;
disp(reshape(u,RB1.nGdlxJ, size(u,1)/RB1.nGdlxJ));
subsection('e')
e=MRB.GetVectE;
disp(reshape(e,RB1.nGdlxJ, size(e,1)/RB1.nGdlxJ));
    
subsection('MRB.GetVectE, MRB.GetVectEULM(false), MRG.GetVectEULM(true)')
disp(cat(2, MRB.GetVectE, MRB.GetVectEULM(false), MRB.GetVectEULM(true)))
chk('GetVectE; GetVectEULM(false)',...
    abs(sum(MRB.GetVectE(1)- MRB.GetVectEULM(false, 1))), 0)

%% DIBUJOS
%

subsection('dibujos')

iniFigureArcoTSAM('Name','testRB210b: RBs');
RB1.plot;
RB2.plot;
RB3.plot;

iniFigureArcoTSAM('Name', 'TestRB210b: plot, plotf, plotj');
MRB.plot;
escf=0.01;
ihip=2;
MRB.plotf(escf,ihip);
MRB.plotj;

iniFigureArcoTSAM('Name', 'TestRB210b: plotu');
MRB.plot;
esca=2;
iSol=1;
MRB.plotu();
MRB.plotuj();
MRB.plotu(false,iSol,esca);
MRB.plotuj(false,iSol,esca);

iniFigureArcoTSAM('Name', 'TestRB210b: plotuLM');
MRB.plot;
%MRB.plotu(1,2);
MRB.plotuLM();
MRB.plotujLM();
%MRB.plotu_provisional(u,0.5);

pauseOctaveFig

%% CALCULO DEL EMPUJE MINIMO
% La comprobacion solo es valida para una geometria

subsection('Empuje minimo');

apoyoAsiento=MRB.elems{2};
ijunt=1;
alpha=pi;
gammau=3;

minhdir=MRB.GethdirMinLPP(apoyoAsiento, ijunt, alpha, gammau);
fprintf('h = %12.6f\n', minhdir);
chk('LPP, min hd', minhdir, -195)

%% CORRECCION NL
%
subsection('Grandes movimientos');

iniFigureArcoTSAM('Name', 'TestRB210b: Grandes movimientos (NO EQU; iter)');
for i=1:10
    fprintf ('alpha=%f,gammau=%f', alpha, gammau);
    aux =  MRB.GethdirMinLPDLM(apoyoAsiento,ijunt,alpha, gammau);
    fprintf ('h = %12.6f\n',aux);
    MRB.plotuLM(MRB.GetNsol);
end
chk('h', aux, -130.9133)

iniFigureArcoTSAM('Name', 'TestRB210b: Grandes movimientos (NO EQU)');

MRB.plotuLM(MRB.GetNsol);

pauseOctaveFig
