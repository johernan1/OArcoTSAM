clear all;

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
wobinichTamino
iniMatlabOctave

RB=ArcoTSAM_RB;
        % x  z
RB.Geome=[0	 0;
          2	 0;
          2	-4;
          0	-2];
        % i j
RB.Junta=[1 2;
          3 4];
RB.nGdlxJ=3;
        % g1 g2 g3
RB.Conex=[ 0  0  0;
           1  2  3;
          10 11 12];
subsection('GetNJuntas')
chk('GetNjuntas', RB.GetNJuntas==2);
subsection('GetMaxConex')
chk('GetMaxConex', RB.GetMaxConex==12);
subsection('MoveConex')
RB1=RB.MoveConex(10);
chk('GetMaxConex', RB.GetMaxConex==22);
subsection('GetArea');
chk('GetArea', RB.GetArea==6);
subsection('GetCdg');
chk('GetCdg', RB.GetCdg==[(4*1+2*4/3)/6,(4*(-1)+2*(-2-2/3))/6]);
subsection('Addf')
Hip2=2;
Hip1=1;
F1=ArcoTSAM_f;
F1.Comp=[0.5, 1, 0];
F1.Punt=[0, 0];
F2=ArcoTSAM_f;
F2.Comp=[-0.5,1,0];
F2.Punt=[1,0];
F3=F1+F2;
RB.addf(F2,Hip2);
RB.addf(F1,Hip2);
chk('Addf Hip2', RB.Hipts{Hip2}.GetComp==F3.GetComp);
chk('Hip1 no definida', RB.Hipts{Hip1}.GetComp==[0 0 0]);
RB.addf(F1,Hip1);
chk('Addf Hip1', RB.Hipts{Hip1}.GetComp==F1.GetComp);
subsection ('delf');
RB.delf(Hip2)
chk('delf Hip2', RB.Hipts{Hip2}.GetComp==F2.GetComp);
RB.delf(Hip2)
chk('Se han borrado todos los sisf de Hip1', RB.Hipts{Hip2}.GetComp==[0 0 0]);
RB.addf(F2,Hip2);
RB.addf(F1,Hip2);
subsection ('addu');
u=zeros(22,1);
u(end-2:end)=[1,1,0];
RB.addu(u);
u(end-2:end)=[0,0,.5];
RB.addu(u);
subsection('warning');
RB.addu(u,4);
subsection('end warning');
subsection('plot');

iniFigureArcoTSAM ('Name','testRB0 (plot, plotj, plotf, plotR)');

RB.plot;
RB.plotj;
RB.plotf(2,1);
RB.plotfR(2,1);

iniFigureArcoTSAM ('Name','testRB0 (plotu)');

RB.plotu(false,1,0.5);
RB.plotu(false,2,0.5);
RB.plot;

pauseOctaveFig

%% Operator =; method copy
if(amImatlab)
    subsection ('Operator = (equivalente a copiar puntero en c)')
    RBc=RB;
    chk(         'RBc==RB', RB==RBc)
    RBc.rho=5;
    chk(         'RBc==RB', RB==RBc)
    subsection ('Method copy')
    RBc=RB.copy;
    chk(         'RBc~=RB', RB~=RBc)
    RBc.rho=RBc.rho+3;
    chk(         'RBc.rho=RB.rho+3', RBc.rho==RB.rho+3)
end

