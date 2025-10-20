%% Rose Windows. J Heyman. Fig 4 
% Empuje máximo y mínimo en transom & mullion.
% Variación: empuje minimo en un mullion.
% La fo es la suma del empuje del transom + empuje del mullion
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


%% CALCULO CONDICIONES DE RESISTENCIA
MRBres = ArcoTSAM_Res();
MRBres.fc=4;
MRBres.Adds(MRBa.elems{1});
MRBres.Adds(MRBa.elems{6});
MRBres.Adds(MRBa.elems{20});
MRBres.Setb(t/2);
%MRBres.Adds(MRBa.elems{neleT+2});

%MRBres.Adds(MRBb.elems{1});
%MRBres.Adds(MRBb.elems{neleT+2});

%MRBres.Adds(MRBc.elems{1});
%MRBres.Adds(MRBc.elems{neleT+2});

MRBres.nRes=100;

% Las condiciones de desigualdad se redefinen como condiciones de igualdad 
% mediante unas variables de holgura, que a efectos prácticos son nuevas 
% componente del vector s de MRBres. 
% ArcoTSAM_Res.GetNs devuelve el número de componentes del vects incluidas  
%                    en las condiciones de resistencia. 
% ArcoTSAM:Res.GetNsAmp devuelve las anteriores más el número de las 
%                    variables de holgura.
% Así, MRBres.GetNsAmp - MRBres.GetNs es el número de restricciones
% 
MRBres.Conex=[MRBrst2.GetMaxConex+1+100: ...
              MRBrst2.GetMaxConex+ +100+MRBres.GetNsAmp - MRBres.GetNs];
MRB.Adds(MRBres);  
MRB.SetConeS;     
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
MRBres.SetR(ihip);
vectQ=MRB.Getf(ihip);
%chk('Hipotesis Q, gamma=1', sum(vectQ), 2.749503) 
    
%% 1. CALCULO DEL EMPUJE MINIMO
% La comprobacion solo es valida para una geometria

subsection('Empuje minimo');
apoyoAsiento=MRBa.elems{1};
apoyoAsiento1=MRBb.elems{1};
ijunt=1;
alpha=pi*0;
gammau=1;   
c=MRB.GetCFoHdir(apoyoAsiento , ijunt, alpha)  + ...
  MRB.GetCFoHdir(apoyoAsiento1, ijunt, alpha)          
    
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

% 
fprintf('Reacción horizontal en transom: (%f)\n', MRBa.elems{1}.VectS{1}(2));
fprintf('Reacción vertical en transom: (%f)\n',   MRBa.elems{1}.VectS{1}(3));
fprintf('Reacción horizontal en transom: (%f)\n',   MRBa.elems{MRBa.GetNelems}.VectS{1}(5));
fprintf('Reacción vertical en transom: (%f)\n',     MRBa.elems{MRBa.GetNelems}.VectS{1}(6));
    
fprintf('Reacción horizontal en mullion 1: (%f)\n', MRBb.elems{1}.VectS{1}(2));
fprintf('Reacción vertical en mullion 1: (%f)\n',   MRBb.elems{1}.VectS{1}(3));
fprintf('Reacción horizontal en mullion 1: (%f)\n', MRBb.elems{MRBb.GetNelems}.VectS{1}(4));
fprintf('Reacción vertical en mullion 1: (%f)\n',   MRBb.elems{MRBb.GetNelems}.VectS{1}(6));
    
fprintf('Reacción horizontal en mullion 2: (%f)\n', MRBc.elems{1}.VectS{1}(2));
fprintf('Reacción vertical en mullion 2: (%f)\n',   MRBc.elems{1}.VectS{1}(3));
fprintf('Reacción horizontal en mullion 2: (%f)\n', MRBc.elems{MRBb.GetNelems}.VectS{1}(4));
fprintf('Reacción vertical en mullion 2: (%f)\n',   MRBc.elems{MRBb.GetNelems}.VectS{1}(6));

MRBres.GetSigma
