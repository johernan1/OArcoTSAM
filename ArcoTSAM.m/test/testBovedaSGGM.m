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

topoBovedaSegovia;

% %% Se lee geometría y topología en formato antiguo (mws)
% datos_b1
% 
% %% Para cada uno de los arcos se transforma geometría y topología mws, 
% % se "desplazan" las conex (índices de las EQU) y se añaden las cc.
% % Se disminuye el PP de los arcos 2 y 4 pues de otro modo no es posible el
% % equilibrio. Otro modo es ligar el movimiento horizontal de sus claves,
% % ligadura que puede justificarse si existe plementería
% 
% MRB01=mpl2RB210(g01,t01);
% MRB01.MoveConex(100);
% MRB01.elems{5}.Conex(1,:)=[0 0 0];
% 
% MRB02=mpl2RB210(g02,t02);
% MRB02.MoveConex(200);
% MRB02.elems{6}.Conex(1,:)=[0 0 0];
% MRB02.SetRho(0.5);  % Se disminuye PP para que sea estable el conjunto
% 
% MRB03=mpl2RB210(g03,t03);
% MRB03.MoveConex(300);
% MRB03.elems{5}.Conex(1,:)=[0 0 0];
% 
% MRB04=mpl2RB210(g04,t04);
% MRB04.MoveConex(400);
% MRB04.elems{6}.Conex(2,:)=[0 0 0];
% MRB04.SetRho(0.5);  % Se disminuye PP para que sea estable el conjunto
% 
% MRB05=mpl2RB210(g05,t05);
% MRB05.MoveConex(500);
% MRB05.elems{5}.Conex(2,:)=[0 0 0];
% 
% MRB06=mpl2RB210(g06,t06);
% MRB06.MoveConex(600);
% MRB06.elems{2}.Conex(1,:)=[0 0 0];
% 
% MRB07=mpl2RB210(g07,t07);
% MRB07.MoveConex(700);
% MRB07.elems{5}.Conex(2,:)=[0 0 0];
% 
% MRB08=mpl2RB210(g08,t08);
% MRB08.MoveConex(800);
% MRB08.elems{2}.Conex(1,:)=[0 0 0];
% 
% MRB09=mpl2RB210(g09,t09);
% MRB09.MoveConex(900);
% MRB09.elems{2}.Conex(1,:)=[0 0 0];
% 
% MRB10=mpl2RB210(g10,t10);
% MRB10.MoveConex(1000);
% MRB10.elems{5}.Conex(2,:)=[0 0 0];
% 
% MRB11=mpl2RB210(g11,t11);
% MRB11.MoveConex(1100);
% MRB11.elems{5}.Conex(2,:)=[0 0 0];
% 
% MRB12=mpl2RB210(g12,t12);
% MRB12.MoveConex(1200);
% MRB12.elems{2}.Conex(1,:)=[0 0 0];
% 
% MRB13=mpl2RB210(g13,t13);
% MRB13.MoveConex(1300);
% 
% MRB14=mpl2RB210(g14,t14);
% MRB14.MoveConex(1400);
% 
% MRB15=mpl2RB210(g15,t15);
% MRB15.MoveConex(1500);
% 
% MRB16=mpl2RB210(g16,t16);
% MRB16.MoveConex(1600);
% 
% %% Orientación, en planta, de cada uno de los arcos
% 
% MRB01.ucsA= pi/4;
% MRB02.ucsA=-pi/4;
% MRB03.ucsA= pi/4;
% MRB04.ucsA=-pi/4;
% 
% MRB05.ucsA=  27.862*pi/180;
% MRB06.ucsA= -27.862*pi/180;
% MRB07.ucsA= 117.536*pi/180;
% MRB08.ucsA=  62.138*pi/180;
% MRB09.ucsA=  27.862*pi/180;
% MRB10.ucsA= -27.862*pi/180;
% MRB11.ucsA= -62.138*pi/180;
% MRB12.ucsA= 242.138*pi/180;
% 
% MRB13.ucsA= 22.5*pi/180;
% MRB14.ucsA= 22.5*pi/180;
% MRB15.ucsA= 67.5*pi/180;
% MRB16.ucsA= 67.5*pi/180;
% 
% %% Modelo formado por los arcos 
% MRB = ArcoTSAM_Modelo();
% MRB.Adds(MRB01);
% MRB.Adds(MRB02);
% MRB.Adds(MRB03);
% MRB.Adds(MRB04);
% MRB.Adds(MRB05);
% MRB.Adds(MRB06);
% MRB.Adds(MRB07);
% MRB.Adds(MRB08);
% MRB.Adds(MRB09);
% MRB.Adds(MRB10);
% MRB.Adds(MRB11);
% MRB.Adds(MRB12);
% MRB.Adds(MRB13);
% MRB.Adds(MRB14);
% MRB.Adds(MRB15);
% MRB.Adds(MRB16);
%  
% %% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% % 
% subsection ('SetConeS')
% MRB.SetConeS;
% 
% %% LAS CLAVES
% 
% % Clave 1
% MRBrst1=clave(MRB13,2,MRB15,2,MRB01,1);
% MRBrst1.SetConeS(2100);
% MRBrst1.Conex=2101:2105;
% 
% % Clave 2
% MRBrst2=clave(MRB15, 3, MRB14, 3, MRB04, 1);
% MRBrst2.SetConeS(2200);
% MRBrst2.Conex=2201:2205;
% 
% % Clave 3
% MRBrst3=clave(MRB13, 3, MRB16, 3, MRB02, 1);
% MRBrst3.SetConeS(2300);
% MRBrst3.Conex=2301:2305;
% 
% % Clave 4
% MRBrst4=clave(MRB14, 2, MRB16, 2, MRB03, 1);
% MRBrst4.SetConeS(2400);
% MRBrst4.Conex=2401:2405;
% 
% % Clave 5
% MRBrst5=clave(MRB13, 1,  MRB07, 1, MRB08, 1);
% MRBrst5.SetConeS(2500);
% MRBrst5.Conex=2501:2505;
% 
% % Clave 6
% MRBrst6=clave(MRB14, 1,  MRB11, 1, MRB12, 1);
% MRBrst6.SetConeS(2600);
% MRBrst6.Conex=2601:2605;
% 
% % Clave 7
% MRBrst7=clave(MRB16, 1,  MRB05, 1, MRB06, 1);
% MRBrst7.SetConeS(2700);
% MRBrst7.Conex=2701:2705;
% 
% % Clave 8
% MRBrst8=clave(MRB15, 1,  MRB09, 1, MRB10, 1);
% MRBrst8.SetConeS(2800);
% MRBrst8.Conex=2801:2805;
% 
% 
% 
% MRB.plot;    % Topología
% MRB.plotj;   % juntas
% MRB.plota;   % Apoyos
% MRB.plotn;   % numero arco.dovela
% 
% 
% 
% 
% %% Se añaden las claves al modelo
% 
% MRB.Adds(MRBrst1);
% MRB.Adds(MRBrst2);
% MRB.Adds(MRBrst3);
% MRB.Adds(MRBrst4);
% MRB.Adds(MRBrst5);
% MRB.Adds(MRBrst6);
% MRB.Adds(MRBrst7);
% MRB.Adds(MRBrst8);
% 
% 
% 
% % Rst
% % 
% % MRBrst = ArcoTSAM_Rst();
% % MRBrst.Adds(MRBB.elems{(ndov)/2});
% % MRBrst.Adds(MRBA.elems{(ndov)/2});
% % MRBrst.Adds(MRBC.elems{(ndov)/2});
% % MRBrst.RstAng=[[3,0];[3,MRBA.ucsA];[3,MRBC.ucsA]];
% % 
% % MRBrst.SetConeS(210);
% % MRBrst.Conex=[301:305]';
% % MRB.Adds(MRBrst);
% % % MRBrst.GetH
% % % xx(x)
% % 
% % % %% rst
% % % %
% % % MRBrstz = ArcoTSAM_rst();
% % % %MRBrst.Adds(MRBa.elems{(ndov+1)/2});
% % % %MRBrst.NgdlCoeff=[[2,1];[2,1]];
% % % %MRBrst.Conex=200;
% % % 
% % % %MRBrstb = ArcoTSAM_rst();
% % % MRBrstz.Adds(MRBa.elems{(ndov+1)/2});
% % % MRBrstz.Adds(MRBb.elems{(ndov+1)/2});
% % % MRBrstz.Adds(MRBc.elems{(ndov+1)/2});
% % % MRBrstz.NgdlCoeff=[[2,1];[2,1];[2,1]];
% % % 
% % % %MRBrstb.Conex=201;
% % % 
% % % %MRBrstz.activate(MRB.GetNs,MRB.GetNGdl+1);
% % % MRBrstz.activate(200,301);
% % % %MRBrstb.activate(aux+2);
% % % MRB.Adds(MRBrstz);
% % % %MRB.Adds(MRBrstb);
% % % 
% % % MRBrstx = ArcoTSAM_rst();
% % % MRBrstx.Adds(MRBa.elems{(ndov+1)/2});
% % % MRBrstx.Adds(MRBb.elems{(ndov+1)/2});
% % % MRBrstx.Adds(MRBc.elems{(ndov+1)/2});
% % % MRBrstx.NgdlCoeff=[[1,cos(0)];[1,cos(MRBb.ucsA)];[1,cos(MRBc.ucsA)]];
% % % %MRBrstx.activate(MRB.GetNs,MRB.GetNGdl+1);
% % % MRBrstx.activate(203,302);
% % % MRB.Adds(MRBrstx);
% % % 
% % % MRBrsty = ArcoTSAM_rst();
% % % MRBrsty.Adds(MRBa.elems{(ndov+1)/2});
% % % MRBrsty.Adds(MRBb.elems{(ndov+1)/2});
% % % MRBrsty.Adds(MRBc.elems{(ndov+1)/2});
% % % MRBrsty.NgdlCoeff=[[1,sin(0)];[1,sin(MRBb.ucsA)];[1,sin(MRBc.ucsA)]];
% % % %MRBrsty.activate(MRB.GetNs,MRB.GetNGdl+1);
% % % MRBrsty.activate(203,303);
% % % MRB.Adds(MRBrsty);
% % % 
% % % MRBrstOx = ArcoTSAM_rst();
% % % MRBrstOx.Adds(MRBa.elems{(ndov+1)/2});
% % % MRBrstOx.Adds(MRBb.elems{(ndov+1)/2});
% % % MRBrstOx.Adds(MRBc.elems{(ndov+1)/2});
% % % MRBrstOx.NgdlCoeff=[[3,-sin(0)];[3,-sin(MRBb.ucsA)];[3,-sin(MRBc.ucsA)]];
% % % %MRBrstx.activate(MRB.GetNs,MRB.GetNGdl+1);
% % % MRBrstOx.activate(206,304);
% % % MRB.Adds(MRBrstOx);
% % % 
% % % MRBrstOy = ArcoTSAM_rst();
% % % MRBrstOy.Adds(MRBa.elems{(ndov+1)/2});
% % % MRBrstOy.Adds(MRBb.elems{(ndov+1)/2});
% % % MRBrstOy.Adds(MRBc.elems{(ndov+1)/2});
% % % MRBrstOy.NgdlCoeff=[[3,cos(0)];[3,cos(MRBb.ucsA)];[3,cos(MRBc.ucsA)]];
% % % %MRBrsty.activate(MRB.GetNs,MRB.GetNGdl+1);
% % % MRBrstOy.activate(206,305);
% % % MRB.Adds(MRBrstOy);
% 

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
MRB14.SetQ(ihip, 3, [0 1 0]);
vectQ=MRB.Getf(ihip);
%chk('Hipotesis Q, gamma=1', sum(vectQ), 2.749503)
iniFigureArcoTSAM (2);

MRB.plot;
escf=2;
ihip=3;
MRB.plotf(escf, ihip);
escf=4;
ihip=1;
MRB.plotf(escf, ihip);

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

subsection('LP');
gammaQM = MRB.GetMaxGammaLPD(vectQ);
%chk('LP', gammaQM, 18.8941)
subsection ('fin LP')

%% DIBUJO Resultados 3D
%
subsection ('dibujos 3D')

f=iniFigureArcoTSAM (302);
if amImatlab f.Name='LP'; end;

%MRB.plot;
%escf=2;
%ihip=3;
%MRB.plotf(escf, ihip);
%escf=1;
%ihip=1;
%MRB.plotf(escf, ihip);
%MRB.plotj;
%
%iniFigureArcoTSAM (301);
%if amImatlab f.Name='LP'; end

iSol=1;
escf=-.05;
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

