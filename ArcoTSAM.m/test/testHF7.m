%% Rose Windows. J Heyman. Fig 7
% Empuje máximo y mínimo en wheel window.
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

neleS= 3; % numero elementos de cada spoke 
lS=2;      % longitud del spoke
t=lS/10;   % spoke proportion d/t=10
lSp=lS+10^-10;
%Con cat 1 se añade un elemento adicional, la clave, sin dimensiones
MRBa=mpl2RB210(cat(1,geomPuntal(0,0,lS,0,t,neleS), ...
        [lSp,0;lSp, -t]), ...
      topoRebajado(neleS+1));

MRBb=mpl2RB210(cat(1,geomPuntal(0,1,lS,1,t,neleS), ...
        [lSp,1;lSp, 1-t]), ...
      topoRebajado(neleS+1));

MRBc=mpl2RB210(cat(1,geomPuntal(0,2,lS,2,t,neleS), ...
        [lSp,2;lSp, 2-t]), ...
      topoRebajado(neleS+1));

ncx=1;
while ncx < MRBa.GetMaxConex;    ncx = ncx+100; end;
MRBb.MoveConex(ncx);

while ncx < MRBb.GetMaxConex;    ncx = ncx+100; end;
MRBc.MoveConex(ncx);

MRB = ArcoTSAM_Modelo();

MRBa.ucsA=pi/2-pi/2;
MRBb.ucsA=pi+pi/6-pi/2;
MRBc.ucsA=2*pi-pi/6-pi/2;
MRB.Adds(MRBa);
MRB.Adds(MRBb);
MRB.Adds(MRBc);

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 
subsection ('SetConeS')
%MRBa.SetConeS;
%MRBb.SetConeS;
MRB.SetConeS;

%% LAS CLAVES

while ncx < MRB.GetMaxConex;    ncx = ncx+100; end;
ncs=1;
while ncs < MRB.GetMaxConex;    ncs = ncs+100; end;

% Clave 1
MRBrst1=clave(MRBa,MRBa.GetNelems,MRBb,MRBb.GetNelems,MRBc,MRBc.GetNelems);
MRBrst1.SetConeS(ncs);
MRBrst1.Conex=ncx:ncx+4;
MRB.Adds(MRBrst1);

% % Clave 2
% MRBrst2=clave2(MRBa,MRBa.GetNelems,MRBc,MRBb.GetNelems);
% MRBrst2.SetConeS(100+ncs);
% MRBrst2.Conex=100+ncx:100+ncx+4;
% MRB.Adds(MRBrst2);

MRB.plot;  % Topología
MRB.plotj; % juntas
MRB.plotn; % numero arco.dovela


%% Apoyos
% Se renumeran Conex, aunque no es necesario
MRBa.elems{1}.Conex(1,:)=[0 0 0];
MRBb.elems{1}.Conex(1,:)=[0 0 0];
MRBc.elems{1}.Conex(1,:)=[0 0 0];
%MRBb.reSetConex;
%MRB.plotConex;
MRB.plota;   % Apoyos
swapXZinFig(); view(-30,30);


%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas

subsection ('H')
H = MRB.GetH;
chk('H', full(sum(sum(H))), -5.7);

%% CALCULO DEL VECTOR DE ACCIONES PERMANENTES
% Se calcula G. 
% La comprobacione solo es validas para una geometria
subsection ('SetG & GetG')
%MRBb.SetG(1);
MRB.SetG(1);
vectG=MRB.Getf(1);
%chk('Hipotesis G', sum(vectG), 11.879817)
% 
%% CALCULO Y CHEQUEO DEL VECTOR DE ACCIONES VARIABLES vectQ 
% La comprobacion solo es valida para una geometria 
subsection ('SetQ & GetQ')
ihip=3;
qpml=4.2/lS;
for ie=1:MRBa.GetNelems
    MRBa.SetQApml(ihip, ie,4, [0 qpml 0]);
    MRBb.SetQApml(ihip, ie,4, [0 qpml 0]);
    MRBc.SetQApml(ihip, ie,4, [0 qpml 0]);
end
vectQ=MRB.Getf(ihip);
%chk('Hipotesis Q, gamma=1', sum(vectQ), 2.749503)
%MRB.plotf(1, ihip);
%xxx=x
%% 1. CALCULO DEL EMPUJE MINIMO
% La comprobacion solo es valida para una geometria

subsection('Empuje minimo');
ielem=1;
ijunt=1;
alpha=pi*0;
gammau=1;
%minhdir=MRB.GethdirMinLPP(ielem, ijunt, alpha, gammau);
%fprintf('h = %12.6f\n', minhdir);
%chk('LPP, min hd', minhdir, -3.806448)
            coneSApoyo=MRB.elems{1}.elems{ielem}.GetConeSjunta(ijunt);
            sdir = MRB.elems{1}.elems{ielem}.GetSdir(ijunt, alpha);                  
            
            c = zeros(MRB.GetNs,1);
            c(coneSApoyo) = sdir; 
         apoyoAsiento=MRB.elems{1}.elems{ielem};   
         %MRB.GetCFoHdir(ielem, ijunt, alpha)  
minhdirD=MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau,vectQ,c);
fprintf('minhdirD=%f\n', minhdirD);
%chk('LPP==LPD, min hd', minhdir, minhdirD)
%chk('vectS LPP==LPD', MRB.GetVectS(1),MRB.GetVectS(2)); 

% %% CALCULO Y CHEQUEO DEL FACTOR DE CARGA DE COLAPSO PARA vectQ
% % La comprobacion solo es valida para vectQ y una geometria
% 
% subsection('LP');
% 
% minhdir=MRB.GethdirMinLPP(ielem, ijunt, alpha, gammau);
% %chk('LP', gammaQM, 18.8941)
% subsection ('LP')

%% DIBUJOS
%
subsection ('dibujos')

iniFigureArcoTSAM (2);

MRB.plot;
escf=1;
ihip=3;
MRB.plotf(escf, ihip);
swapXZinFig(); view(-30,30);
%escf=1;
% ihip=1;
% MRB.plotf(escf, ihip);
% MRB.plotj;

iniFigureArcoTSAM (3);


h= MRB.plot;
set(h,'facealpha',.0)
%set(h,'facecolor','r')
esca=.25;
iSol=1;
MRB.plotu( false,iSol,esca);
MRB.plotuj(false,iSol,esca);
swapXZinFig(); view(-30,30);

iniFigureArcoTSAM (4);

escf=-.025;
escu=0;
MRB.plot;
MRB.plotRjULM(escf, false, iSol, escu);
swapXZinFig(); view(-30,30);

pauseOctaveFig

%% Chequeos
%
Srv=-MRBa.elems{1}.VectS{1}(3)+MRBa.elems{MRBa.GetNelems}.VectS{1}(6) ...
    -MRBb.elems{1}.VectS{1}(3)+MRBb.elems{MRBa.GetNelems}.VectS{1}(6) ...
    -MRBc.elems{1}.VectS{1}(3)+MRBc.elems{MRBa.GetNelems}.VectS{1}(6);
Sq=qpml*lS*3;    

chk(sprintf('Suma reacciones verticales (%f) == suma cargas (%f)', ...
        Srv, Sq), Srv, Sq);

 
fprintf('Reacción horizontal en spoke 1: (%f)\n', MRBa.elems{1}.VectS{1}(2));
fprintf('Reacción vertical en spoke 1: (%f)\n',   MRBa.elems{1}.VectS{1}(3));

fprintf('Reacción horizontal en spoke 2: (%f)\n', MRBb.elems{1}.VectS{1}(2));
fprintf('Reacción horizontal en spoke 2: (%f)\n', MRBb.elems{1}.VectS{1}(3));

fprintf('Reacción vertical en spoke 3: (%f)\n',   MRBc.elems{1}.VectS{1}(2));
fprintf('Reacción vertical en spoke 3: (%f)\n',   MRBc.elems{1}.VectS{1}(3));
    