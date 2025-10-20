%% Boveda Mexico
% Asiento.
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

topoMX;

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

% %% CALCULO Y CHEQUEO DEL VECTOR DE ACCIONES VARIABLES vectQ 
% % La comprobacion solo es valida para una geometria 
% subsection ('SetQ & GetQ')
% ihip=3;
% iele=4;
% % MRB01.SetQ(ihip, iele, [0 1 0]);
% % MRB02.SetQ(ihip, 2, [0 1 0]);
% % MRB03.SetQ(ihip, iele, [0 1 0]);
% MRB14.SetQ(ihip, 3, [0 1 0]);
% vectQ=MRB.Getf(ihip);
% %chk('Hipotesis Q, gamma=1', sum(vectQ), 2.749503)
% iniFigureArcoTSAM (2);
% 
% MRB.plot;
% escf=2;
% ihip=3;
% MRB.plotf(escf, ihip);
% escf=4;
% ihip=1;
% MRB.plotf(escf, ihip);

%% H*Ht
% Ht=H';
% HHt=H*Ht;
% f = MRB.Getf(3);
% u=-HHt\f;
% s=Ht*u
% iniFigureArcoTSAM (4);
% 
% MRB.SetVectS(s)
% MRB.SetMatJU(u)
% MRB.SetVectU(u)
% escf=-.25;
% escu=0;
% MRB.plot;
% MRB.plotj;
% MRB.plota;
% %MRB.plotConex;
% MRB.plotRjULM(escf, false, 1, escu);
% iniFigureArcoTSAM (6);
% x3=MRB.elems{6}.elems{3};
% x4=MRB.elems{6}.elems{4};
% x3H=x3.GetH;
% x4H=x4.GetH;
% s3s4=[x3.VectS{1} x4.VectS{1}]
% problema con clave 2 y 3
% y los arcos 2 y 3
% xxx
%% CALCULO Y CHEQUEO DEL FACTOR DE CARGA DE COLAPSO PARA vectQ
% La comprobacion solo es valida para vectQ y una geometria

c = MRB.GetCFoHdir(apoyoAsiento1,1,pi/2);
subsection('LP');
minhdir = MRB.GethdirMinLPD(apoyoAsiento1,1,pi/2,2,vectG,c);
%chk('LP', minhdir, 0.2593)
subsection ('fin LP')

%% DIBUJO Resultados 3D
%
subsection ('dibujos 3D')

f=iniFigureArcoTSAM (302);
if amImatlab f.Name='LP'; end;

iSol=1;
escf=-.05;
escu=0;
MRB.plot;
MRB.plota;
MRB.plotRjULM(escf, false, iSol, escu);

pauseOctaveFig
%ihip=3;
%MRB.plotf(escf, ihip);
%escf=1;
%ihip=1;
%MRB.plotf(escf, ihip);
%MRB.plotj;

f=iniFigureArcoTSAM (301);
if amImatlab f.Name='MEC'; end

h= MRB.plot;
set(h,'facealpha',.0)
%set(h,'facecolor','r')
esca=.25/4;
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

%iSol=1;
%escf=-.25;
%escu=0;
MRB.plot;
MRB.plota;
MRB.plotRjULM(escf, false, iSol, escu);

pauseOctaveFig

f=iniFigureArcoTSAM (401);
if amImatlab f.Name='MEC'; end

h= MRB.plot;
set(h,'facealpha',.0)
%set(h,'facecolor','r')
esca=.25/4;
%esca=1;
iSol=1;
MRB.plotu( false,iSol,esca);
MRB.plotuj(false,iSol,esca);

%% Chequeos
%

subsection('Chequeo desplazamientos. Clave 1')
vectUa=MRBrst1.elems{1}.VectU{1};
vectUb=MRBrst1.elems{2}.VectU{1};
%vectUc=MRBrst1.elems{3}.VectU{1};
vectUr=MRBrst1.VectU{1};
cdgJa=MRBrst1.elems{1}.GetCdg;
cdgJb=MRBrst1.elems{2}.GetCdg;
%cdgJc=MRBrst1.elems{3}.GetCdg;
% El desplazamiento vertical tiene que ser el mismo
chk(' v junta MRBa / v MRBrst', vectUr(3),vectUa(2)-cdgJa(1)*vectUa(3))
chk(' v junta MRBb / v MRBrst', vectUr(3),vectUb(2)-cdgJb(1)*vectUb(3))
%chk(' v junta MRBc / v MRBrst', vectUr(3),vectUc(2)-cdgJc(1)*vectUc(3))

chk('Ux junta MRBa / ux*c+uy*s MRBrst', vectUa(1)+cdgJa(2)*vectUa(3), ...
    vectUr(1)*cos(MRBrst1.RstAng(1,2))+vectUr(2)*sin(MRBrst1.RstAng(1,2)))
chk('Ux junta MRBb / ux*c+uy*s MRBrst', vectUb(1)+cdgJb(2)*vectUb(3), ...
    vectUr(1)*cos(MRBrst1.RstAng(2,2))+vectUr(2)*sin(MRBrst1.RstAng(2,2)))
% chk('Ux junta MRBc / ux*c+uy*s MRBrst', vectUc(1)+cdgJc(2)*vectUc(3), ...
%     vectUr(1)*cos(MRBrst1.RstAng(3,2))+vectUr(2)*sin(MRBrst1.RstAng(3,2)))

 
 chk('Uy MRBa / ux*s-uy*c MRBrst', MRBrst1.elems{1}.VectUy{1}(2), ...
    vectUr(1)*sin(MRBrst1.RstAng(1,2))-vectUr(2)*cos(MRBrst1.RstAng(1,2)))
 chk('Uy MRBb / ux*s-uy*c MRBrst', MRBrst1.elems{2}.VectUy{1}(2), ...
     vectUr(1)*sin(MRBrst1.RstAng(2,2))-vectUr(2)*cos(MRBrst1.RstAng(2,2)))
%  chk('Uy MRBc / ux*s-uy*c MRBrst', MRBrst1.elems{3}.VectUy{1}(2), ...
%     vectUr(1)*sin(MRBrst1.RstAng(3,2))-vectUr(2)*cos(MRBrst1.RstAng(3,2)))

