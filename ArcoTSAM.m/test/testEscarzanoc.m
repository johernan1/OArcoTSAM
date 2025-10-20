%% ARCO ESCARZANO
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
addpath('../ArcoTSAMprepro');
wobinichTamino;
iniMatlabOctave();

ndov =16;
MRB=mpl2RB210(geomEscarzano(10,5,1,ndov), topoRebajado(ndov));
% Apoyos
MRB.elems{1}.Conex(1,:)=[0 0 0];
MRB.elems{ndov}.Conex(2,:)=[0 0 0];
% Se introduce una perturbación para evitar soluciones simétricas, a las
% que converge el algoritmo de punto interior
% Si la perturbación es menor octave no converge ¿?
%MRB.elems{14}.rho=1.00001;
%  iniFigureArcoTSAM(1);
%  MRB.plot
%  pauseOctaveFig

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 

subsection('SetConeS')
MRB.SetConeS;

%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas

subsection('GetH')
H = MRB.GetH;
chk('H',full(sum(sum(H))),6);

%% CALCULO DEL VECTOR DE ACCIONES PERMANENTES
% Se calcula G. 
% La comprobacione solo es validas para una geometria
MRB.SetRho(MRB.elems{1}.rho/10); 
subsection ('SetG & GetG')
MRB.SetG(1);
vectG=MRB.Getf(1);
%chk('Hipotesis G', sum(vectG), 11.879817)

%% 1. CALCULO DEL EMPUJE MINIMO
% La comprobacion solo es valida para una geometria


subsection('Empuje minimo');
apoyoAsiento=MRB.elems{MRB.GetNelems};
ijunt=2;
alpha=pi*0;
gammau=.9;
minhdir=MRB.GethdirMinLPP(apoyoAsiento, ijunt, alpha, gammau);
fprintf('h = %12.6f\n', minhdir);
chk('LPP, min hd', minhdir, -3.806448, 1/100)
minhdirD=MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau, vectG);
fprintf('minhdirD=%f\n', minhdirD);
chk('LPP==LPD, min hd', minhdir, minhdirD)
chk('vectS LPP==LPD', MRB.GetVectS(1),MRB.GetVectS(2)); 
%chk('vectU LPP==LPD', MRB.GetVectU(1),MRB.GetVectU(2));
[MRB.GetVectU(1),MRB.GetVectU(2)]
%iniFigureArcoTSAM(1);

%MRB.plotu(1)
%MRB.plotu(2)
%pauseOctaveFig
%x=xxx
%% CORRECCION NL
% Se ajusta e=E(u) usando la aproximacion e=B_0·u, donde B_0 es la del 
% origen (metodo de NR modificado). 

subsection('Grandes movimientos');

%iniFigureArcoTSAM('Name', 'TestRB210b: Grandes movimientos (NO EQU; iter)');
iniFigureArcoTSAM(1);
 %if(~amImatlab)
 %    section ('PERTURBACION EN OCTAVE PARA EVITAR SIMETRIAS');
 %    MRB.elmvectG(8)=vectG(8)+1;
 %end
for i=1:10
    fprintf ('alpha=%f,gammau=%f, ', alpha, gammau);
    er=MRB.GetVectEr(MRB.GetNsol);
    [maxer,imax]=max(abs(er));
    fprintf ('max er=%f (indice=%d), ', maxer, imax);
    aux = MRB.GethdirMinLPDLM(apoyoAsiento, ijunt, alpha, gammau);
    fprintf ('h = %12.6f\n',aux);
    MRB.plotuLM(MRB.GetNsol);
end
disp (['Como no se actualiza B, er no tiende a 0 (no se anula),' ...
       ' se va "estabilizando" al iterar']); 
pauseOctaveFig
 if(~amImatlab)
     section ('SIN PRECISIÓN EN OCTAVE. SE SALE DE testEscarzaoc.m');
     section ('simplex no converge e interior point lo hace a una solución simetrica');
     return;
 end
chk('h', aux, -3.440383,1/100)



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
MRB.plotf(1);

iniFigureArcoTSAM(50);
MRB.plotuLM(true,MRB.GetNsol,1);
%MRB.plotVectSULM(-.05, true, MRB.GetNsol, 1);
%MRB.plotVectEULM(-1, true, MRB.GetNsol, 1);
%MRB.plotVectComoSULM(MRB.GetVectEULM(true, MRB.GetNsol),-1, true, MRB.GetNsol, 1);
MRB.plotVectComoSULM(MRB.GetVectEr,-10, true, MRB.GetNsol, 1);
%set(g,'facecolor','r')
%MRB.plotf(1);

%% Idem sin LP
%
% Deberían hallarse los mismos resultados sin necesidad de resolver un LP
% en cada iteración. Es más al no cambiar B, se puede usar de un modo muy
% eficiente el algoritmo QR.
% Se vuelve a calcular LP inicial para 'reiniciar' el proceso
MRB.clearSol;
MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau);
c=MRB.GetCFoHdir(apoyoAsiento, ijunt, alpha);
s=MRB.GetVectS;
s(3:3:numel(s))=100  % Se coaccionan los deslizamientos
s(abs(c)>10^-10)=0   % Se liberan los movimientos del apoyo
S=diag(s);

norm=MRB.iGetH(':',abs(c)>10^-5);
SB=[S*MRB.H'; norm'];  % La última fila es el criterio de normalización
% b=[MRB.GetVectEr(MRB.GetNsol)*0; -gammau];
% uSB=linsolve(full(SB),b);

%uSB=b\SB;

iniFigureArcoTSAM(52);
iniFigureArcoTSAM(51);
% MRB.SetMatJU(uSB)
% MRB.SetVectU(uSB)
MRB.plotuLM
% MRB.delu
% MRB.delju
eri=MRB.GetVectEr;
for i=1:10
    iniFigureArcoTSAM(52);
%     fprintf ('alpha=%f,gammau=%f, ', alpha, gammau);
     er=MRB.GetVectEr(MRB.GetNsol);
     eri=[eri er MRB.GetVectE s];
     MRB.plotVectComoSULM(MRB.GetVectEr,-10, true, MRB.GetNsol, 1);
     b=[S*MRB.GetVectEr(MRB.GetNsol); -gammau];
     uSB=linsolve(full(SB),b);
     eSB=MRB.H'*uSB;
     MRB.SetVectE(eSB);
     MRB.SetMatJU(uSB);
     MRB.SetVectU(uSB);
     [maxer,imax]=max(abs(er));
     fprintf ('max er=%f (indice=%d), ', maxer, imax);
%     aux = MRB.GethdirMinLPDLM(apoyoAsiento, ijunt, alpha, gammau);
%     fprintf ('h = %12.6f\n',aux);
     figure(51);
     MRB.plotuLM(MRB.GetNsol);
     MRB.plotujLM(MRB.GetNsol);
end


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
    MRB.plotf;  
    er=MRB.GetVectEr(MRB.GetNsol);
    [maxer,imax]=max(abs(er));
    fprintf ('max er=%f (indice=%d), ', maxer, imax);
    aux = MRB.GethdirMinLPDLMf(apoyoAsiento, ijunt, alpha, gammau);
    fprintf ('h = %12.6f\n',aux);
end
chk('MRB.GetLargeMf',aux,-3.531387,1/100);

disp (['Como no se actualiza B, er no tiende a 0 (no se anula),' ...
       ' se va "estabilizando" al iterar']);
   
pauseOctaveFig

%% DIBUJO

iniFigureArcoTSAM (15);

MRB.plotuLM(MRB.GetNsol);
MRB.plotf(1);

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
    MRB.plotf;
    % Se actualiza H
    if (mod(i,7)==0)
        fprintf('Se actualiza H\n')
        fprintf('SUM(SUM(H))=%f; sum(Er)=%f\n', sum(sum(full(MRB.H))) ,sum(MRB.GetVectEr))
        HULM=MRB.GetHULM;
        fprintf('SUM(SUM(H))=%f; sum(Er)=%f\n', sum(sum(full(MRB.H))) ,sum(MRB.GetVectEr))
    end
    er=MRB.GetVectEr(MRB.GetNsol);
    [maxer,imax]=max(abs(er));
    fprintf ('max er=%f (indice=%d), ', maxer, imax);
    hdir=MRB.GetCFoHdir(apoyoAsiento, ijunt, alpha);
    aux =  MRB.GethdirMinLPDLMf(apoyoAsiento,ijunt,alpha, gammau, hdir);
end
chk('hLM', aux, -3.531387);

pauseOctaveFig

%% DIBUJO

iniFigureArcoTSAM (25);
%MRB.GetLargeMf(2,1,alpha, gammau)
MRB.plotuLM(MRB.GetNsol);
MRB.plotujLM(MRB.GetNsol);
MRB.plotf(1);
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
    MRB.elems{idov}.epsEQU=10^-6; 
    chk( sprintf('chkEQU idov=%2d (EQU  geomeLM: H=H(u), f=f(u))',idov), MRB.elems{idov}.isEQU(1));
    subsection('.',0,-3,'.');
end

pauseOctaveFig
