%% Arco Escarzano
% Maximo factor de carga.
% 
clear all;

%% GEOMETRIA Y TOPOLOGIA
%

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro');
wobinichTamino;
iniMatlabOctave();

ndov=10;
MRB=mpl2RB210(geomEscarzano(8,3,1,ndov), topoRebajado(ndov));

%% Apoyos
% Se renumeran Conex, aunque no es necesario
MRB.elems{1}.Conex(1,:)=[0 0 0];
MRB.elems{ndov}.Conex(2,:)=[0 0 0];
MRB.reSetConex;

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 
subsection ('SetConeS')
MRB.SetConeS;

%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas
subsection ('H')
MRB.GetH;
H = MRB.H;
chk('H', full(sum(sum(H))), 5.76);

%% CALCULO Y CHEQUEO DEL VECTOR DE ACCIONES VARIABLES vectQ 
% La comprobacion solo es valida para una geometria 
subsection ('SetQ & GetQ')
ihip=3;
iele=4;
MRB.SetQ(ihip, iele, [0 1 0]);
vectQ=MRB.Getf(ihip);
chk('Hipotesis Q, gamma=1', sum(vectQ), 2.749503)

%%
% Ht=H';
% HHt=H*Ht;
% f = MRB.Getf(1);
% u=-HHt\f;
% s=Ht*u
% iniFigureArcoTSAM (4);
% 
% MRB.SetVectS(s)
% MRB.SetVectU(u)
% escf=-.25;
% escu=0;
% MRB.plot;
% MRB.plotRjULM(escf, false, 1, escu);

%% CALCULO Y CHEQUEO DEL FACTOR DE CARGA DE COLAPSO PARA vectQ
% La comprobacion solo es valida para vectQ y una geometria

subsection('LP');
gammaQM = MRB.GetMaxGammaLPD(vectQ);
chk('LP', gammaQM, 188.9411)
gammaQMP = MRB.GetMaxGammaLPP(vectQ);
chk('gammaQM LPP==LPD', gammaQM, gammaQMP);

chk('vectU LPP==LPD', MRB.GetVectU(2),MRB.GetVectU(1), 0.000001); 
chk('vectS LPP==LPD', MRB.GetVectS(2),MRB.GetVectS(1), 0.000001);

%% DIBUJOS
%
subsection ('dibujos')

iniFigureArcoTSAM (2);

MRB.plot;
escf=2;
ihip=3;
MRB.plotf(escf, ihip);
escf=1;
ihip=1;
MRB.plotf(escf, ihip);
MRB.plotj;

iniFigureArcoTSAM (3);

MRB.plot;
esca=.25;
iSol=1;
MRB.plotu( false,iSol,esca);
MRB.plotuj(false,iSol,esca);

iniFigureArcoTSAM (4);

escf=-.025;
escu=0;
MRB.plot;
MRB.plotRjULM(escf, false, iSol, escu);

pauseOctaveFig
