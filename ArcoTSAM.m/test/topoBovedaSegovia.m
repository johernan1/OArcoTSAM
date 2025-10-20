%% Boveda Segovia
% Geometría y Topología
% 

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro');
addpath('Datos');

subsection ('topoBovedaSegovia')
%% GEOMETRIA Y TOPOLOGIA
%

subsection ('        topo')
%% Se lee geometría y topología en formato antiguo (mws)
datos_b1

%% Para cada uno de los arcos se transforma geometría y topología mws, 
% se "desplazan" las conex (índices de las EQU) y se añaden las cc.
% Se disminuye el PP de los arcos 2 y 4 pues de otro modo no es posible el
% equilibrio. Otro modo es ligar el movimiento horizontal de sus claves,
% ligadura que puede justificarse si existe plementería

MRB01=mpl2RB210(g01,t01);
MRB01.MoveConex(100);
MRB01.elems{5}.Conex(1,:)=[0 0 0];
apoyoAsiento1=MRB01.elems{5};

MRB02=mpl2RB210(g02,t02);
MRB02.MoveConex(200);
MRB02.elems{6}.Conex(1,:)=[0 0 0];
MRB02.SetRho(15);  % Se disminuye PP para que sea estable el conjunto

MRB03=mpl2RB210(g03,t03);
MRB03.MoveConex(300);
MRB03.elems{5}.Conex(1,:)=[0 0 0];

MRB04=mpl2RB210(g04,t04);
MRB04.MoveConex(400);
MRB04.elems{6}.Conex(2,:)=[0 0 0];
MRB04.SetRho(15);  % Se disminuye PP para que sea estable el conjunto

MRB05=mpl2RB210(g05,t05);
MRB05.MoveConex(500);
MRB05.elems{5}.Conex(2,:)=[0 0 0];
apoyoAsiento5=MRB05.elems{5};

MRB06=mpl2RB210(g06,t06);
MRB06.MoveConex(600);
MRB06.elems{2}.Conex(1,:)=[0 0 0];

MRB07=mpl2RB210(g07,t07);
MRB07.MoveConex(700);
MRB07.elems{5}.Conex(2,:)=[0 0 0];

MRB08=mpl2RB210(g08,t08);
MRB08.MoveConex(800);
MRB08.elems{2}.Conex(1,:)=[0 0 0];

MRB09=mpl2RB210(g09,t09);
MRB09.MoveConex(900);
MRB09.elems{2}.Conex(1,:)=[0 0 0];

MRB10=mpl2RB210(g10,t10);
MRB10.MoveConex(1000);
MRB10.elems{5}.Conex(2,:)=[0 0 0];

MRB11=mpl2RB210(g11,t11);
MRB11.MoveConex(1100);
MRB11.elems{5}.Conex(2,:)=[0 0 0];

MRB12=mpl2RB210(g12,t12);
MRB12.MoveConex(1200);
MRB12.elems{2}.Conex(1,:)=[0 0 0];
apoyoAsiento12=MRB12.elems{2};

MRB13=mpl2RB210(g13,t13);
MRB13.MoveConex(1300);

MRB14=mpl2RB210(g14,t14);
MRB14.MoveConex(1400);

MRB15=mpl2RB210(g15,t15);
MRB15.MoveConex(1500);

MRB16=mpl2RB210(g16,t16);
MRB16.MoveConex(1600);

%% Orientación, en planta, de cada uno de los arcos

MRB01.ucsA= pi/4;
MRB02.ucsA=-pi/4;
MRB03.ucsA= pi/4;
MRB04.ucsA=-pi/4;

MRB05.ucsA=  27.862*pi/180;
MRB06.ucsA= -27.862*pi/180;
MRB07.ucsA= 117.536*pi/180;
MRB08.ucsA=  62.138*pi/180;
MRB09.ucsA=  27.862*pi/180;
MRB10.ucsA= -27.862*pi/180;
MRB11.ucsA= -62.138*pi/180;
MRB12.ucsA= 242.138*pi/180;

MRB13.ucsA= 22.5*pi/180;
MRB14.ucsA= 22.5*pi/180;
MRB15.ucsA= 67.5*pi/180;
MRB16.ucsA= 67.5*pi/180;

%% Modelo formado por los arcos 
MRB = ArcoTSAM_Modelo();
MRB.Adds(MRB01);
MRB.Adds(MRB02);
MRB.Adds(MRB03);
MRB.Adds(MRB04);
MRB.Adds(MRB05);
MRB.Adds(MRB06);
MRB.Adds(MRB07);
MRB.Adds(MRB08);
MRB.Adds(MRB09);
MRB.Adds(MRB10);
MRB.Adds(MRB11);
MRB.Adds(MRB12);
MRB.Adds(MRB13);
MRB.Adds(MRB14);
MRB.Adds(MRB15);
MRB.Adds(MRB16);
 
%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 
subsection ('        SetConeS')
MRB.SetConeS;

%% LAS CLAVES
%
subsection ('        claves')
% Clave 1
MRBrst1=clave(MRB13,2,MRB15,2,MRB01,1);
MRBrst1.SetConeS(2100);
MRBrst1.Conex=2101:2105;
MRBkey{1}=MRBrst1;

% Clave 2
MRBrst2=clave(MRB15, 3, MRB14, 3, MRB04, 1);
MRBrst2.SetConeS(2200);
MRBrst2.Conex=2201:2205;
MRBkey{2}=MRBrst2;

% Clave 3
MRBrst3=clave(MRB13, 3, MRB16, 3, MRB02, 1);
MRBrst3.SetConeS(2300);
MRBrst3.Conex=2301:2305;
MRBkey{3}=MRBrst3;

% Clave 4
MRBrst4=clave(MRB14, 2, MRB16, 2, MRB03, 1);
MRBrst4.SetConeS(2400);
MRBrst4.Conex=2401:2405;
MRBkey{4}=MRBrst4;

% Clave 5
MRBrst5=clave(MRB13, 1,  MRB07, 1, MRB08, 1);
MRBrst5.SetConeS(2500);
MRBrst5.Conex=2501:2505;
MRBkey{5}=MRBrst5;

% Clave 6
MRBrst6=clave(MRB14, 1,  MRB11, 1, MRB12, 1);
MRBrst6.SetConeS(2600);
MRBrst6.Conex=2601:2605;
MRBkey{6}=MRBrst6;

% Clave 7
MRBrst7=clave(MRB16, 1,  MRB05, 1, MRB06, 1);
MRBrst7.SetConeS(2700);
MRBrst7.Conex=2701:2705;
MRBkey{7}=MRBrst7;

% Clave 8
MRBrst8=clave(MRB15, 1,  MRB09, 1, MRB10, 1);
MRBrst8.SetConeS(2800);
MRBrst8.Conex=2801:2805;

MRBkey{8}=MRBrst8;

%% Se añaden las claves al modelo

MRB.Adds(MRBrst1);
MRB.Adds(MRBrst2);
MRB.Adds(MRBrst3);
MRB.Adds(MRBrst4);
MRB.Adds(MRBrst5);
MRB.Adds(MRBrst6);
MRB.Adds(MRBrst7);
MRB.Adds(MRBrst8);
%% Dibujo topología, geometria,.. 2D
subsection ('        plot2D')

f=iniFigureArcoTSAM(101);
if(amImatlab) f.Name='topo2D, claves'; end;
global ucs2D;
ucs2D = true;
g=MRB.plot;
set(g,'facealpha',.0);

ucs2D = true;
c=colorcube(numel(MRBkey));
for iKey =1:numel(MRBkey)
    g=MRBkey{iKey}.plot;
    set(g,'facecolor',c(iKey,:));
    MRBkey{iKey}.plotname;
end
f=iniFigureArcoTSAM(102);
if (amImatlab) f.Name='nombre elementos'; end;
MRB.plot;
MRB.plotname;
f=iniFigureArcoTSAM(103); 
if (amImatlab) f.Name='numero elementos'; end;
MRB.plot;
MRB.plotn;
ucs2D = false;

%% Dibujo topología, geometria,.. 3D
subsection ('        plot3D')
f=iniFigureArcoTSAM(111);
if (amImatlab) f.Name='topo3D, juntas, apoyos'; end;

MRB.plot;    % Topología
MRB.plotj;   % juntas
MRB.plota;   % Apoyos
c=colorcube(numel(MRBkey));
for iKey =1:numel(MRBkey)
    g=MRBkey{iKey}.plot;
    set(g,'facecolor',c(iKey,:));
    MRBkey{iKey}.plotname;
end


f=iniFigureArcoTSAM(112);
if (amImatlab) f.Name='nombre elementos'; end;
MRB.plot;    % Topología
MRB.plotname;
f=iniFigureArcoTSAM(113);
if (amImatlab) f.Name='numero elementos'; end;
g=MRB.plot;    % Topología
%set(g,'facealpha',.0);
g=MRB.plotn;   % numero de cada elemento


