%% Bovedas
% Maximo factor de carga.
% 
clear all;

%% GEOMETRIA Y TOPOLOGIA
%

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro');
addpath('Datos');

wobinichTamino;
iniMatlabOctave();

topoBovedaVandelvira;


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
% MRB01.SetQ(ihip, iele, [0 1 0]);
% MRB02.SetQ(ihip, 2, [0 1 0]);
% MRB03.SetQ(ihip, iele, [0 1 0]);
MRB01.SetQ(ihip, 5, [0 1 0]);
vectQ=MRB.Getf(ihip);
%chk('Hipotesis Q, gamma=1', sum(vectQ), 2.749503)
f=iniFigureArcoTSAM(201);
if amImatlab f.Name='vectG+Q'; end;

MRB.plot;
escf=2;
ihip=3;
MRB.plotf(escf, ihip);
escf=1;
ihip=1;
g=MRB.plotf(escf, ihip);
set(g,'facealpha','b')


%% CALCULO Y CHEQUEO DEL FACTOR DE CARGA DE COLAPSO PARA vectQ
% La comprobacion solo es valida para vectQ y una geometria

subsection('LP');
gammaQM = MRB.GetMaxGammaLPD(vectQ);
%chk('LP', gammaQM, 18.8941)
subsection ('fin LP')

%% DIBUJO Resultados 3D
%
subsection ('dibujos 3D')

% iniFigureArcoTSAM (2);
% 
% MRB.plot;
% escf=2;
% ihip=3;
% MRB.plotf(escf, ihip);
% escf=1;
% ihip=1;
% MRB.plotf(escf, ihip);
% MRB.plotj;

f=iniFigureArcoTSAM (302);
if amImatlab f.Name='LP'; end;

iSol=1;
escf=-.25/20;
escu=0;
MRB.plot;
MRB.plota;
MRB.plotRjULM(escf, false, iSol, escu);

pauseOctaveFig

f=iniFigureArcoTSAM (301);
if amImatlab f.Name='MEC'; end

h= MRB.plot;
set(h,'facealpha',.0)
%set(h,'facecolor','r')
esca=.25/8;
%esca=1;
iSol=1;
MRB.plotu( false,iSol,esca);
MRB.plotuj(false,iSol,esca);

%% DIBUJO Resultados 2D
%
subsection ('dibujos 2D')

ucs2D = true;

f=iniFigureArcoTSAM (402);
if amImatlab f.Name='LP'; end;

MRB.plot;
MRB.plota;
MRB.plotRjULM(escf, false, iSol, escu);

pauseOctaveFig

f=iniFigureArcoTSAM (401);
if amImatlab f.Name='MEC'; end

h= MRB.plot;
set(h,'facealpha',.0)
MRB.plotu( false,iSol,esca);
MRB.plotuj(false,iSol,esca);



%% Chequeos
%

subsection('Chequeo desplazamientos. Clave 1')
vectUa=MRBrst1.elems{1}.VectU{1};
vectUb=MRBrst1.elems{2}.VectU{1};
vectUc=MRBrst1.elems{3}.VectU{1};
vectUr=MRBrst1.VectU{1};
cdgJa=MRBrst1.elems{1}.GetCdg;
cdgJb=MRBrst1.elems{2}.GetCdg;
cdgJc=MRBrst1.elems{3}.GetCdg;
% El desplazamiento vertical tiene que ser el mismo
chk(' v junta MRBa / v MRBrst', vectUr(3),vectUa(2)-cdgJa(1)*vectUa(3))
chk(' v junta MRBb / v MRBrst', vectUr(3),vectUb(2)-cdgJb(1)*vectUb(3))
chk(' v junta MRBc / v MRBrst', vectUr(3),vectUc(2)-cdgJc(1)*vectUc(3))

chk('Ux junta MRBa / ux*c+uy*s MRBrst', vectUa(1)+cdgJa(2)*vectUa(3), ...
    vectUr(1)*cos(MRBrst1.RstAng(1,2))+vectUr(2)*sin(MRBrst1.RstAng(1,2)))
chk('Ux junta MRBb / ux*c+uy*s MRBrst', vectUb(1)+cdgJb(2)*vectUb(3), ...
    vectUr(1)*cos(MRBrst1.RstAng(2,2))+vectUr(2)*sin(MRBrst1.RstAng(2,2)))
chk('Ux junta MRBc / ux*c+uy*s MRBrst', vectUc(1)+cdgJc(2)*vectUc(3), ...
    vectUr(1)*cos(MRBrst1.RstAng(3,2))+vectUr(2)*sin(MRBrst1.RstAng(3,2)))

 
 chk('Uy MRBa / ux*s-uy*c MRBrst', MRBrst1.elems{1}.VectUy{1}(2), ...
    vectUr(1)*sin(MRBrst1.RstAng(1,2))-vectUr(2)*cos(MRBrst1.RstAng(1,2)))
 chk('Uy MRBb / ux*s-uy*c MRBrst', MRBrst1.elems{2}.VectUy{1}(2), ...
     vectUr(1)*sin(MRBrst1.RstAng(2,2))-vectUr(2)*cos(MRBrst1.RstAng(2,2)))
 chk('Uy MRBc / ux*s-uy*c MRBrst', MRBrst1.elems{3}.VectUy{1}(2), ...
    vectUr(1)*sin(MRBrst1.RstAng(3,2))-vectUr(2)*cos(MRBrst1.RstAng(3,2)))

