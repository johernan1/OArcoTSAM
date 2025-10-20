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
MRBo=mpl2RB210(geomEscarzano(8,3,1,ndov), topoRebajado(ndov));

%% Apoyos
% Se renumeran Conex, aunque no es necesario
MRBo.elems{1}.Conex(1,:)=[0 0 0];
MRBo.elems{ndov}.Conex(2,:)=[0 0 0];
MRBo.reSetConex;

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 
subsection ('SetConeS')
MRBo.SetConeS;

%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas
%subsection ('H')
%chk('H', full(sum(sum(H))), 5.76);

%% CALCULO CONDICIONES DE RESISTENCIA
subsection ('Condicones de resistencia');
MRBres = ArcoTSAM_Res();
MRBres.fc=5;
MRBres.Adds(MRBo.elems{1});
MRBres.Adds(MRBo.elems{4});
MRBres.Adds(MRBo.elems{7});
MRBres.Adds(MRBo.elems{10});
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
subsection ('Se ensambla H')
H=MRB.GetH;
%chk('H', full(sum(sum(H))), 55.478849);

%% CALCULO DEL VECTOR DE ACCIONES PERMANENTES
% Se calcula G. 
% La comprobación sólo es válida para una geometría
% El vector G incluye las términos independiente de las condiciones de
% resistencia. Si quiere hallarse la suma de G de las EQU hay que hacerlo
% para el modelo sin restricciones
subsection ('SetG & GetG')
MRB.SetG(1);
% MRBres.SetR(1) indica la hipótesis en la que se incluyen las condicones de
% resistencia. Es decir E/R<1 -> E/R+h=1 y hay que indicar en que hipótesis
% de carga deben incluirse los términos independientes (el vector de unos)
MRBres.SetR(1);
vectG=MRB.Getf(1);
vectGo=MRB.elems{1}.Getf(1);
chk('Hipotesis G', sum(vectGo), 118.79817)
chk('Hipotesis G sum(vectGo)+nres=sum(vectG)', ...
                    sum(vectGo)+MRBres.GetNGdl, sum(vectG))

%% CALCULO Y CHEQUEO DEL VECTOR DE ACCIONES VARIABLES vectQ 
% La comprobacion sólo es válida para una geometría 
subsection ('SetQ & GetQ')
ihip=3;
iele=4;
MRBo.SetQ(ihip, iele, [0 1 0]);
vectQ=MRB.Getf(ihip);
vectQo=MRBo.Getf(ihip);
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
%gammaQM = MRBo.GetMaxGammaLPD(vectQo, vectGo);
%chk('LP sin comprobar la resistencia: gammaQM=18.89', gammaQM, 18.8941)
gammaQM = MRB.GetMaxGammaLPD(vectQ, vectG);
%chk('LP comprobando la resistencia: gammaQM=18.79', gammaQM, 18.796644)
gammaQMP = MRB.GetMaxGammaLPP(vectQ, vectG)
chk('gammaQM LPP==LPD', gammaQM, gammaQMP);

chk('vectU LPP==LPD', MRBo.GetVectU(2),MRBo.GetVectU(1), 0.000001); 
chk('vectS LPP==LPD', MRBo.GetVectS(2),MRBo.GetVectS(1), 0.000001);


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

chk('Res: vectS LPP==LPD', MRBres.GetVectS(2),MRBres.GetVectS(1), 0.000001);
chk('vectU LPP==LPD', MRBo.GetVectU(2),MRBo.GetVectU(1), 0.000001); 

subsection('Tensiones, en las juntas de los elem. de MRBres');
MRBres.GetSigma

pauseOctaveFig