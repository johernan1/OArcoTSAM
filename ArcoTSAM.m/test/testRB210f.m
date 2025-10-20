clear all;

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro');
addpath('Datos/');
wobinichTamino;
iniMatlabOctave();

ndov=3;
MRB=mpl2RB210(geomEscarzano(10,5,1,ndov), topoRebajado(ndov));

subsection ('SetConeS')
MRB.SetConeS;

MRB.GetNs

% Reacciones
MRB.elems{   1}.ConeS = cat(2, MRB.elems{   1}.ConeS, ...
                        [MRB.GetNs+1,   MRB.GetNs+2, MRB.GetNs+3]);
MRB.GetNs

MRB.elems{ndov}.ConeS = cat(2, MRB.elems{ndov}.ConeS, ...
                        [0,0,0,MRB.GetNs+1, MRB.GetNs+2, MRB.GetNs+3]);
% Asimetria                    
MRB.elems{1}.Geome(4,1)=-3.1

%MRB.elems{1}.Conex(1,:)=[0 0 0];
%MRB.elems{ndov}.Conex(2,:)=[0 0 0];
%MRB.reSetConex;

%[elem222, elem210, elem210] = datos_dolmen; 
%RB1 = ArcoTSAM_RB210NL(elem210{1});
%RB2 = ArcoTSAM_RB210NL(elem210{2});
%RB3 = ArcoTSAM_RB210NL(elem210{3});

%MRB = ArcoTSAM_ModeloNL();
%MRB.Adds(RB1);
%MRB.Adds(RB2);
%MRB.Adds(RB3);


lb = MRB.GetLb;
ub = MRB.GetUb;

subsection ('GetH')
H = MRB.GetH;

%% 1
iniFigureArcoTSAM (1);


subsection('LP')
alpha=pi;
gammau=1;
%gammau=0.25;
ielem=3;
ijunt=4; % ijunt > GetNjuntas => componentes de reacciones
foP=MRB.GethdirMinLPP(ielem, ijunt, alpha, gammau);
fprintf('foP=%f\n', foP);
%chk(eval(sprintf('%.4f',foP))==0.5655, 'LPP, min hd')
% iniFigureArcoTSAM('Name', 'TestRB210d: plotu');
% MRB.plot;
% esca=1;
% iSol=1;
% MRB.plotu(false,iSol,esca);
% x xx
[e, u] = MRB.GetLargeM2(ielem,ijunt,alpha, gammau)
% cat(u, MRB.GetVectU)
 x xx
for i=1:10
    MRB.plotuLM(MRB.GetNsol);
    MRB.plotf(.1);
    aux =  MRB.GetLargeM(ielem,ijunt,alpha, gammau);
    fprintf ('h = %12.6f\n',aux);
end



pauseOctaveFig
x xx
iniFigureArcoTSAM (5);

MRB.plotuLM(MRB.GetNsol);
MRB.plotujLM(MRB.GetNsol);
MRB.plotf(.1);

pauseOctaveFig
subsection('chkEQU sobre geometria INICIAL. F posicion inicial')
ndov=3;
nHip=MRB.GetNHipts;
for idov =1 : ndov
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU  geome0, f  geome0)\n', ... 
        MRB.elems{idov}.chkEQU(0))
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU geomeLM, f  geome0)\n', ...
         MRB.elems{idov}.chkEQU(1))
    chk(MRB.elems{idov}.isEQU(0),'chkEQU idov (EQU  geome0, f  geome0)');
     subsection('.',0,-3,'.'); 
end

MRB.plotRjULM(-.25, false, MRB.GetNsol, 0);


%% 2
iniFigureArcoTSAM (11);

subsection('min hd (segundo calculo)')
foP2=MRB.GethdirMinLPP(ielem, ijunt, alpha, gammau);
fprintf('foP=%f\n', foP2);
chk(eval(sprintf('%.4f',foP))==eval(sprintf('%.4f',foP2)), 'LPP2, min hd');

for i=1:10
    MRB.plotuLM(MRB.GetNsol);
    MRB.plotf(.1);
    aux =  MRB.GetLargeMf(ielem,ijunt,alpha, gammau);
    fprintf ('h = %12.6f\n',aux);
end
%chk(abs(eval(sprintf('%.4f',aux))+3.809666)<0.001, 'MRB.GetLargeMf');


pauseOctaveFig
iniFigureArcoTSAM (15);

MRB.plotuLM(MRB.GetNsol);
MRB.plotf(.1);

pauseOctaveFig

subsection ('chkEQU sobre geometria INICIAL. F posicion FINAL')
ndov=3;
nHip=MRB.GetNHipts;
for idov =1 : ndov
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU  geome0, f  geome0)\n', ...
        MRB.elems{idov}.chkEQU(0))
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU geomeLM, f  geome0)\n', ...
        MRB.elems{idov}.chkEQU(1))
    chk(MRB.elems{idov}.isEQU(0),'chkEQU idov (EQU  geomeNL, f  geome0)');

    subsection('.',0,-3,'.');
end

disp '-----HLM*u,    VectE,   VectEm,  VectELM,   VectEr'; 
cat(2,MRB.H'*MRB.GetVectUAmp,MRB.GetVectE, MRB.GetVectEULM(false), MRB.GetVectEULM(true), MRB.GetVectEr)
disp '^^^^^HLM*u,    VectE,   VectEm,  VectELM,   VectEr'; 
MRB.plotRjULM(-.25, false, MRB.GetNsol, 0);

%% 3
iniFigureArcoTSAM (21);

subsection ('min hd (tercer calculo)')
foP2=MRB.GethdirMinLPP(ielem, ijunt, alpha, gammau)
chk(eval(sprintf('%.4f',foP))==eval(sprintf('%.4f',foP2)), 'LPP2, min hd');

MRB.GetLargeMf(ielem,ijunt,alpha, gammau);
for i=1:39 
    fprintf ('hLM = %12.6f\n',aux);
    MRB.plotuLM(MRB.GetNsol);
    MRB.plotf(.1);
    if (mod(i,1)==0)
        fprintf('Se actualiza H\n')
        fprintf('SUM(SUM(H))=%f; sum(Er)=%f; \n', sum(sum(full(MRB.H))) ,sum(MRB.GetVectEr))
        HULM=MRB.GetHULM;
        fprintf('SUM(SUM(H))=%f; sum(Er)=%f\n', sum(sum(full(MRB.H))) ,sum(MRB.GetVectEr))
    end
    %aux =  MRB.GetLargeMfer(ielem,ijunt,alpha, gammau);
    aux =  MRB.GetLargeMf(ielem,ijunt,alpha, gammau);
end


pauseOctaveFig

iniFigureArcoTSAM (25);
%MRB.GetLargeM(2,1,alpha, gammau)
MRB.plotuLM(MRB.GetNsol);
MRB.plotujLM(MRB.GetNsol);
MRB.plotf(.1);

pauseOctaveFig

subsection ('chkEQU sobre geometria DEFORMADA')
ndov=3;
nHip=MRB.GetNHipts;
for idov =1 : ndov
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU  geome0, f  geome0)\n', ...
        MRB.elems{idov}.chkEQU(0))
    MRB.elems{idov}.epsEQU=0.001;
    fprintf('\t\t%12.8f %12.8f %12.8f (EQU geomeLM, f  geome0)\n', ...
        MRB.elems{idov}.chkEQU(1))
    chk(MRB.elems{idov}.isEQU(1), 'chkEQU idov (EQU  geomeNL, f  geome0)');
    subsection('.',0,-3,'.'); 
end

disp '-----HLM*u,    VectE,   VectEm,  VectELM, VectEm_1, VectELM_1'; 
cat(2,MRB.H'*MRB.GetVectUAmp,MRB.GetVectE, MRB.GetVectEULM(false), MRB.GetVectEULM(true));%, MRB.GetVectEm_1, MRB.GetVectELM_1, MRB.GetVectEr_1)
disp '^^^^^HLM*u,    VectE,   VectEm,  VectELM, VectEm_1, VectELM_1';
%disp 'Las siguientes deberían tener los ceros en el mismo lugar'
%cat(2, MRB.GetVectEULM(true), MRB.GetVectELM_1);

iniFigureArcoTSAM(2);

MRB.plotuLM(MRB.GetNsol);
MRB.plotRjULM(-.25, 1, MRB.GetNsol, true);
MRB.plotf(.25, MRB.GetNHipts);
MRB.plotujLM;

pauseOctaveFig
