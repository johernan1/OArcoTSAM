%% DOLMEN
% Calculo de min(h_dir) para LM. Este 'test' es similar al testRB210c.m
% salvo porque se definen explicitamente las componentes de las 
% reacciones.
% Indice
%   1. Metodo de NR modificado. Para resolver e=E(u) itera con e=B_0·u
clear all;

%% GEOMETRIA Y TOPOLOGIA
%

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('Datos/');
wobinichTamino;
iniMatlabOctave();

[elem222, ~, ~, elem210] = datos_dolmen; 

RB1 = ArcoTSAM_RB210NL(elem210{1});
RB2 = ArcoTSAM_RB210NL(elem210{2});
RB3 = ArcoTSAM_RB210NL(elem210{3});
%RB3.Geome(1,1)=RB3.Geome(1,1)*(1+10^-6);
%RB3.Geome(4,1)=RB3.Geome(4,1)*(1+10^-6);
RB3.Junta(3,:)=[];
RB3.Conex(4,:)=[];

MRB = ArcoTSAM_ModeloNL();
MRB.Adds(RB1);
MRB.Adds(RB2);
MRB.Adds(RB3);

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 

subsection ('SetConeS')
MRB.SetConeS;

%% Reacciones

MRB.elems{   1}.ConeS = cat(2, MRB.elems{   1}.ConeS, ...
                        [MRB.GetNs+1,   MRB.GetNs+2, MRB.GetNs+3]);
                    
MRB.GetNs;

MRB.elems{   2}.ConeS = cat(2, MRB.elems{2}.ConeS, ...
                        [MRB.GetNs+1, MRB.GetNs+2, MRB.GetNs+3]);
%% Chequeo GDL
iniFigureArcoTSAM(1);
MRB.plot;
MRB.plotConex;

%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas

subsection('GetH')
H = MRB.GetH;
chk('H', sum(sum(full(H))), 21.5);

%% 1. CALCULO DEL EMPUJE MINIMO
% La comprobacion solo es valida para una geometria
MRB.SetRho(MRB.elems{1}.rho/10); 

subsection('Empuje minimo');
apoyoAsiento=MRB.elems{2};
ijunt=3;
alpha=pi;
gammau=1.1;
minhdir=MRB.GethdirMinLPP(apoyoAsiento, ijunt, alpha, gammau);
fprintf('h = %12.6f\n', minhdir);
chk('LPP, min hd', minhdir, -7.15)
minhdirD=MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau);
fprintf('minhdirD=%f\n', minhdirD);
chk('LPP==LPD, min hd', minhdir, minhdirD)

%% CORRECCION NL
% Se ajusta e=E(u) usando la aproximacion e=B_0·u, donde B_0 es la del 
% origen (metodo de NR modificado). 

subsection('Grandes movimientos');

%iniFigureArcoTSAM('Name', 'TestRB210b: Grandes movimientos (NO EQU; iter)');
iniFigureArcoTSAM(2);
for i=1:10
    aux =  MRB.GethdirMinLPDLM(apoyoAsiento,ijunt,alpha, gammau);
    fprintf ('h = %12.6f\n',aux);
    MRB.plotuLM(MRB.GetNsol);
end
chk('h', aux, -5.851751)

%% DIBUJO
iniFigureArcoTSAM(5);
%iniFigureArcoTSAM('Name', 'TestRB210b: Grandes movimientos (NO EQU)');

MRB.plotuLM(MRB.GetNsol);

pauseOctaveFig

%% CHEQUEO DE EQU
% Hay equilibrio SOLO para la geometría inicial y las cargas
% correspondientes a dicha geometria inicial

subsection('chkEQU sobre geometria INICIAL. F posicion inicial')
ndov=3;
%nHip=MRB.GetNHipts;
for idov =1 : ndov
    MRB.elems{idov}.epsEQU=10^-6;
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU  geome0, f  geome0)\n', ... 
        MRB.elems{idov}.chkEQU(0))
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU geomeLM, f  geome0)\n', ...
         MRB.elems{idov}.chkEQU(1))
    chk('chkEQU idov (EQU  geome0, f  geome0)', MRB.elems{idov}.isEQU(0));
    subsection('.',0,-3,'.'); 
end

MRB.plotRjULM(-.25, false, MRB.GetNsol, 0);
MRB.plotf(.1);
