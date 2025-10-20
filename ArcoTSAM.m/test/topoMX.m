%% Boveda Mexico
% Geometría y Topología
% 

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro');
addpath('Datos');

subsection ('topoMexico')
%% GEOMETRIA Y TOPOLOGIA
%

subsection ('        topo')
%% Se lee geometría y topología en formato antiguo (mws)
datos_MX

%% Para cada uno de los arcos se transforma geometría y topología mws, 
% se "desplazan" las conex (índices de las EQU) y se añaden las cc.

MRB01=mpl2RB210(g01,t01);
MRB01.MoveConex(100);
MRB01.elems{1}.Conex(1,:)=[0 0 0];
MRB01.elems{8}.Conex(2,:)=[0 0 0];
apoyoAsiento1=MRB01.elems{1};

MRB02=mpl2RB210(g02,t02);
MRB02.MoveConex(200);
MRB02.elems{1}.Conex(1,:)=[0 0 0];
MRB02.elems{8}.Conex(2,:)=[0 0 0];
%MRB02.SetRho(0.5);  % Se disminuye PP para que sea estable el conjunto

MRB03=mpl2RB210(g03,t03);
MRB03.MoveConex(300);
MRB03.elems{1}.Conex(1,:)=[0 0 0];
MRB03.elems{8}.Conex(2,:)=[0 0 0];

MRB04=mpl2RB210(g04,t04);
MRB04.MoveConex(400);
MRB04.elems{1}.Conex(1,:)=[0 0 0];
MRB04.elems{8}.Conex(2,:)=[0 0 0];
%MRB04.SetRho(0.5);  % Se disminuye PP para que sea estable el conjunto

MRB05=mpl2RB210(g05,t05);
MRB05.MoveConex(500);
MRB05.elems{1}.Conex(1,:)=[0 0 0];
MRB05.elems{13}.Conex(2,:)=[0 0 0];
apoyoAsiento5=MRB05.elems{5};

MRB06=mpl2RB210(g06,t06);
MRB06.MoveConex(600);
MRB06.elems{1}.Conex(1,:)=[0 0 0];
MRB06.elems{13}.Conex(2,:)=[0 0 0];

MRB07=mpl2RB210(g07,t07);
MRB07.MoveConex(700);
MRB07.elems{1}.Conex(1,:)=[0 0 0];
MRB07.elems{13}.Conex(2,:)=[0 0 0];

MRB08=mpl2RB210(g08,t08);
MRB08.MoveConex(800);
MRB08.elems{1}.Conex(1,:)=[0 0 0];
MRB08.elems{13}.Conex(2,:)=[0 0 0];



%% Orientación, en planta, de cada uno de los arcos

MRB01.ucsA= pi/2;
MRB02.ucsA= pi/2;
MRB03.ucsA= pi/2;
MRB04.ucsA= pi/2;


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
 
%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 
subsection ('        SetConeS')
MRB.SetConeS;

%% LAS CLAVES
%
subsection ('        claves')
% Clave 1
MRBrst1=clave(MRB01, 3, MRB05, 4);
MRBrst1.SetConeS(2100);
MRBrst1.Conex=2101:2105;
MRBkey{1}=MRBrst1;
 
% Clave 2
MRBrst2=clave(MRB01, 4, MRB06, 4);
MRBrst2.SetConeS(2200);
MRBrst2.Conex=2201:2205;
MRBkey{2}=MRBrst2;

% Clave 3
MRBrst3=clave(MRB01, 5, MRB07, 4);
MRBrst3.SetConeS(2300);
MRBrst3.Conex=2301:2305;
MRBkey{3}=MRBrst3;

% Clave 4
MRBrst4=clave(MRB01, 6, MRB08, 4);
MRBrst4.SetConeS(2400);
MRBrst4.Conex=2401:2405;
MRBkey{4}=MRBrst4;

% Clave 5
MRBrst5=clave(MRB05, 6, MRB02, 3);
MRBrst5.SetConeS(2500);
MRBrst5.Conex=2501:2505;
MRBkey{5}=MRBrst5;
 
% Clave 6
MRBrst6=clave(MRB06, 6, MRB02, 4);
MRBrst6.SetConeS(2600);
MRBrst6.Conex=2601:2605;
MRBkey{6}=MRBrst6;

% Clave 7
MRBrst7=clave(MRB07, 6, MRB02, 5);
MRBrst7.SetConeS(2700);
MRBrst7.Conex=2701:2705;
MRBkey{7}=MRBrst7;

% Clave 8
MRBrst8=clave( MRB08, 6, MRB02, 6);
MRBrst8.SetConeS(2800);
MRBrst8.Conex=2801:2805;
MRBkey{8}=MRBrst8;

% Clave 9
MRBrst9=clave(MRB05, 8, MRB03, 3);
MRBrst9.SetConeS(2900);
MRBrst9.Conex=2901:2905;
MRBkey{9}=MRBrst9;
 
% Clave 10
MRBrst10=clave(MRB06, 8, MRB03, 4);
MRBrst10.SetConeS(3000);
MRBrst10.Conex=3001:3005;
MRBkey{10}=MRBrst10;

% Clave 11
MRBrst11=clave(MRB07, 8, MRB03, 5);
MRBrst11.SetConeS(3100);
MRBrst11.Conex=3101:3105;
MRBkey{11}=MRBrst11;

% Clave 12
MRBrst12=clave( MRB08, 8, MRB03, 6);
MRBrst12.SetConeS(3200);
MRBrst12.Conex=3201:3205;
MRBkey{12}=MRBrst12;


% Clave 13
MRBrst13=clave(MRB05,10, MRB04, 3);
MRBrst13.SetConeS(3300);
MRBrst13.Conex=3301:3305;
MRBkey{13}=MRBrst13;
 
% Clave 14
MRBrst14=clave(MRB06,10, MRB04, 4);
MRBrst14.SetConeS(3400);
MRBrst14.Conex=3401:3405;
MRBkey{14}=MRBrst14;

% Clave 15
MRBrst15=clave(MRB07,10, MRB04, 5);
MRBrst15.SetConeS(3500);
MRBrst15.Conex=3501:3505;
MRBkey{15}=MRBrst15;

% Clave 16
MRBrst16=clave( MRB08,10, MRB04, 6);
MRBrst16.SetConeS(3600);
MRBrst16.Conex=3601:3605;
MRBkey{16}=MRBrst16;
%% Se añaden las claves al modelo

MRB.Adds(MRBrst1);
MRB.Adds(MRBrst2);
MRB.Adds(MRBrst3);
MRB.Adds(MRBrst4);
MRB.Adds(MRBrst5);
MRB.Adds(MRBrst6);
MRB.Adds(MRBrst7);
MRB.Adds(MRBrst8);
MRB.Adds(MRBrst9);
MRB.Adds(MRBrst10);
MRB.Adds(MRBrst11);
MRB.Adds(MRBrst12);
MRB.Adds(MRBrst13);
MRB.Adds(MRBrst14);
MRB.Adds(MRBrst15);
MRB.Adds(MRBrst16);
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


