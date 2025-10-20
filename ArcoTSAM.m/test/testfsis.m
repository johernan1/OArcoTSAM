clear all;

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
wobinichTamino
iniMatlabOctave

f1=[2,1,0];
P1=[0,0];
P2=[2,4];
P3=[-2,-5];
F1=ArcoTSAM_f;
F2=ArcoTSAM_f;
F1.Comp=f1;
F1.Punt=P1;
F2.Punt=P2;
F2.Comp=F1.GetComp(P2);

sisF1=ArcoTSAM_fsis;
chk('GetComp: sistema "vacio"', sisF1.GetComp==[0 0 0])
sisF1.addf(F1)
sisF1.addf(F2)
chk('GetNf: Sistema con 2 fuerzas', sisF1.GetNf==2);
chk('GetCom', sisF1.GetComp==2*F1.GetComp)

 
sisF2=ArcoTSAM_fsis;
sisF2.addf(F2);
sisF2.addf(F1);
chk('GetNf: Otro sistema con 2 fuerzas', sisF2.GetNf==2);

  
 
sisF3=sisF1+sisF2;
chk('plus: sistema con 4 fuerzas', sisF3.GetNf==4);


sisF4=2*sisF1;
chk('plus, mtimes', sisF4.GetComp==sisF3.GetComp);

sisF5=sisF2-sisF1;
chk('minus', sisF5.GetComp==[0 0 0]);

chk('eq', sisF4==sisF3);

sisF6=ArcoTSAM_fsis+sisF5;
sisF6.delf;
sisF6;
chk('delf', sisF6.GetNf+1==sisF5.GetNf);
sisF7=sisF6-sisF5;
%sisF2
sisF2.delf;
%sisF2
chk('eq:delf:minus', sisF7==sisF2);

subsection ('Dibujo')
f = iniFigureArcoTSAM('Name','testfsis.m');

F2.plot(0,0,0,0);


pauseOctaveFig

%% Operator =; method copy
subsection ('Operator = (equivalente a copiar puntero en c)')
sisF3c=sisF3;
chk(         'sisF3==sisF3c', sisF3==sisF3c)
sisF3.delf;
chk(         'sisF3c==sisF3', sisF3==sisF3c)
subsection ('Method copy')
sisF3c=sisF3.copy;
chk(         'sisF3==sisF3c', sisF3==sisF3c)
sisF3.delf;
chk(         'sisF3c~=sisF3', sisF3~=sisF3c)


