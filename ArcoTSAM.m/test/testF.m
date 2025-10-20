clear all;

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
wobinichTamino
iniMatlabOctave

f010=ArcoTSAM_f;
f010.Comp=[0, 1, 0];
f010.Punt=[0, 0];

subsection('Cambio S.R.')
chk('ArcoTSAM_f.GetComp', f010.GetComp([ 0,0])==[0  1  0]);
chk('ArcoTSAM_f.GetComp', f010.GetComp([10,0])==[0  1 10]);
chk('ArcoTSAM_f.GetComp', f010.GetComp([0,10])==[0  1  0]);

subsection('Cambio S.R.')
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
chk('ArcoTSAM_f.GetComp', F1.GetComp(P3)==F2.GetComp(P3))

subsection ('plus, mtimes, minus')
F3=2*F1+3*F2;
F4=5*F1;
F6=F3-F4;
chk('2*F1+3*F2==5*F1', F3.GetComp(P2)==F4.GetComp(P2))
chk( '2*F1+3*F2-5*F1', F6.GetComp(P2)==[0 0 0])
chk(         'F3==F4', F3==F4)



subsection ('Dibujo')

f = iniFigureArcoTSAM('Name','testF.m');

F1.plot(1);
f010.plot(.25);
F2.plot;

pauseOctaveFig

%% Operator =; method copy (innecesario)
subsection ('Operator =: method copy (innecesario)')
F1c=F1;
chk(         'F1==F1c', F1==F1c)
F1.Punt=[1,1];
chk(         'F1c~=F1', F1==F1c,0)
