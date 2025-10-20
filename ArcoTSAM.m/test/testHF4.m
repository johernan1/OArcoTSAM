%% Rose Windows. J Heyman. Fig 4
% Empuje máximo y mínimo en transom & mullion.
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

neleT= 9*2; % numero elementos de cada transom (+2 'claves') 
neleM=12*2; % numero elementos de cada mullion (+2 'claves')
lT=9;       % longitud de los transom
lM=12;      % longitud de los mullion
t=lM/24;    % mullion proportion d/t=24
lC=0.0125;    % longitud de la clave
leT=(lT-2*lC)/neleT;
leM=(lM-2*lC)/neleM;

MRBa=mpl2RB210(cat(1,geomPuntal(0,0,leT*neleT/3,0,t,neleT/3), ...
      geomPuntal(leT*neleT/3+lC,0,2*leT*neleT/3+lC,0,t,neleT/3), ...
      geomPuntal(2*leT*neleT/3+2*lC,0,3*leT*neleT/3+2*lC,0,t,neleT/3)), ...
      topoRebajado(neleT+2));

MRBb=mpl2RB210(cat(1,geomPuntal(0,5,leM*neleM/3,5,t,neleM/3), ...
      geomPuntal(leM*neleM/3+lC,5,2*leM*neleM/3+lC,5,t,neleM/3), ...
      geomPuntal(2*leM*neleM/3+2*lC,5,3*leM*neleM/3+2*lC,5,t,neleM/3)), ...
      topoRebajado(neleM+2));

MRBc=mpl2RB210(cat(1,geomPuntal(0,10,leM*neleM/3,10,t,neleM/3), ...
      geomPuntal(leM*neleM/3+lC,10,2*leM*neleM/3+lC,10,t,neleM/3), ...
      geomPuntal(2*leM*neleM/3+2*lC,10,3*leM*neleM/3+2*lC,10,t,neleM/3)), ...
      topoRebajado(neleM+2));

ncx=1;
while ncx < MRBa.GetMaxConex;    ncx = ncx+100; end;
MRBb.MoveConex(ncx);

while ncx < MRBb.GetMaxConex;    ncx = ncx+100; end;
MRBc.MoveConex(ncx);

MRB = ArcoTSAM_Modelo();

MRBb.ucsA=pi/2;
MRBc.ucsA=pi/2;
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
MRBrst1=clave(MRBa,7,MRBb,9);
MRBrst1.SetConeS(ncs);
MRBrst1.Conex=ncx:ncx+4;
MRB.Adds(MRBrst1);

% Clave 2
MRBrst2=clave(MRBa,14,MRBc,9);
MRBrst2.SetConeS(100+ncs);
MRBrst2.Conex=100+ncx:100+ncx+4;
MRB.Adds(MRBrst2);

MRB.plot;    % Topología
MRB.plotj;   % juntas
MRB.plotn;   % numero arco.dovela

%% Apoyos
% Se renumeran Conex, aunque no es necesario
MRBa.elems{1}.Conex(1,:)=[0 0 0];
MRBa.elems{neleT+2}.Conex(2,:)=[0 0 0];
MRBb.elems{1}.Conex(1,:)=[0 0 0];
MRBb.elems{neleM+2}.Conex(2,:)=[0 0 0];
MRBc.elems{1}.Conex(1,:)=[0 0 0];
MRBc.elems{neleM+2}.Conex(2,:)=[0 0 0];
%MRBb.reSetConex;
%MRB.plotConex;
MRB.plota;   % Apoyos



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
% 
%% CALCULO Y CHEQUEO DEL VECTOR DE ACCIONES VARIABLES vectQ 
% La comprobacion solo es valida para una geometria 
subsection ('SetQ & GetQ')
ihip=3;
qpml=18/3;
for ie=1:MRBa.GetNelems
    MRBa.SetQApml(ihip, ie,4, [0 qpml 0]);
end
vectQ=MRB.Getf(ihip);
%chk('Hipotesis Q, gamma=1', sum(vectQ), 2.749503)
%MRB.plotf(1, ihip);
%xxx=x
%% 1. CALCULO DEL EMPUJE MINIMO
% La comprobacion solo es valida para una geometria

subsection('Empuje minimo');
apoyoAsiento=MRBa.elems{1};
ijunt=1;
alpha=pi*0;
gammau=1;
%minhdir=MRB.GethdirMinLPP(ielem, ijunt, alpha, gammau);
%fprintf('h = %12.6f\n', minhdir);
%chk('LPP, min hd', minhdir, -3.806448)
%             coneSApoyo=MRB.elems{1}.elems{ielem}.GetConeSjunta(ijunt);
%             sdir = MRB.elems{1}.elems{ielem}.GetSdir(ijunt, alpha);                  
%             
%             c = zeros(MRB.GetNs,1);
%             c(coneSApoyo) = sdir; 
           
minhdirD=MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau,vectQ);
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

iniFigureArcoTSAM (4);

escf=-.025;
escu=0;
MRB.plot;
MRB.plotRjULM(escf, false, iSol, escu);

pauseOctaveFig

%% Chequeos
%
Srv=-MRBa.elems{1}.VectS{1}(3)+MRBa.elems{MRBa.GetNelems}.VectS{1}(6) ...
    -MRBb.elems{1}.VectS{1}(3)+MRBb.elems{MRBa.GetNelems}.VectS{1}(6) ...
    -MRBc.elems{1}.VectS{1}(3)+MRBc.elems{MRBa.GetNelems}.VectS{1}(6);
Sq=qpml*lT;    

chk(sprintf('Suma reacciones verticales (%f) == suma cargas (%f)', ...
        Srv, Sq), Srv, Sq);

% Los siguientes chequeos no se satisfacen si se cambia geom, cargas, etc.

chk(sprintf('Reacción horizontal en transom: (%f)', ...
        MRBa.elems{1}.VectS{1}(2)),MRBa.elems{1}.VectS{1}(2), -13.4251);
chk(sprintf('Reacción vertical en transom: (%f)', ...
        MRBa.elems{1}.VectS{1}(3)),MRBa.elems{1}.VectS{1}(3), -8.9750);
chk(sprintf('Reacción horizontal en transom: (%f)', ...
        MRBa.elems{MRBa.GetNelems}.VectS{1}(4)),MRBa.elems{MRBa.GetNelems}.VectS{1}(4), -13.4251);
chk(sprintf('Reacción vertical en transom: (%f)', ...
        MRBa.elems{MRBa.GetNelems}.VectS{1}(6)),MRBa.elems{MRBa.GetNelems}.VectS{1}(6), 8.9750);
    
chk(sprintf('Reacción horizontal en mullion 1: (%f)', ...
        MRBb.elems{1}.VectS{1}(2)),MRBb.elems{1}.VectS{1}(2), -96.0332);
chk(sprintf('Reacción vertical en mullion 1: (%f)', ...
        MRBb.elems{1}.VectS{1}(3)),MRBb.elems{1}.VectS{1}(3), -12.0198);
chk(sprintf('Reacción horizontal en mullion 1: (%f)', ...
        MRBb.elems{MRBb.GetNelems}.VectS{1}(4)),MRBb.elems{MRBb.GetNelems}.VectS{1}(4), -96.0332);
chk(sprintf('Reacción vertical en mullion 1: (%f)', ...
        MRBb.elems{MRBb.GetNelems}.VectS{1}(6)),MRBb.elems{MRBb.GetNelems}.VectS{1}(6), 6.0052);
    
chk(sprintf('Reacción horizontal en mullion 2: (%f)', ...
        MRBc.elems{1}.VectS{1}(2)),MRBc.elems{1}.VectS{1}(2), -96.0332);
chk(sprintf('Reacción vertical en mullion 2: (%f)', ...
        MRBc.elems{1}.VectS{1}(3)),MRBc.elems{1}.VectS{1}(3), -12.0198);
chk(sprintf('Reacción horizontal en mullion 2: (%f)', ...
        MRBc.elems{MRBb.GetNelems}.VectS{1}(4)),MRBc.elems{MRBb.GetNelems}.VectS{1}(4), -96.0332);
chk(sprintf('Reacción vertical en mullion 2: (%f)', ...
        MRBc.elems{MRBb.GetNelems}.VectS{1}(6)),MRBc.elems{MRBb.GetNelems}.VectS{1}(6), 6.0052);
