%% DOLMEN
% Maximo factor de carga.
% Matriz H sobre geometria inicial y final.
% 
clear all;

%% GEOMETRIA Y TOPOLOGIA
%

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('Datos/');
wobinichTamino;
iniMatlabOctave();

[elem222, elem210, elem210b] = datos_dolmen; 

RB1 = ArcoTSAM_RB210(elem210{1});
RB2 = ArcoTSAM_RB210(elem210{2});
RB3 = ArcoTSAM_RB210(elem210{3});

MRB = ArcoTSAM_Modelo();
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
chk('H', sum(sum(H)), 42);

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
chk('Hipotesis G, gamma=10', sum(vectG1), 28000)
MRB.SetG(1);
vectG2=MRB.Getf(2);
vectG3=MRB.Getf(1);
chk('Hipotesis G, gamma=1',  sum(vectG3), 2800)
chk('Suma de hipotesis', sum(vectG1+vectG2), 28000+2800)

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
chk('LP', gammaQM, 100)

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
% chk(abs(sum(MRB.GetVectE(1)- MRB.GetVectEULM(false, 1)))<0.00000000001, ...
%     'GetVectE; GetVectEULM(false)')
chk('GetVectE; GetVectEULM(false)', ...
    sum(MRB.GetVectE(1)- MRB.GetVectEULM(false, 1)),0)

%% DIBUJOS
%

subsection('dibujos')

iniFigureArcoTSAM('Name','testRB210: RB.plot');
RB1.plot;
RB2.plot;
RB3.plot;

iniFigureArcoTSAM('Name', 'TestRB210: MRB.plot, plotf, plotj');
MRB.plot;
escf=0.01;
ihip=2;
MRB.plotf(escf, ihip);
ihip=3;
MRB.plotf(10*escf, ihip);
MRB.plotj;

iniFigureArcoTSAM('Name', 'TestRB210: MRB.plotu');
MRB.plot;
esca=2;
iSol=1;
MRB.plotu();
MRB.plotuj();
% Se modifica la escala del dibujo
MRB.plotu(false,iSol,esca);
MRB.plotuj(false,iSol,esca);

%% CALCULO DE LA MATRIZ H EN LA POSION DEFORMADA
% Se desplaza el 'soporte izquierdo' hasta situarlo sobre el 'derecho' y se
% comparan las matrices H del primero en la posicion final y la del segundo
% en la original: deben coincidir
subsection('TestRB210: GetHLM (EQU en posicion final)')
u=zeros(21,1);
u(10:12)=[4,0,0];
RB1.addu(u);
chk('RB1.GetHLM+[4,0,0]=RB2.GetH', ...
    eval(sprintf('%.8f',sum(sum(RB1.GetHULM-RB2.GetH))))==0);

%% CALCULO DE LA MATRIZ H EN LA POSION DEFORMADA
% Se crea un nuevo solido a partir del RB1 desplazado y girado. Se comparan
% la matrices H del primero en la posición final y la del nuevo solido:
% deben ser iguales
iu=[1.5,1,pi/4];
u(10:12)=iu;
RB1.adds(RB1.VectS{1});
RB1.addu(u);
RB4 = ArcoTSAM_RB210;
RB4.Geome=RB1.GetGeomeU(RB1.Geome, iu, true, 0, 1);
RB4.Junta=RB1.Junta;

chk('RB1.GetHLM+[1.5,1,Pi/4]=RB4.GetH', ...
    eval(sprintf('%.8f',sum(sum(RB1.GetHULM-RB4.GetH))))==0);

%% DIBUJOS
%
iniFigureArcoTSAM('Name', 'TestRB210: Geom de RB4: RB4=RB1+[1.5,1,pi/4]');

RB1.plot;
RB4.plot;

pauseOctaveFig

iniFigureArcoTSAM('Name', 'TestRB210: Resultante en cada junta');
RB1.plot;
escf=.01;
escau=2;
iSol=3;
RB1.plotRj(escf, iSol);
%RB1.plotu(esca, RB1.GetNsol);

iniFigureArcoTSAM('Name','TestRB210: Resultante en cada junta(plotRjULM)');
RB1.plotu(false, iSol, escau);
RB1.plotu(false, iSol, escau/2);
RB1.plotRjULM(escf, false, iSol, escau);
RB1.plotRjULM(escf,  true, iSol, escau);
RB1.plotRjULM(escf, false, iSol, escau/2);
RB1.plotRjULM(escf,  true, iSol, escau/2);
RB1.plotu(true, iSol, escau);
RB1.plotu(true, iSol, escau/2);

iniFigureArcoTSAM('Name', 'TestRB210:  Trayectoria de fuerzas');
MRB.plot;
MRB.plotRjULM(-2*escf, false, 1, 0);
MRB.plotf(2*escf, 1);

pauseOctaveFig
