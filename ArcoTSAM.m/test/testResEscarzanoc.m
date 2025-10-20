%% ARCO ESCARZANO
% Calculo de min(h_dir) 

clear all;

%% GEOMETRIA Y TOPOLOGIA
%

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro');
wobinichTamino;
iniMatlabOctave();

ndov =16;
MRBo=mpl2RB210(geomEscarzano(10,5,1,ndov), topoRebajado(ndov));
% Apoyos
MRBo.elems{1}.Conex(1,:)=[0 0 0];
MRBo.elems{ndov}.Conex(2,:)=[0 0 0];

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 

subsection('SetConeS')
MRBo.SetConeS;

%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas

%subsection('GetH')
%H = MRB.GetH;
%chk('H',full(sum(sum(H))),6);
%% CALCULO CONDICIONES DE RESISTENCIA
MRBres = ArcoTSAM_Res();
MRBres.fc=1;
MRBres.Adds(MRBo.elems{3});
MRBres.Adds(MRBo.elems{8});
MRBres.Adds(MRBo.elems{14});
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
MRBres.Conex=[MRBo.GetMaxConex+1: ...
              MRBo.GetMaxConex+ MRBres.GetNsAmp - MRBres.GetNs];
%% MODELO CON CONDICIONES DE RESISTENCIA
% La comprobacione solo es validas para una geometria y unas condiciones de
% resistencia particulares  
MRB=ArcoTSAM_Modelo();
MRB.Adds(MRBo);
MRB.Adds(MRBres);
MRB.SetConeS;
H = MRB.GetH;
%chk('H', full(sum(sum(H))), 173.509834);
%% CALCULO DEL VECTOR DE ACCIONES PERMANENTES
% Se calcula G. 
% La comprobacione solo es validas para una geometria
subsection ('SetG & GetG')
MRB.SetG(1);
vectG=MRB.Getf(1);
%chk('Hipotesis G', sum(vectG), 11.879817)
% MRBres.SetR(1) indica la hipótesis en la que se incluyen las condicones de
% resistencia. Es decir E/R<1 -> E/R+h=1 y hay que indicar en que hipótesis
% de carga deben incluirse los términos independientes (el vector de unos)
MRBres.SetR(1);
vectG=MRB.Getf(1);
vectGo=MRB.elems{1}.Getf(1);
chk('Hipotesis G', sum(vectGo), 171.67948)
chk('Hipotesis G sum(vectGo)+nres=sum(vectG)', ...
                    sum(vectGo)+MRBres.GetNGdl, sum(vectG))

%% 1. CALCULO DEL EMPUJE MINIMO
% La comprobacion solo es valida para una geometria

subsection('Empuje minimo');
ielem=1; %MRBo.GetNelems;
ijunt=1;
alpha=pi*0;
gammau=.9;

apoyoAsiento=MRBo.elems{ielem};

%minhdir=MRB.GethdirMinLPP(ielem, ijunt, alpha, gammau);
%fprintf('h = %12.6f\n', minhdir);
%chk('LPP, min hd', minhdir, -3.806448, 1/100)
minhdirD=MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau, vectG);
fprintf('minhdirD=%f\n', minhdirD);
%chk('Empuje mínimo', 25.00607, minhdirD);
%chk('LPP==LPD, min hd', minhdir, minhdirD)
%chk('vectS LPP==LPD', MRB.GetVectS(1),MRB.GetVectS(2)); 
%chk('vectU LPP==LPD', MRB.GetVectU(1),MRB.GetVectU(2));
%[MRB.GetVectU(1),MRB.GetVectU(2)]
iniFigureArcoTSAM(1);

MRB.plotu;
iniFigureArcoTSAM (4);

escf=-.025;
escu=0;
MRB.plot;
MRB.plotRjULM(escf, false, 1, escu);

pauseOctaveFig;
