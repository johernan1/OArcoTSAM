%% Boveda Vandelvira
% Geometría y Topología
% 

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro');
addpath('Datos');

subsection ('topoBovedaVandelvira')
%% GEOMETRIA Y TOPOLOGIA
%

subsection ('        topo')
%% Se lee geometría y topología en formato antiguo (mws)
datos_b2

%% Para cada uno de los arcos se transforma geometría y topología mws, 
% se "desplazan" las conex (índices de las EQU) y se añaden las cc.
% Se disminuye el PP de los arcos 2 y 4 pues de otro modo no es posible el
% equilibrio. Otro modo es ligar el movimiento horizontal de sus claves,
% ligadura que puede justificarse si existe plementería

MRB01=mpl2RB210(g01,t01);
MRB01.MoveConex(100);
MRB01.elems{ 8}.Conex(1,:)=[0 0 0];
MRB01.elems{17}.Conex(1,:)=[0 0 0];
apoyoAsiento1=MRB01.elems{ 8};

MRB02=mpl2RB210(g02,t02);
MRB02.MoveConex(250);
MRB02.elems{ 8}.Conex(1,:)=[0 0 0];
MRB02.elems{17}.Conex(1,:)=[0 0 0];


MRB03=mpl2RB210(g03,t03);
MRB03.MoveConex(500);
%MRB03.elems{5}.Conex(1,:)=[0 0 0];

MRB04=mpl2RB210(g04,t04);
MRB04.MoveConex(600);
MRB04.elems{5}.Conex(1,:)=[0 0 0];
%MRB04.SetRho(0.5);  % Se disminuye PP para que sea estable el conjunto

MRB05=mpl2RB210(g05,t05);
MRB05.MoveConex(700);
MRB05.elems{5}.Conex(1,:)=[0 0 0];
%apoyoAsiento5=MRB05.elems{5};

MRB06=mpl2RB210(g06,t06);
MRB06.MoveConex(800);
MRB06.elems{5}.Conex(1,:)=[0 0 0];

MRB07=mpl2RB210(g07,t07);
MRB07.MoveConex(900);
MRB07.elems{5}.Conex(1,:)=[0 0 0];
apoyoAsiento7=MRB07.elems{ 5};

MRB08=mpl2RB210(g08,t08);
MRB08.MoveConex(1000);
%MRB08.elems{2}.Conex(1,:)=[0 0 0];

MRB09=mpl2RB210(g09,t09);
MRB09.MoveConex(1100);
MRB09.elems{5}.Conex(1,:)=[0 0 0];

MRB10=mpl2RB210(g10,t10);
MRB10.MoveConex(1200);
MRB10.elems{5}.Conex(1,:)=[0 0 0];
apoyoAsiento10=MRB10.elems{ 5};

MRB11=mpl2RB210(g11,t11);
MRB11.MoveConex(1300);
MRB11.elems{5}.Conex(1,:)=[0 0 0];

MRB12=mpl2RB210(g12,t12);
MRB12.MoveConex(1400);
MRB12.elems{5}.Conex(1,:)=[0 0 0];
%apoyoAsiento12=MRB12.elems{2};

MRB13=mpl2RB210(g13,t13);
MRB13.MoveConex(1500);

MRB14=mpl2RB210(g14,t14);
MRB14.MoveConex(1600);

MRB15=mpl2RB210(g15,t15);
MRB15.MoveConex(1700);

MRB16=mpl2RB210(g16,t16);
MRB16.MoveConex(1800);

MRB17=mpl2RB210(g17,t17);
MRB17.MoveConex(1900);

MRB18=mpl2RB210(g18,t18);
MRB18.MoveConex(2000);

MRB19=mpl2RB210(g19,t19);
MRB19.MoveConex(2100);

MRB20=mpl2RB210(g20,t20);
MRB20.MoveConex(2200);
%MRB10.elems{5}.Conex(2,:)=[0 0 0];

MRB21=mpl2RB210(g21,t21);
MRB21.MoveConex(2300);
%MRB11.elems{5}.Conex(2,:)=[0 0 0];

MRB22=mpl2RB210(g22,t22);
MRB22.MoveConex(2400);
%MRB12.elems{2}.Conex(1,:)=[0 0 0];
%apoyoAsiento12=MRB12.elems{2};

MRB23=mpl2RB210(g23,t23);
MRB23.MoveConex(2500);

MRB24=mpl2RB210(g24,t24);
MRB24.MoveConex(2600);

MRB25=mpl2RB210(g25,t25);
MRB25.MoveConex(2700);

MRB26=mpl2RB210(g26,t26);
MRB26.MoveConex(2800);

MRB27=mpl2RB210(g27,t27);
MRB27.MoveConex(2900);

MRB28=mpl2RB210(g28,t28);
MRB28.MoveConex(3000);


%% Orientación, en planta, de cada uno de los arcos

angulo=26.52;
MRB01.ucsA=-pi/4;
MRB02.ucsA= pi/4;
MRB03.ucsA= 0;
MRB04.ucsA= (90-angulo)*pi/180;
MRB05.ucsA=-(270-angulo)*pi/180;
MRB06.ucsA= (270-angulo)*pi/180;
MRB07.ucsA=-( 90-angulo)*pi/180;
MRB08.ucsA=  -90*pi/180;
MRB09.ucsA=  angulo*pi/180;
MRB10.ucsA= -angulo*pi/180;
MRB11.ucsA= -angulo*pi/180;
MRB12.ucsA=  angulo*pi/180;

MRB13.ucsA=  67.5*pi/180;
MRB14.ucsA=  22.5*pi/180;
MRB15.ucsA= -22.5*pi/180;
MRB16.ucsA= -67.5*pi/180;
MRB17.ucsA= -112.5*pi/180;
MRB18.ucsA= -157.5*pi/180;
MRB19.ucsA=  157.5*pi/180;
MRB20.ucsA=  112.5*pi/180;

MRB21.ucsA=  67.5*pi/180;
MRB22.ucsA=  22.5*pi/180;
MRB23.ucsA= -22.5*pi/180;
MRB24.ucsA= -67.5*pi/180;
MRB25.ucsA= -112.5*pi/180;
MRB26.ucsA= -157.5*pi/180;
MRB27.ucsA=  157.5*pi/180;
MRB28.ucsA=  112.5*pi/180;

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
MRB.Adds(MRB17);
MRB.Adds(MRB18);
MRB.Adds(MRB19);
MRB.Adds(MRB20);
MRB.Adds(MRB21);
MRB.Adds(MRB22);
MRB.Adds(MRB23);
MRB.Adds(MRB24);
MRB.Adds(MRB25);
MRB.Adds(MRB26);
MRB.Adds(MRB27);
MRB.Adds(MRB28);
 
%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 
subsection ('        SetConeS')
MRB.SetConeS;

%% LAS CLAVES
%
subsection ('        claves')
% Clave 1
MRBrst1=clave(MRB01,9,MRB02,9,MRB08,5,MRB03,5);
MRBrst1.SetConeS(3100);
MRBrst1.Conex=3101:3105;
MRBkey{1}=MRBrst1;
MRBkey{1}.name='C1';

% Clave 2
MRBrst2=clave(MRB03, 9, MRB04, 1, MRB05, 1, MRB13, 3, MRB20, 2);
MRBrst2.SetConeS(3200);
MRBrst2.Conex=3201:3205;
MRBkey{2}=MRBrst2;
MRBkey{2}.name='C2';

% Clave 3
MRBrst3=clave(MRB03, 4, MRB06, 1, MRB07, 1, MRB16, 2, MRB17, 3);
MRBrst3.SetConeS(3300);
MRBrst3.Conex=3301:3305;
MRBkey{3}=MRBrst3;
MRBkey{3}.name='C3';

% Clave 4
MRBrst4=clave(MRB08, 4, MRB09, 1, MRB10, 1, MRB18, 2, MRB19, 3);
MRBrst4.SetConeS(3400);
MRBrst4.Conex=3401:3405;
MRBkey{4}=MRBrst4;
MRBkey{4}.name='C4';

% Clave 5
MRBrst5=clave(MRB08, 9,  MRB11, 1, MRB12, 1, MRB14, 2, MRB15, 3);
MRBrst5.SetConeS(3500);
MRBrst5.Conex=3501:3505;
MRBkey{5}=MRBrst5;
MRBkey{5}.name='C5';

% Clave 6
MRBrst6=clave(MRB01, 13,  MRB13, 2, MRB14, 3);
MRBrst6.SetConeS(3600);
MRBrst6.Conex=3601:3605;
MRBkey{6}=MRBrst6;
MRBkey{6}.name='C6';
 
% % Clave 7
MRBrst7=clave(MRB02, 4,  MRB15, 2, MRB16, 3);
MRBrst7.SetConeS(3700);
MRBrst7.Conex=3701:3705;
MRBkey{7}=MRBrst7;
MRBkey{7}.name='C7';

% Clave 8
MRBrst8=clave(MRB01, 4,  MRB17, 2, MRB18, 3);
MRBrst8.SetConeS(3800);
MRBrst8.Conex=3801:3805;
MRBkey{8}=MRBrst8;
MRBkey{8}.name='C8';

% Clave 9
MRBrst9=clave(MRB02,13,  MRB19, 2, MRB20, 3);
MRBrst9.SetConeS(3900);
MRBrst9.Conex=3901:3905;
MRBkey{9}=MRBrst9;
MRBkey{9}.name='C9';

% Clave 10
MRBrst10=clave(MRB03, 7,  MRB21, 3, MRB28, 2);
MRBrst10.SetConeS(4000);
MRBrst10.Conex=4001:4005;
MRBkey{10}=MRBrst10;
MRBkey{10}.name='C10';

% Clave 11
MRBrst11=clave(MRB01,11,  MRB21, 2, MRB22, 3);
MRBrst11.SetConeS(4100);
MRBrst11.Conex=4101:4105;
MRBkey{11}=MRBrst11;
MRBkey{11}.name='C11';

% Clave 12
MRBrst12=clave(MRB08,7,  MRB22, 2, MRB23, 3);
MRBrst12.SetConeS(4200);
MRBrst12.Conex=4201:4205;
MRBkey{12}=MRBrst12;
MRBkey{12}.name='C12';

% Clave 13
MRBrst13=clave(MRB02,2,  MRB23, 2, MRB24, 3);
MRBrst13.SetConeS(4300);
MRBrst13.Conex=4301:4305;
MRBkey{13}=MRBrst13;
MRBkey{13}.name='C13';

% Clave 14
MRBrst14=clave(MRB03,2,  MRB24, 2, MRB25, 3);
MRBrst14.SetConeS(4400);
MRBrst14.Conex=4401:4405;
MRBkey{14}=MRBrst14;
MRBkey{14}.name='C14';

% Clave 15
MRBrst15=clave(MRB01,2,  MRB25, 2, MRB26, 3);
MRBrst15.SetConeS(4500);
MRBrst15.Conex=4501:4505;
MRBkey{15}=MRBrst15;
MRBkey{15}.name='C15';

% Clave 16
MRBrst16=clave(MRB08,2,  MRB26, 2, MRB27, 3);
MRBrst16.SetConeS(4600);
MRBrst16.Conex=4601:4605;
MRBkey{16}=MRBrst16;
MRBkey{16}.name='C16';

% Clave 17
MRBrst17=clave(MRB02,11,  MRB27, 2, MRB28, 3);
MRBrst17.SetConeS(4700);
MRBrst17.Conex=4701:4705;
MRBkey{17}=MRBrst17;
MRBkey{17}.name='C17';

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
MRB.Adds(MRBrst17);
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



