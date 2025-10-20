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
MRBa.elems{6}.Junta(2,:)=[];
MRBa.elems{6}.Conex(2,:)=[];

geomE(:,1)=geomE(:,1)+12;
MRBb=mpl2RB210(geomE, topoRebajado(ndov));
MRBb.MoveConex(100);
MRBb.elems{6}.Junta(2,:)=[];
MRBb.elems{6}.Conex(2,:)=[];

geomE(:,1)=geomE(:,1)+12;
MRBc=mpl2RB210(geomE, topoRebajado(ndov));
MRBc.MoveConex(200);
MRBc.elems{6}.Junta(2,:)=[];
MRBc.elems{6}.Conex(2,:)=[];

for i=(ndov+1)/2+1: ndov
    MRBa.elems(:,end)=[];
    MRBb.elems(:,end)=[];
    MRBc.elems(:,end)=[];
end

MRB = ArcoTSAM_Modelo();

MRBa.ucsA=0;
MRBb.ucsA=MRBa.ucsA+3*pi/4;
MRBb.ucsX=-12*cos(3*pi/4);
MRBb.ucsY=-12*sin(3*pi/4);
MRBc.ucsA=MRBa.ucsA-3*pi/4;
MRBc.ucsX=-24*cos(-3*pi/4);
MRBc.ucsY=-24*sin(-3*pi/4);
MRB.Adds(MRBa);
MRB.Adds(MRBb);
MRB.Adds(MRBc);

MRB.plot

%% Apoyos
% Se renumeran Conex, aunque no es necesario
MRBa.elems{1}.Conex(1,:)=[0 0 0];
%MRBa.elems{ndov}.Conex(2,:)=[0 0 0];
%MRBa.reSetConex;
MRBb.elems{1}.Conex(1,:)=[0 0 0];
%MRBb.elems{ndov}.Conex(2,:)=[0 0 0];
%MRBb.reSetConex;
MRBc.elems{1}.Conex(1,:)=[0 0 0];
MRB.plotConex;

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 
subsection ('SetConeS')
%MRBa.SetConeS;
%MRBb.SetConeS;
MRB.SetConeS;

% Rst

MRBrst = ArcoTSAM_Rst();
MRBrst.Adds(MRBa.elems{(ndov+1)/2});
MRBrst.Adds(MRBb.elems{(ndov+1)/2});
MRBrst.Adds(MRBc.elems{(ndov+1)/2});
MRBrst.RstAng=[[1,0];[1,MRBb.ucsA];[1,MRBc.ucsA]];

MRBrst.SetConeS(210);
MRBrst.Conex=301:305;
MRB.Adds(MRBrst);
% MRBrst.GetH
% xx(x)

% %% rst
% %
% MRBrstz = ArcoTSAM_rst();
% %MRBrst.Adds(MRBa.elems{(ndov+1)/2});
% %MRBrst.NgdlCoeff=[[2,1];[2,1]];
% %MRBrst.Conex=200;
% 
% %MRBrstb = ArcoTSAM_rst();
% MRBrstz.Adds(MRBa.elems{(ndov+1)/2});
% MRBrstz.Adds(MRBb.elems{(ndov+1)/2});
% MRBrstz.Adds(MRBc.elems{(ndov+1)/2});
% MRBrstz.NgdlCoeff=[[2,1];[2,1];[2,1]];
% 
% %MRBrstb.Conex=201;
% 
% %MRBrstz.activate(MRB.GetNs,MRB.GetNGdl+1);
% MRBrstz.activate(200,301);
% %MRBrstb.activate(aux+2);
% MRB.Adds(MRBrstz);
% %MRB.Adds(MRBrstb);
% 
% MRBrstx = ArcoTSAM_rst();
% MRBrstx.Adds(MRBa.elems{(ndov+1)/2});
% MRBrstx.Adds(MRBb.elems{(ndov+1)/2});
% MRBrstx.Adds(MRBc.elems{(ndov+1)/2});
% MRBrstx.NgdlCoeff=[[1,cos(0)];[1,cos(MRBb.ucsA)];[1,cos(MRBc.ucsA)]];
% %MRBrstx.activate(MRB.GetNs,MRB.GetNGdl+1);
% MRBrstx.activate(203,302);
% MRB.Adds(MRBrstx);
% 
% MRBrsty = ArcoTSAM_rst();
% MRBrsty.Adds(MRBa.elems{(ndov+1)/2});
% MRBrsty.Adds(MRBb.elems{(ndov+1)/2});
% MRBrsty.Adds(MRBc.elems{(ndov+1)/2});
% MRBrsty.NgdlCoeff=[[1,sin(0)];[1,sin(MRBb.ucsA)];[1,sin(MRBc.ucsA)]];
% %MRBrsty.activate(MRB.GetNs,MRB.GetNGdl+1);
% MRBrsty.activate(203,303);
% MRB.Adds(MRBrsty);
% 
% MRBrstOx = ArcoTSAM_rst();
% MRBrstOx.Adds(MRBa.elems{(ndov+1)/2});
% MRBrstOx.Adds(MRBb.elems{(ndov+1)/2});
% MRBrstOx.Adds(MRBc.elems{(ndov+1)/2});
% MRBrstOx.NgdlCoeff=[[3,-sin(0)];[3,-sin(MRBb.ucsA)];[3,-sin(MRBc.ucsA)]];
% %MRBrstx.activate(MRB.GetNs,MRB.GetNGdl+1);
% MRBrstOx.activate(206,304);
% MRB.Adds(MRBrstOx);
% 
% MRBrstOy = ArcoTSAM_rst();
% MRBrstOy.Adds(MRBa.elems{(ndov+1)/2});
% MRBrstOy.Adds(MRBb.elems{(ndov+1)/2});
% MRBrstOy.Adds(MRBc.elems{(ndov+1)/2});
% MRBrstOy.NgdlCoeff=[[3,cos(0)];[3,cos(MRBb.ucsA)];[3,cos(MRBc.ucsA)]];
% %MRBrsty.activate(MRB.GetNs,MRB.GetNGdl+1);
% MRBrstOy.activate(206,305);
% MRB.Adds(MRBrstOy);


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

%%
% Ht=H';
% HHt=H*Ht;
% f = MRB.Getf(1);
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
% MRB.plotRjULM(escf, false, 1, escu);
% xxxx
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

%% Chequeos PENDIENTE DE AJUSTAR. COPIADO DE testBoveda3.m
%

subsection('Chequeo desplazamientos')
vectUa=MRBa.elems{6}.VectU{1};
vectUb=MRBb.elems{6}.VectU{1};
vectUc=MRBc.elems{6}.VectU{1};
vectUr=MRBrst.VectU{1};
cdgJa=MRBa.elems{6}.GetCdg;
cdgJb=MRBb.elems{6}.GetCdg;
cdgJc=MRBc.elems{6}.GetCdg;
% El desplazamiento vertical tiene que ser el mismo
chk(' v junta MRBa / v MRBrst', vectUr(3),vectUa(2))
chk(' v junta MRBb / v MRBrst', vectUr(3),vectUb(2)-cdgJb(1)*vectUb(3))
chk(' v junta MRBc / v MRBrst', vectUr(3),vectUc(2)-cdgJc(1)*vectUc(3))

chk('Ux junta MRBa / ux*c+uy*s MRBrst', vectUa(1)+cdgJa(2)*vectUa(3), ...
    vectUr(1)*cos(MRBa.ucsA)+vectUr(2)*sin(MRBa.ucsA))
chk('Ux junta MRBb / ux*c+uy*s MRBrst', vectUb(1)+cdgJb(2)*vectUb(3), ...
    vectUr(1)*cos(MRBb.ucsA)+vectUr(2)*sin(MRBb.ucsA))
chk('Ux junta MRBc / ux*c+uy*s MRBrst', vectUc(1)+cdgJc(2)*vectUc(3), ...
    vectUr(1)*cos(MRBc.ucsA)+vectUr(2)*sin(MRBc.ucsA))

 
 chk('Uy MRBa / ux*s-uy*c MRBrst', MRBrst.elems{1}.VectUy{1}(2), ...
    vectUr(1)*sin(MRBa.ucsA)-vectUr(2)*cos(MRBa.ucsA))
 chk('Uy MRBb / ux*s-uy*c MRBrst', MRBrst.elems{2}.VectUy{1}(2), ...
     vectUr(1)*sin(MRBb.ucsA)-vectUr(2)*cos(MRBb.ucsA))
 chk('Uy MRBc / ux*s-uy*c MRBrst', MRBrst.elems{3}.VectUy{1}(2), ...
    vectUr(1)*sin(MRBc.ucsA)-vectUr(2)*cos(MRBc.ucsA))

