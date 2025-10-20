%% Pruebas
% 
clear all;

%% GEOMETRIA Y TOPOLOGIA
%

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro/');
addpath('Datos/');
wobinichTamino;
iniMatlabOctave();

nElem=4;
%% Topo
MRBa=mpl2RB210(geomPuntal(0,0,10,0,1,nElem), ...
        topoRebajado(nElem));

% Reacciones
MRBa.elems{1}.Conex(1,:)=[0 0 0];
MRBa.elems{nElem}.Conex(2,:)=[0 0 0];

MRBa.SetConeS

MRBb=mpl2RB210(geomPuntal(0,-1,10,-1,1,nElem), ...
        topoRebajado(nElem));

% Se eliminan juntas extremas
MRBb.elems{1}.Junta(1,:)=[];
MRBb.elems{nElem}.Junta(2,:)=[];

f=iniFigureArcoTSAM(111);
if (amImatlab) f.Name='topo, juntas, apoyos'; end;

MRB = ArcoTSAM_ModeloNL();

MRB.Adds(MRBa);
MRB.Adds(MRBb);

MRB.plot;    % Topología
MRB.plotj;   % juntas
MRB.plota;   % Apoyos




% %% Calculo de H
% subsection ('H')
% H = MRB.GetH;
% %% 1. CALCULO DEL EMPUJE MINIMO
% 
% subsection('Empuje minimo');
% ielem=1;
% apoyoAsiento=MRB.elems{ielem};
% ijunt=1;
% alpha=pi*0;
% gammau=1;
% 
% %c=MRB.GetCFoHdir(apoyoAsiento , ijunt, alpha);          
% minhdirP=MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau);
% 
% MRB.plotu
% 
% MRB.plotuj
% %%Comprobaciones
% B=full(transpose(H))
% BU_E=[B*MRB.GetVectUAmp MRB.GetVectE]
% % Hay un error en los signos de VectE al hacer  GethdirMinLPP (PRIMAL) 
% ES=diag(MRB.GetVectS)
% % Se 'libera' la componente asociada al h max
% ES(2,2)=0;
% % Y se coaccionan los deslizacimento
% ES(12,12)=100;
% ES(15,15)=100;
% I24=eye(24)
% cero24=zeros(24,27)
% M=[[I24 B];[ES cero24]]
% % Criterio de normalización u(4)=-1
% %normalizacion=zeros(1,51);
% %normalizacion(24+4)=1;
% % 
% e_u=[MRB.GetVectE; MRB.GetVectUAmp]
% Mxe_u=M*e_u
% % Se añade una condicion de normalizacion
% norm=zeros(1,51)
% norm(28)=1;
% Mn=[M;norm];
% 
% 
% MMM=inv(Mn'*Mn+10^(-15)*eye(51))*Mn'
% aux=zeros(48+1,1);
% % Esta última condición hay que cambiarla por un criterio de normalización
% aux(49)=1;
% e_u_M=MMM*aux;
% e_u_M_=linsolve(Mn,aux);
% xxxx=[MRB.GetVectE; MRB.GetVectUAmp] 
% [xxxx e_u_M e_u_M_]
% %spy(H)
% 
% %%%%
% EB=ES*B
% norm=zeros(1,27)
% norm(26)=1;
% aux=zeros(25,1)
% aux(25)=5;
% EBn=[EB;norm];
% uEB=linsolve(EBn,aux);
% MRB.SetMatJU(uEB)
% MRB.SetVectU(uEB)
% MRB.plotu
% MRB.plotu(2)
% MRB.plotuj
% MRB.plotuj(2)