clear all;

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('Datos/');
wobinichTamino;
iniMatlabOctave();

[elem222, elem210] = datos_dolmen; 

RB1 = ArcoTSAM_RB222(elem222{1});
RB2 = ArcoTSAM_RB222(elem222{2});
RB3 = ArcoTSAM_RB222(elem222{3});

MRB = ArcoTSAM_Modelo();
MRB = MRB.Adds(RB1);
MRB = MRB.Adds(RB2);
MRB = MRB.Adds(RB3);



subsection ('SetConeS')
MRB.SetConeS;

lb = MRB.GetLb;
ub = MRB.GetUb;

subsection ('H')
H = MRB.GetH;
chk('H', sum(sum(H)),48);

subsection ('SetG & GetG')
MRB.SetG(2);
fG=MRB.Getf(1);
chk('Hipotesis no asignada', sum(fG), 0)
fG1=10*MRB.Getf(2);
chk('Hipotesis G, gamma=10', sum(fG1), 28000)
MRB.SetG(1);
fG2=MRB.Getf(2);
fG3=MRB.Getf(1);
chk('Hipotesis G, gamma=1', sum(fG3), 2800)
chk('Suma de hipotesis', sum(fG2+fG1), 28000+2800)

subsection ('SetQ & GetQ')
MRB.SetQ(3, 3, [1 0 0])
vectQ=MRB.Getf(3);
chk('Hipotesis Q, gamma=1', sum(vectQ), -4.0)


subsection ('LP')
% %% como función objetivo se define -gammaf pues linprog minimiza
% 
% if(amImatlab)
% alg='interior-point-legacy';
% options = optimoptions('linprog','Algorithm',alg, ...
% 		       'Display', 'iter', 'MaxIterations', 1000);
% options = optimoptions('linprog','Algorithm','dual-simplex');
% [ss, fo, status, extra, lambda ] = linprog( ...
%             [zeros(MRB.GetNs,1);-1], ...
%             [],[], ...
%             cat(2,H,fq1), -fG3, ...
%             [ lb;-Inf], ...
%             [ ub; Inf], options);
% else    
% param.lpsolver=2
% [ss, fo, status, extra ] = glpk( ...
% 			[zeros(MRB.GetNs,1); -1], ...
%             cat(2,H, fq1), -MRB.Getf(1), ...
%             [lb; -Inf], ...
%             [ub; Inf], ...
%             [],[],1,param); 
% 
% end        
% 
% fprintf ('---------- factor de carga ----------------------------------\n')
% fo=-fo
% chk(eval(sprintf('%.5f',fo))==10, 'LP')
% 
% fprintf ('---------- vectores s, u y e --------------------------------\n')
% s=ss(1:end-1);
% s=reshape(s,RB1.nGdlxJ, size(s,1)/RB1.nGdlxJ)
% if(amImatlab)
%     e=lambda.lower+lambda.upper;
%     e=e(1:end-1);
%     e=reshape(e,RB1.nGdlxJ, size(e,1)/RB1.nGdlxJ)
%     u=lambda.eqlin;
%     %u=reshape(u,RB1.nGdlxJ, size(u,1)/RB1.nGdlxJ)
% else
%     %extra
%     e=extra.redcosts;
%     e=e(1:end-1);
%     e=reshape(e,RB1.nGdlxJ, size(e,1)/RB1.nGdlxJ)
%     u=-extra.lambda;
%     %u=reshape(u,RB1.nGdlxJ, size(u,1)/RB1.nGdlxJ)
% end
% 
% MRB.SetVectU(u);
% MRB.SetVectU(0.5*u,2);
% MRB.SetVectS(ss);
% MRB.SetVectS(0.5*ss,2);
fo = MRB.GetMaxGammaLPD(vectQ);

subsection ('dibujos')

iniFigureArcoTSAM ('Name', 'testRB222: RBs');

RB1.plot;
RB2.plot;
RB3.plot;

iniFigureArcoTSAM ('Name', 'testRB222: plot, plotf, plotj');

escf=.01;
ihip=2;
MRB.plot;
MRB.plotf(escf, ihip);
MRB.plotj;

iniFigureArcoTSAM ('Name', 'testRB222: plotu');

isol=1;
esca=1;
MRB.plot;
MRB.plotu(esca,isol);
MRB.plotu(2*esca);


if(~amImatlab)
    w = waitforbuttonpress;
end