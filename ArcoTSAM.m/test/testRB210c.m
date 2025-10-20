%% DOLMEN
% Calculo de min(h_dir) para LM
% Indice
%   1. Metodo de NR modificado. Para resolver e=E(u) itera con e=B_0·u
%   2. Idem, pero en cada iteracion se ajusta f a la nueva geometria
%   3. Metodo de NR. En cada iteracion se aproxima e=E(u) por e=B_{t-1}·u
clear all;

%% GEOMETRIA Y TOPOLOGIA
%

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('Datos/');
wobinichTamino;
iniMatlabOctave();

ndov = 3;
[elem222, ~, elem210] = datos_dolmen; 

RB1 = ArcoTSAM_RB210NL(elem210{1});
RB2 = ArcoTSAM_RB210NL(elem210{2});
RB3 = ArcoTSAM_RB210NL(elem210{3});

MRB = ArcoTSAM_ModeloNL();
MRB.Adds(RB1);
MRB.Adds(RB2);
MRB.Adds(RB3);

%% Chequeo GDL
iniFigureArcoTSAM(1);
MRB.plot;
MRB.plotConex;

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 

subsection('SetConeS')
MRB.SetConeS;

%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas

subsection('GetH')
H = MRB.GetH;
chk('H',sum(sum(H)),37);

%% 1. CALCULO DEL EMPUJE MINIMO
% La comprobacion solo es valida para una geometria. Se ajusta rho
MRB.SetRho(MRB.elems{1}.rho/10); 

subsection('Empuje minimo');
apoyoAsiento=MRB.elems{2};
ijunt=1;
alpha=pi;
gammau=1.1;

minhdir=MRB.GethdirMinLPP(apoyoAsiento, ijunt, alpha, gammau);
fprintf('h = %12.6f\n', minhdir);
chk('LPP, min hd', minhdir, -7.15)
minhdirD=MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau);
fprintf('minhdirD=%f\n', minhdirD);
chk('LPP==LPD, min hd', minhdir, minhdirD)
chk('vectS LPP==LPD', MRB.GetVectS(1),MRB.GetVectS(2)); 

%% CORRECCION NL
% Se ajusta e=E(u) usando la aproximacion e=B_0·u, donde B_0 es la del 
% origen (metodo de NR modificado). 

subsection('Grandes movimientos');

%iniFigureArcoTSAM('Name', 'TestRB210b: Grandes movimientos (NO EQU; iter)');
iniFigureArcoTSAM(2);
for i=1:10
    aux = MRB.GethdirMinLPDLM(apoyoAsiento, ijunt, alpha, gammau);
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
for idov =1 : ndov
    MRB.elems{idov}.epsEQU=10^-6;
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU  geome0, f  geome0)\n', ... 
        MRB.elems{idov}.chkEQU(0))
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU geomeLM, f  geome0)\n', ...
         MRB.elems{idov}.chkEQU(1))
    chk(sprintf('chkEQU idov=%2d (EQU H_0, f=f_0)',idov), MRB.elems{idov}.isEQU(0)); 
    subsection('.',0,-3,'.'); 
end

MRB.plotRjULM(-.25, false, MRB.GetNsol, 0);
MRB.plotf(.1);
%% 2. CALCULO DEL EMPUJE MINIMO
% Se comprueba que el resultado es el mismo que el de la seccion 1


subsection('min hd (segundo calculo; H=H0, f=f(u))')
minhdir2=MRB.GethdirMinLPP(apoyoAsiento, ijunt, alpha, gammau);
fprintf('h = %12.6f\n', minhdir2);
chk('minhdir2==minhdir', minhdir2, minhdir);
minhdirD2=MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau);
chk('minhdirD2==minhdirD', minhdir, minhdirD2);

%chk('vectU LPP==LPD', sum(MRB.GetVectU-MRB.GetVectU(-1)), 0); 
chk('vectS LPP==LPD', sum(MRB.GetVectS-MRB.GetVectS(-1)), 0); 

%% CORRECCION NL AJUSTANDO POSICION DE f
% Se ajusta e=E(u) usando la aproximacion e=Bu, donde B es la del origen 
% (metodo NR modificado). En cada iteracion se ajusta el vector f lo cual
% solo tiene un interes teorico. No parece mejorar ni empeorar la 
% convergencia, pero pueden detectarse soluciones en las cuales el 
% equilibrio no es posible (para gammau muy grandes, por ejemplo)  

iniFigureArcoTSAM (11);

for i=1:10
    MRB.plotuLM;
    MRB.plotf(.1);
    aux = MRB.GethdirMinLPDLMf(apoyoAsiento, ijunt, alpha, gammau);
    fprintf ('h = %12.6f\n',aux);
end
chk('MRB.GetLargeMf',aux,-3.809666);

pauseOctaveFig

%% DIBUJO

iniFigureArcoTSAM (15);

MRB.plotuLM(MRB.GetNsol);
MRB.plotf(.1);

pauseOctaveFig

%% CHEQUEO DE EQU
% Hay equilibrio SOLO para la geometría inicial y las cargas
% correspondientes a la geometria FINAL

subsection ('chkEQU sobre geometria INICIAL: H=H0. F posicion FINAL: f=f(u)')

for idov =1 : ndov
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU  geome0, f=f(u))\n', ... 
        MRB.elems{idov}.chkEQU(0))
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU geomeLM, f=f(u)M)\n', ...
        MRB.elems{idov}.chkEQU(1))
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU geomeLM, f=f0)\n', ...
        MRB.elems{idov}.chkEQU(1, MRB.GetNsol, 1, 1))
    chk('chkEQU idov (EQU  geomeNL, f  geomeLM)',MRB.elems{idov}.isEQU(0));

    subsection('.',0,-3,'.');
end

%% CHEQUEO e
% Varios calculos relativos a vector e:
% 
% e=Bu                                          -> MRB.H'*MRB.GetVectUAmp
% e=solucion de LP                              -> MRB.GetVectE
% e=E(u) (con cos(theta)=1 y sen(theta)=theta)  -> MRB.GetVectEULM(false)
% Por tanto, las tres primeras columnas que se imprime a continuacion deben
% ser iguales.
%
% e=E(u) (calculo de e incluyendo LM)           -> MRB.GetVectEULM(true)
%
% residuo (diferencia entre los dos anteriores) -> MRB.GetVectEr

subsection ('chk E')

disp '-----HLM*u,    VectE, VectELMf,  VectELM,   VectEr'; 
cat(2,MRB.H'*MRB.GetVectUAmp,MRB.GetVectE, MRB.GetVectEULM(false), ... 
      MRB.GetVectEULM(true), MRB.GetVectEr)
disp '^^^^^HLM*u,    VectE, VectELMf,  VectELM,   VectEr'; 

MRB.plotRjULM(-.25, false, MRB.GetNsol, 0);

%% INFO e
% Se imprime los calulos GetEULM(false) y GetEULM(true) para RB1

of = iniDiaryArcoTSAM(['/tmp/' mfilename '_RB1_infoEULM_false_NRm.txt']);
section1 (['info E: Se crea el fichero ' of])
RB1.infoEULM(false)
diary off
visdiff(of, ['chk_logs/' mfilename '_RB1_infoEULM_false_NRm.txt'])

of = iniDiaryArcoTSAM(['/tmp/' mfilename '_RB1_infoEULM_true_NRm.txt']);
section1 (['info E: Se crea el fichero ' of])
RB1.infoEULM(true)
diary off
visdiff(of, ['chk_logs/' mfilename '_RB1_infoEULM_true_NRm.txt']);

%% 3  CALCULO DEL EMPUJE MINIMO
% Se comprueba que el resultado es el mismo que el de la seccion 1

iniFigureArcoTSAM (21);

subsection ('min hd (tercer calculo)')
minhdirD3=MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau);
chk('LPD3, min hd', minhdirD3, minhdir);
minhdirP3=MRB.GethdirMinLPP(apoyoAsiento, ijunt, alpha, gammau);
chk('LPP3, min hd', minhdirP3, minhdir);

%chk('vectU LPP==LPD', sum(MRB.GetVectU-MRB.GetVectU(-1)), 0); 
chk('vectS LPP==LPD', sum(MRB.GetVectS-MRB.GetVectS(-1)), 0);

%% CORRECCION NL AJUSTANDO B Y POSICION DE f
% Se ajusta e=E(u) usando la aproximacion e=Bu, donde B es la del origen 
% (u=0) en la primera iteracion y en las siguientes iteraciones la 
% correspondiente a la iteración anterior (metodo NR). En cada iteracion se
% ajusta el vector f lo cual por lo que en la última iteracion se satisface 
% e=B(u) y las condiciones de equilibrio.
% La convergencia es significativamente mas lenta, incluso en puede no
% converger el algoritmo. Parece mas eficiente utilizar el metod de NR
% modificado, ajustando B cada cierto numero de iteraciones.

for i=1:20 
    fprintf ('hLM = %12.6f\n',aux);
    MRB.plotuLM(MRB.GetNsol);
    MRB.plotf(.1);
    % Se actualiza H
    HULM=MRB.GetHULM;
    hdir=MRB.GetCFoHdir(apoyoAsiento, ijunt, alpha);
    aux =  MRB.GethdirMinLPDLMf(apoyoAsiento,ijunt,alpha, gammau, hdir);
end
chk('hLM', aux, -3.809666);

pauseOctaveFig

%% DIBUJO

iniFigureArcoTSAM (25);
%MRB.GetLargeMf(2,1,alpha, gammau)
MRB.plotuLM(MRB.GetNsol);
MRB.plotujLM(MRB.GetNsol);
MRB.plotf(.1);
MRB.plotRjULM(-.25, 1, MRB.GetNsol, true);

pauseOctaveFig

%% CHEQUEO DE EQU
% Hay equilibrio SOLO para la geometría FINAL y las cargas
% correspondientes a dicha geometria FINAL

subsection ('chkEQU sobre geometria DEFORMADA. H=H(u), f=f(u)')

nHip=MRB.GetNHipts;
for idov =1 : ndov
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU  geome0: H=H0, f=f(u))\n', ... 
        MRB.elems{idov}.chkEQU(0))
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU geomeLM: H=H(u), f=f(u))\n', ...
        MRB.elems{idov}.chkEQU(1))
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU geomeLM: H=H(u), f=f0)\n', ...
        MRB.elems{idov}.chkEQU(1, MRB.GetNsol, 1, 1))
    chk( sprintf('chkEQU idov=%2d (EQU  geomeLM: H=H(u), f=f(u))',idov), MRB.elems{idov}.isEQU(1));
    subsection('.',0,-3,'.');
end

%% CHEQUEO e
% Varios calculos relativos a vector e:
% 
% e=Bu                                          -> MRB.H'*MRB.GetVectUAmp
% e=solucion de LP                              -> MRB.GetVectE
% e=E(u) (con cos(theta)=1 y sen(theta)=theta)  -> MRB.GetVectEULM(false)
% Las dos primeras columnas que se imprime a continuacion deben ser
% iguales, pero no la tercera.
% La tercera coincide con las primeras columnas de la seccion 2. Es logico,
% pues mide las deformaciones IM del modelo inicia. e=Bu mide ahora las
% deformaciones respecto de la geometría de la iteracion t-1
%
% e=E(u) (calculo de e incluyendo LM)           -> MRB.GetVectEULM(true)
%
% residuo (diferencia entre los dos anteriores) -> MRB.GetVectEr

subsection ('chkE')

disp '-----HLM*u,    VectE, VectELMf,  VectELM,   VectEr'; 

cat(2,MRB.H'*MRB.GetVectUAmp,MRB.GetVectE, MRB.GetVectEULM(false), ...
      MRB.GetVectEULM(true), MRB.GetVectEr)
disp '^^^^^HLM*u,    VectE, VectELMf,  VectELM,   VectEr'; 

%% INFO e
% Se imprime los calulos GetEULM(false) y GetEULM(true) para RB1

of = iniDiaryArcoTSAM(['/tmp/' mfilename '_RB1_infoEULM_false.txt']);
section1 (['info E: Se crea el fichero ' of]);
RB1.infoEULM(false)
diary off
visdiff(of, ['chk_logs/' mfilename '_RB1_infoEULM_false.txt']);

of = iniDiaryArcoTSAM(['/tmp/' mfilename '_RB1_infoEULM_true.txt']);
section1 (['info E: Se crea el fichero ' of])
RB1.infoEULM(true)
diary off
visdiff(of, ['chk_logs/' mfilename '_RB1_infoEULM_true.txt']);

pauseOctaveFig
