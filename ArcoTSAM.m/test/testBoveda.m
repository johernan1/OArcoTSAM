%% Bovedas
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
iniFigureArcoTSAM (1);

ndov=11;
MRBa=mpl2RB210(geomEscarzano(8,3,1,ndov), topoRebajado(ndov));
geomE = geomEscarzano(8,3,1,ndov);
%geomE(:,1)=geomE(:,1)+12;
MRBb=mpl2RB210(geomE, topoRebajado(ndov));
MRBb.MoveConex(100)

MRB = ArcoTSAM_Modelo();

MRBb.ucsA=pi/4;
MRB.Adds(MRBa);
MRB.Adds(MRBb);

MRB.plot

%% Apoyos
% Se renumeran Conex, aunque no es necesario
MRBa.elems{1}.Conex(1,:)=[0 0 0];
MRBa.elems{ndov}.Conex(2,:)=[0 0 0];
MRBa.reSetConex;
MRBb.elems{1}.Conex(1,:)=[0 0 0];
MRBb.elems{ndov}.Conex(2,:)=[0 0 0];
%MRBb.reSetConex;
MRB.plotConex;

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 
subsection ('SetConeS')
%MRBa.SetConeS;
%MRBb.SetConeS;
MRB.SetConeS;

%% rst
%
MRBrstz = ArcoTSAM_rst();
%MRBrst.Adds(MRBa.elems{(ndov+1)/2});
%MRBrst.NgdlCoeff=[[2,1];[2,1]];
%MRBrst.Conex=200;

%MRBrstb = ArcoTSAM_rst();
MRBrstz.Adds(MRBa.elems{(ndov+1)/2});
MRBrstz.Adds(MRBb.elems{(ndov+1)/2});
MRBrstz.NgdlCoeff=[[2,1];[2,1]];

%MRBrstb.Conex=201;

%MRBrstz.activate(MRB.GetNs,MRB.GetNGdl+1);
MRBrstz.activate(200,250);
%MRBrstb.activate(aux+2);
MRB.Adds(MRBrstz);
%MRB.Adds(MRBrstb);

MRBrstx = ArcoTSAM_rst();
MRBrstx.Adds(MRBa.elems{(ndov+1)/2});
MRBrstx.Adds(MRBb.elems{(ndov+1)/2});
MRBrstx.NgdlCoeff=[[1,cos(0)];[1,cos(MRBb.ucsA)]];
%MRBrstx.activate(MRB.GetNs,MRB.GetNGdl+1);
MRBrstx.activate(202,251);
MRB.Adds(MRBrstx);

MRBrsty = ArcoTSAM_rst();
MRBrsty.Adds(MRBa.elems{(ndov+1)/2});
MRBrsty.Adds(MRBb.elems{(ndov+1)/2});
MRBrsty.NgdlCoeff=[[1,sin(0)];[1,sin(MRBb.ucsA)]];
%MRBrsty.activate(MRB.GetNs,MRB.GetNGdl+1);
MRBrsty.activate(202,252);
MRB.Adds(MRBrsty);



%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas
subsection ('H')
H = MRB.GetH;
%chk('H', full(sum(sum(H))), 5.76);

%% CALCULO DEL VECTOR DE ACCIONES PERMANENTES
% Se calcula G. 
% La comprobacione solo es validas para una geometria
subsection ('SetG & GetG')
%MRBb.SetG(1);
MRB.SetG(1);
vectG=MRB.Getf(1);
%chk('Hipotesis G', sum(vectG), 11.879817)

%% CALCULO Y CHEQUEO DEL VECTOR DE ACCIONES VARIABLES vectQ 
% La comprobacion solo es valida para una geometria 
subsection ('SetQ & GetQ')
ihip=3;
iele=4;
MRBa.SetQ(ihip, iele, [0 1 0]);
vectQ=MRB.Getf(ihip);
%chk('Hipotesis Q, gamma=1', sum(vectQ), 2.749503)

%% CALCULO Y CHEQUEO DEL FACTOR DE CARGA DE COLAPSO PARA vectQ
% La comprobacion solo es valida para vectQ y una geometria

subsection('LP');
gammaQM = MRB.GetMaxGammaLPD(vectQ);
%chk('LP', gammaQM, 18.8941)
subsection ('LP')

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


h= MRB.plot;
set(h,'facealpha',.0)
%set(h,'facecolor','r')
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


