%% Rose Windows. J Heyman. Fig 14
% Empuje máximo y mínimo Notre Dame Mantes.
%

%
% TODO:
% Perturbación en w
% Mecanismos varios, para distintas relaciones de los udir de cada spoke
% Los triangulitos próximos al 'óculo' puede que estabilicen el MEC. Es
% probable que no estén puestos para adornar

clear all;


addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro');

wobinichTamino;
iniMatlabOctave();

%% GEOMETRIA Y TOPOLOGIA
%
neleSp= 3;    % numero elementos de cada spoke
nelePe=  3;    % numero elementos de cada petalo
nSpoke= 12;    % numero de spokes
radioT=  3;    % Radio total de los pétalos
radioE=  4;
neleRi=  3;    % numero de elementos de cada inner ring
radioI= 0.85;    % radio del inner ring

t=radioE/16;   % spoke proportion d/t=10

topoHF14

%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del
% origen de coordenadas
subsection ('H')
H = MRB.GetH;
%chk('H', full(sum(sum(H))), 287.894171);

%% CALCULO DEL VECTOR DE ACCIONES VARIABLES vectQ (distribución H)
% La comprobacion solo es valida para una geometria
subsection ('SetQ & GetQ')
ihip=3;
arista=4;
w=2; %kN/m^2
AreaE=pi*radioE^2;
AreaT=pi*radioT^2;
AreaS=pi*radioS^2;
AreaI=pi*radioI^2;

qpmliRing=w*(AreaI)/nSpoke/longRi;
qpmlH=w*(AreaE-AreaI)/nSpoke/(radioE-radioI)

%qpmlSpoke=qpmlH*cos(angulS/2);
%qpmlPetal=qpmlH*cos(angulP)/2;
qpmlSpoke=w*(AreaE-AreaI)/nSpoke/(radioE-radioI);
qpmlPetal=qpmlSpoke/2*(radioT-radioS)/longPe;
for jspoke=1:nSpoke
    for ieleRi=1:neleRi
        MRBiring{jspoke}.SetQApml(ihip, ieleRi,arista, [0 qpmliRing 0]);
    end
    for ieleSp=1:neleSp
        MRBspoke{jspoke}.SetQApml(ihip, ieleSp,arista, [0 qpmlSpoke 0]);
    end
    for ielePe=1:neleSp
        MRBpeta1{jspoke}.SetQApml(ihip, ielePe,arista, [0 qpmlPetal 0]);
        MRBpeta2{jspoke}.SetQApml(ihip, ielePe,arista, [0 qpmlPetal 0]);
    end
    for ielePe=1:neleSp
        MRBspokeE{jspoke}.SetQApml(ihip, ielePe,arista, [0 qpmlSpoke 0]);
    end
end


vectQ=MRB.Getf(ihip);
auxi=MRB.GetConexf;
auxf=vectQ;
auxf=auxf(auxi~=0);
sumaQ=sum((reshape(auxf, 3, size(auxf,1)/3))');

chk(sprintf('Hipotesis Q, SumaQ_z=%f, w*AreaT=%f',sumaQ(2), w*AreaE), ...
    sumaQ(2), w*AreaE,.001)

f=iniFigureArcoTSAM(201);
if amImatlab f.Name='vectQ'; end;
escf=1.25;
MRB.plot;
MRB.plotf(escf, ihip);

%% 1. CALCULO DEL EMPUJE MINIMO
% La comprobacion solo es valida para una geometria

subsection('Empuje minimo');
ielem=neleSp;
apoyoAsiento=MRB.elems{5}.elems{ielem};
%apoyoAsiento1=MRB.elems{8}.elems{ielem};
ijunt=2;
alpha=pi*1;
gammau=1;

% coneSApoyo=MRB.elems{3}.elems{ielem}.GetConeSjunta(ijunt);
% sdir = MRB.elems{3}.elems{ielem}.GetSdir(ijunt, alpha);
% c = zeros(MRB.GetNs,1);
% c=MRB.GetCFoHdir(apoyoAsiento , ijunt, alpha)  + ...
%   MRB.GetCFoHdir(apoyoAsiento1, ijunt, alpha);          
c=MRB.GetCFoHdir(apoyoAsiento , ijunt, alpha);

minhdirP=MRB.GethdirMinLPP(apoyoAsiento, ijunt, alpha, gammau,vectQ,c);
%fprintf('h = %12.6f\n', minhdirP);
%chk('LPP, min hd', minhdir, -3.806448)

minhdirD=MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau,vectQ,c);

%% CHEQUEO DEL EMPUJE MINIMO PARA vectQ
chk(sprintf('LPP==LPD, min hd=%f',minhdirP), minhdirP, minhdirD)
chk('LPP==LPD. VectS', MRB.GetVectS(1),MRB.GetVectS(2),0.0001);

qpmlH=w*AreaE/nSpoke/(radioE);
fprintf('%21s|%10s|%17s|%10s|%12s\n',...
    'qpmlH', 'qpmlSpoke', 'hdirH', 'hdirLP', 'hdirH/hdirLP');
fprintf('%21s|%10s|%17s|%10s|%12s\n',...
    'w*AreaE/nSpoke/radioT', '', 'qpmlH*(2*r)^2/8/t', '', '');
fprintf('%21f|%10f|%17f|%10f|%12f\n', ...
    qpmlH, qpmlSpoke, qpmlH*(2*radioE)^2/8/t,  minhdirP, qpmlH*(2*radioE)^2/8/t/(minhdirP*cos(pi/6)));

%% CALCULO Y CHEQUEO DEL VECTOR DE ACCIONES VARIABLES vectQ
% La comprobacion solo es valida para una geometria
subsection ('SetQ & GetQ')
ihip=5;
arista=4;
w=2; %kN/m^2
AreaT=pi*radioT^2;
AreaI=pi*radioI^2;
qpmlSpoke=w*(AreaT-AreaI)/nSpoke/longSp;
qpmliRing=w*(AreaI)/nSpoke/longRi;
for jspoke=1:nSpoke
    %    qpml=4.2/longSp;
    %     if jspoke==2
    %         qpml=0*qpml
    %     end
    iRadioI=radioI;
    iRadioE=iRadioI+longSp/neleSp;
    iArea=pi*(iRadioE^2-iRadioI^2);
    qpmlSpoke=w*(iArea)/nSpoke/(longSp/neleSp);
    for ieleRi=1:neleRi
        MRBiring{jspoke}.SetQApml(ihip, ieleRi,arista, [0 qpmliRing 0]);
    end
    for ieleSp=1:neleSp
        %MRBiring{jspoke}.SetQApml(ihip, ieleSp,arista, [0 qpmliRing 0]);
        MRBspoke{jspoke}.SetQApml(ihip, ieleSp,arista, [0 qpmlSpoke 0]);
        iRadioI=iRadioE;
        iRadioE=iRadioI+longSp/neleSp;
        iArea=pi*(iRadioE^2-iRadioI^2);
        qpmlSpoke=w*(iArea)/nSpoke/(longSp/neleSp);
    end
    %fprintf('------------------\n');
    iRadioI=radioS;
    iRadioE=iRadioI+(radioT-radioS)/nelePe;
    iArea=pi*(iRadioE^2-iRadioI^2);
    qpmlPetal=w*(iArea)/nSpoke/(longPe/nelePe);
    for ielePe=1:nelePe
        %MRBiring{jspoke}.SetQApml(ihip, ieleSp,arista, [0 qpmliRing 0]);
        MRBpeta1{jspoke}.SetQApml(ihip, ielePe,arista, [0 qpmlPetal/2 0]);
        MRBpeta2{jspoke}.SetQApml(ihip, ielePe,arista, [0 qpmlPetal/2 0]);
        iRadioI=iRadioE;
        iRadioE=iRadioI+(radioT-radioS)/nelePe;
        iArea=pi*(iRadioE^2-iRadioI^2);
        qpmlPetal=w*(iArea)/nSpoke/(longPe/nelePe);
    end
    iRadioI=radioT;
    iRadioE=iRadioI+(radioE-radioT)/neleSp;
    iArea=pi*(iRadioE^2-iRadioI^2);
    qpmlSpoke=w*(iArea)/nSpoke/((radioE-radioT)/neleSp);
    for ieleSp=1:neleSp
        %MRBiring{jspoke}.SetQApml(ihip, ieleSp,arista, [0 qpmliRing 0]);
        MRBspokeE{jspoke}.SetQApml(ihip, ieleSp,arista, [0 qpmlSpoke 0]);
        iRadioI=iRadioE;
        iRadioE=iRadioI+(radioE-radioT)/neleSp;
        iArea=pi*(iRadioE^2-iRadioI^2);
        qpmlSpoke=w*(iArea)/nSpoke/((radioE-radioT)/neleSp);
    end
end



vectQ=MRB.Getf(ihip);
auxi=MRB.GetConexf;
auxf=vectQ;
auxf=auxf(auxi~=0);
sumaQ=sum((reshape(auxf, 3, size(auxf,1)/3))');

f=iniFigureArcoTSAM(202);
if amImatlab  f.Name='vectQ'; end;
escf=1.25;
MRB.plot;


MRB.plotf(escf, ihip);

chk(sprintf('Hipotesis Q, SumaQ_z=%f, w*AreaT=%f',sumaQ(2), w*AreaE), ...
    sumaQ(2), w*AreaE)
;
% vectQ=MRB.Getf(ihip);
% %chk('Hipotesis Q, gamma=1', sum(vectQ), w*AreaT)
%
% f=iniFigureArcoTSAM(201);
% f.Name='vectQ';
% escf=1.25;
% MRB.plot;
% MRB.plotf(escf, ihip);

%% 1. CALCULO DEL EMPUJE MINIMO
% La comprobacion solo es valida para una geometria

subsection('Empuje minimo');
% ielem=nelePe;
% apoyoAsiento=MRB.elems{3}.elems{ielem};
% ijunt=2;
% alpha=pi*1;
% gammau=1;

% coneSApoyo=MRB.elems{3}.elems{ielem}.GetConeSjunta(ijunt);
% sdir = MRB.elems{3}.elems{ielem}.GetSdir(ijunt, alpha);
% c = zeros(MRB.GetNs,1);
% c(coneSApoyo) = sdir;
% c=MRB.GetCFoHdir(apoyoAsiento , ijunt, alpha)  + ...
%   MRB.GetCFoHdir(apoyoAsiento1, ijunt, alpha);        
c=MRB.GetCFoHdir(apoyoAsiento , ijunt, alpha);

minhdirP=MRB.GethdirMinLPP(apoyoAsiento, ijunt, alpha, gammau,vectQ,c);
%fprintf('h = %12.6f\n', minhdirP);
%chk('LPP, min hd', minhdir, -3.806448)

minhdirD=MRB.GethdirMinLPD(apoyoAsiento, ijunt, alpha, gammau,vectQ,c);




%% CHEQUEO DEL EMPUJE MINIMO PARA vectQ
chk(sprintf('LPP==LPD, min hd=%f',minhdirP), minhdirP, minhdirD)
chk('LPP==LPD. VectS', MRB.GetVectS(3),MRB.GetVectS(4),0.05);

fprintf('%21s|%10s|%18s|%10s|%12s\n',...
    'qpmlH', 'qpmlSpoke', 'hdirH', 'hdirLP', 'hdirH/hdirLP');
fprintf('%21s|%10s|%18s|%10s|%12s\n',...
    'w*AreaE/nSpoke/radioE', '(max)', 'qpmlH*(2*r)^2/8/t', '', '');
fprintf('%21f|%10f|%18f|%10f|%12f\n', ...
    qpmlH, qpmlSpoke, qpmlH*(2*radioE)^2/8/t,  minhdirP*cos(pi/6), qpmlH*(2*radioE)^2/8/t/(minhdirP*cos(pi/6)));
fprintf('\n');
fprintf('%21s|%10s|%18s|%10s|%12s\n',...
    'qpmlH', 'qpmlSpoke', 'hdirH(corr)', 'hdirLP', 'hdirH/hdirLP');
fprintf('%21s|%10s|%18s|%10s|%12s\n',...
    'w*AreaE/nSpoke/radioE', '(max)', 'qpmlH*(2*r)^2/12/t', '', '');
fprintf('%21f|%10f|%18f|%10f|%12f\n', ...
    qpmlH, qpmlSpoke, qpmlH*(2*radioE)^2/12/t,  minhdirP*cos(pi/6), qpmlH*(2*radioE)^2/12/t/(minhdirP*cos(pi/6)));
%% DIBUJO Resultados
%
subsection ('dibujo resultados')

f=iniFigureArcoTSAM (301);
if amImatlab f.Name='MEC'; end


h= MRB.plot;
set(h,'facealpha',.0)
%set(h,'facecolor','r')
esca=t;
iSol=1;
MRB.plotu( false,iSol,esca);
%MRB.plotn;
MRB.plotuj(false,iSol,esca);

f=iniFigureArcoTSAM (302);
if amImatlab f.Name='LP'; end;

escf=-.0125;
escu=0;
MRB.plot;
%MRB.plotn;
MRB.plotRjULM(escf, false, iSol, escu);

pauseOctaveFig

%% Chequeos
%
Srv=0;
for jspoke=1:nSpoke
    Srv=Srv+MRBspokeE{jspoke}.elems{neleSp}.VectS{3}(6);
end
Sq=w*AreaE;

chk(sprintf('Suma reacciones verticales (%f) == suma cargas (%f)', ...
    Srv, Sq), Srv, Sq);

fprintf('%7s|%7s|%6s|%6s|%6s|%6s|%6s|%6s|%6s|%6s|%6s|%6s|%6s\n','iSol','iSpoke', 'fz_ir', 'fx_ir','e','e', 'fz_sp', 'fx_sp','e','e', 'fz_pe', 'fx_pe', 'H');
% for iSol=1:4
%     for iSpoke=1:nSpoke
%         %fprintf('(Sol %d) Reacción horizontal en spoke 1: (%f)\n', iSol, MRBspoke{iSpoke}.elems{neleSp}.VectS{iSol}(4));
%         %fprintf('(Sol %d) Reacción vertical en spoke 1: (%f)\n', iSol,  MRBspoke{iSpoke}.elems{neleSp}.VectS{iSol}(6));
%         fprintf('%7d|%7d|%10f|%10f|%10f|%10f|%10f|%10f\n',iSol,iSpoke, ...
%             MRBiring{iSpoke}.elems{neleRi}.VectS{iSol}(4)+ ...
%             MRBiring{iSpoke}.elems{neleRi}.VectS{iSol}(5), ...
%             MRBiring{iSpoke}.elems{neleRi}.VectS{iSol}(6), ...
%             MRBspoke{iSpoke}.elems{neleSp}.VectS{iSol}(4)+ ...
%             MRBspoke{iSpoke}.elems{neleSp}.VectS{iSol}(5), ...
%             MRBspoke{iSpoke}.elems{neleSp}.VectS{iSol}(6), ...
%             MRBpeta1{iSpoke}.elems{nelePe}.VectS{iSol}(4)+ ...
%             MRBpeta1{iSpoke}.elems{nelePe}.VectS{iSol}(5), ...
%             MRBpeta1{iSpoke}.elems{nelePe}.VectS{iSol}(6))
%     end
% end
for iSol=1:4
    for iSpoke=1:nSpoke
        fprintf('%7d|%7d|%6.2f|%6.2f|%6.2f|%6.2f|%6.2f|%6.2f|%6.2f|%6.2f|%6.2f|%6.2f|%6.2f\n',iSol,iSpoke, ...
            MRBiring{iSpoke}.elems{neleRi}.VectS{iSol}(6),  ...
            MRBiring{iSpoke}.elems{neleRi}.VectS{iSol}(4)+  ...
            MRBiring{iSpoke}.elems{neleRi}.VectS{iSol}(5),  ...
            MRBiring{iSpoke}.elems{neleRi}.VectS{iSol}(4)/( ...
            MRBiring{iSpoke}.elems{neleRi}.VectS{iSol}(4)+  ...
            MRBiring{iSpoke}.elems{neleRi}.VectS{iSol}(5)), ...
            ...
            MRBspoke{iSpoke}.elems{     1}.VectS{iSol}(2)/(  ...
            MRBspoke{iSpoke}.elems{     1}.VectS{iSol}(1)+  ...
            MRBspoke{iSpoke}.elems{     1}.VectS{iSol}(2)),  ...
            MRBspoke{iSpoke}.elems{neleSp}.VectS{iSol}(6),  ...
            MRBspoke{iSpoke}.elems{neleSp}.VectS{iSol}(4)+  ...
            MRBspoke{iSpoke}.elems{neleSp}.VectS{iSol}(5),  ...
            MRBspoke{iSpoke}.elems{neleSp}.VectS{iSol}(4)/(  ...
            MRBspoke{iSpoke}.elems{neleSp}.VectS{iSol}(4)+  ...
            MRBspoke{iSpoke}.elems{neleSp}.VectS{iSol}(5)),  ...
            ...
            MRBpeta1{iSpoke}.elems{     1}.VectS{iSol}(2)/( ... 
            MRBpeta1{iSpoke}.elems{     1}.VectS{iSol}(1)+  ...
            MRBpeta1{iSpoke}.elems{     1}.VectS{iSol}(2)),  ...
            MRBpeta1{iSpoke}.elems{nelePe}.VectS{iSol}(6),  ...
            MRBpeta1{iSpoke}.elems{nelePe}.VectS{iSol}(4)+  ...
            MRBpeta1{iSpoke}.elems{nelePe}.VectS{iSol}(5), ...
            ...
            (MRBpeta1{iSpoke}.elems{nelePe}.VectS{iSol}(4)+  ...
            MRBpeta1{iSpoke}.elems{nelePe}.VectS{iSol}(5))*cos(angulP)*2)
    end
end

    
