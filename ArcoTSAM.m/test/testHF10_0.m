%% Rose Windows. J Heyman. Fig 7
% Empuje máximo y mínimo en wheel window.
% 
clear all;

%% GEOMETRIA Y TOPOLOGIA
%

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro');

wobinichTamino;
iniMatlabOctave();
iniFigureArcoTSAM (1);

neleS= 3; % numero elementos de cada spoke 
nSpok= 3; % numero de spokes
Rt=  2;    % Radio total de rose window
nri= 3;    % numero de elementos de cada inner ring 
ri=  .5;   % radio del inner ring
lS=Rt-ri;  % longitud del spoke
lri = 2*ri*sin(2*pi/nSpok/2);     % longitud de cada tramo del inner ring
t=Rt/10;   % spoke proportion d/t=10
lSp=lS+10^-00;
MRBiring = {}
MRBspoke = {};
MRB = ArcoTSAM_Modelo();
ncx=1;

for i =1:nSpok
    MRBiring{i}=mpl2RB210(geomPuntal(0,i,lri,i,t,nri),...
        topoRebajado(nri))
         if (i>1)
    ncx=1;         
    while ncx < MRB.GetMaxConex;    ncx = ncx+100; end;
    MRBiring{i}.MoveConex(ncx);
         end
    MRBiring{i}.ucsA=2*pi/nSpok*(i-1)+pi/2+2*pi/nSpok/2;
    MRBiring{i}.ucsX=ri*cos(2*pi/nSpok*(i-1));
    MRBiring{i}.ucsY=ri*sin(2*pi/nSpok*(i-1));
    MRBiring{i}.ucsZ=-i;
    MRB.Adds(MRBiring{i});
    %claves
    if i>1
        MRBrstRing{i-1}= ArcoTSAM_Rst();
        MRBrstRing{i-1}.Adds(  MRBiring{i}.elems{1});
        MRBiring{i}.elems{1}.name=sprintf('%senlaceiRing %d ',MRBiring{i}.elems{1}.name, i-1); 
        MRBrstRing{i-1}.Adds(MRBiring{i-1}.elems{nri});
        MRBiring{i-1}.elems{nri}.name=sprintf('%senlaceiRing %d ',MRBiring{i-1}.elems{nri}.name, i-1); 

        MRBrstRing{i-1}.RstAng=[[2,MRBiring{i}.ucsA];[3,MRBiring{i-1}.ucsA]];
        ncx=ncx+33;
        %ncx=1;
        while ncx < MRB.GetMaxConex;    ncx = ncx+100; end;
        ncs=1;
        while ncs < MRB.GetMaxConex;    ncs = ncs+100; end;
        MRBrstRing{i-1}.SetConeS(ncs);
        MRBrstRing{i-1}.Conex=ncx:ncx+4;
        % Las restricciones tienen que añadirse al final, pues de otro modo
        % SetConeS no funciona correctamente
        % MRB.Adds(MRBrstRing{i-1});
    end;
    if i==nSpok
        MRBrstRing{i}= ArcoTSAM_Rst();
        MRBrstRing{i}.Adds(  MRBiring{1}.elems{1});
        MRBiring{1}.elems{1}.name=sprintf('%senlaceiRing %d ',MRBiring{1}.elems{1}.name, i); 
        MRBrstRing{i}.Adds(MRBiring{i}.elems{nri});
        MRBiring{i}.elems{nri}.name=sprintf('%senlaceiRing %d ',MRBiring{i}.elems{nri}.name, i); 

        MRBrstRing{i}.RstAng=[[2,MRBiring{1}.ucsA];[3,MRBiring{i}.ucsA]];
        ncx=ncx+33;
        %ncx=1;
        while ncx < MRB.GetMaxConex;    ncx = ncx+100; end;
        ncs=1;
        while ncs < MRB.GetMaxConex;    ncs = ncs+100; end;
        MRBrstRing{i}.SetConeS(ncs);
        MRBrstRing{i}.Conex=ncx:ncx+4;
        % Las restricciones tienen que añadirse al final, pues de otro modo
        % SetConeS no funciona correctamente
        %MRB.Adds(MRBrstRing{i});
    end
end
%MRB.plot;
%MRB.plotj;   % juntas
%xxx=xxx
%ncx=10000;
for iSpoke =1:nSpok
%     %Con cat 1 se añade un elemento adicional, la clave, sin dimensiones
%     MRBspoke{i}=mpl2RB210(cat(1,geomPuntal(ri,i,lS,i,t,neleS), ...
%         [lSp,i;lSp, i-t]), ...
%         topoRebajado(neleS+1));
     MRBspoke{iSpoke}=mpl2RB210(geomPuntal(ri,iSpoke,lS,iSpoke,t,neleS), ...
         topoRebajado(neleS));

    
    % MRBb=mpl2RB210(cat(1,geomPuntal(0,1,lS,1,t,neleS), ...
    %         [lSp,1;lSp, 1-t]), ...
    %       topoRebajado(neleS+1));
    %
    % MRBc=mpl2RB210(cat(1,geomPuntal(0,2,lS,2,t,neleS), ...
    %         [lSp,2;lSp, 2-t]), ...
    %       topoRebajado(neleS+1));
    
    %if (i>1)
    ncx=1;  
        while ncx < MRB.GetMaxConex;    ncx = ncx+100; end;
        MRBspoke{iSpoke}.MoveConex(ncx);
    %end
    
    MRBspoke{iSpoke}.ucsA=2*pi/nSpok*(iSpoke);
    %%% Perturbación para evitar mecanismo
    if iSpoke==1 MRBspoke{iSpoke}.ucsA=MRBspoke{iSpoke}.ucsA+0*pi/180; end;
    MRBspoke{iSpoke}.ucsZ=-iSpoke;
    MRB.Adds(MRBspoke{iSpoke});
    
    % No se pueden hacer dos enlaces a una misma junta
%     MRBrstSpoke{i}= ArcoTSAM_Rst();
%     MRBrstSpoke{i}.Adds(  MRBiring{i}.elems{1});
%     MRBiring{i}.elems{1}.name=sprintf('%senlaceSpoke %d ',MRBiring{i}.elems{1}.name, i-1); 
%     MRBrstSpoke{i}.Adds(MRBspoke{i}.elems{1});
%     MRBspoke{i}.elems{1}.name=sprintf('%senlaceSpoke %d ',MRBspoke{i}.elems{1}.name, i-1); 
%     
%     MRBrstSpoke{i}.RstAng=[[2,MRBiring{i}.ucsA];[2,MRBspoke{i}.ucsA]];
% if iSpoke>1
    MRBrstRing{iSpoke}.Adds(  MRBspoke{iSpoke}.elems{1});
    MRBspoke{iSpoke}.elems{1}.name=sprintf('%senlaceSpoke %d ',MRBspoke{iSpoke}.elems{1}.name, iSpoke);
    MRBrstRing{iSpoke}.RstAng=[MRBrstRing{iSpoke}.RstAng;[2,MRBspoke{iSpoke}.ucsA]];
% end
% if iSpoke==1
%     MRBrstRing{nSpok}.Adds(  MRBspoke{iSpoke}.elems{1});
%     MRBspoke{nSpok}.elems{1}.name=sprintf('%senlaceSpoke %d ',MRBspoke{iSpoke}.elems{1}.name, iSpoke);
%     MRBrstRing{nSpok}.RstAng=[MRBrstRing{nSpoke}.RstAng;[2,MRBspoke{iSpoke}.ucsA]];
% end
ncx=1
    while ncx < MRB.GetMaxConex;    ncx = ncx+100; end;
    ncs=1;
    while ncs < MRB.GetMaxConex;    ncs = ncs+100; end;
    MRBrstRing{iSpoke}.SetConeS(ncs);
    %MRBrstSpoke{i}.Conex=ncx:ncx+4;
    %MRB.Adds(MRBrstSpoke{i});
    %% Apoyos
    MRBspoke{iSpoke}.elems{neleS}.Conex(2,:)=[0 0 0];
end;

% Se añaden las restricciones/claves
for i =1:nSpok
    MRB.Adds(MRBrstRing{i});
end



%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 
subsection ('SetConeS')
%MRBa.SetConeS;
%MRBb.SetConeS;
MRB.SetConeS;

%% LAS CLAVES

% while ncx < MRB.GetMaxConex;    ncx = ncx+100; end;
% ncs=1;
% while ncs < MRB.GetMaxConex;    ncs = ncs+100; end;
% 
% % Clave 1
% MRBrst1=clave3(MRBa,MRBa.GetNelems,MRBb,MRBb.GetNelems,MRBc,MRBc.GetNelems);
% MRBrst1.SetConeS(ncs);
% MRBrst1.Conex=ncx:ncx+4;
% MRB.Adds(MRBrst1);
% 
% % % Clave 2
% % MRBrst2=clave2(MRBa,MRBa.GetNelems,MRBc,MRBb.GetNelems);
% % MRBrst2.SetConeS(100+ncs);
% % MRBrst2.Conex=100+ncx:100+ncx+4;
% % MRB.Adds(MRBrst2);

%%% chequeo
%       MRB.elems(9)=[];
%       MRB.elems(8)=[];
%       MRB.elems(6)=[];
%       MRB.elems(5)=[];
%       MRB.elems(3)=[];
%  MRB.SetConeS;

MRB.plot;    % Topología
MRB.plotj;   % juntas

MRB.plotname;
MRB.plotn;   % numero arco.dovela

%% Apoyos
% Se renumeran Conex, aunque no es necesario
%MRBa.elems{1}.Conex(1,:)=[0 0 0];
%MRBb.elems{1}.Conex(1,:)=[0 0 0];
%MRBc.elems{1}.Conex(1,:)=[0 0 0];
%MRBb.reSetConex;
%MRB.plotConex;

%MRB.elems{1}.elems{1}.Conex(1,:)=[0 0 0];
%MRB.elems{2}.elems{3}.Conex(2,:)=[0 0 0];
MRB.plota;   % Apoyos


%% CALCULO Y CHEQUEO DE LA MATRIZ H
% La comprobacion solo es valida para una geometria y una posicion del 
% origen de coordenadas
subsection ('H')
H = MRB.GetH;
%chk('H', full(sum(sum(H))), 5.76);

%% CALCULO DEL VECTOR DE ACCIONES PERMANENTES
% Se calcula G. 
% La comprobacione solo es validas para una geometria
subsection ('SetG & GetG')
%MRBb.SetG(1);
MRB.SetG(1);
vectG=MRB.Getf(1);
%chk('Hipotesis G', sum(vectG), 11.879817)
% 
%% CALCULO Y CHEQUEO DEL VECTOR DE ACCIONES VARIABLES vectQ 
% La comprobacion solo es valida para una geometria 
subsection ('SetQ & GetQ')
ihip=3;
qpml=4.2/lS;
for jspoke=1:nSpok
    for ie=1:neleS
    MRBspoke{jspoke}.SetQApml(ihip, ie,4, [0 qpml 0]);
    
    end
end
vectQ=MRB.Getf(ihip);
%chk('Hipotesis Q, gamma=1', sum(vectQ), 2.749503)
MRB.plotf(1, ihip);
%% 1. CALCULO DEL EMPUJE MINIMO
% La comprobacion solo es valida para una geometria

subsection('Empuje minimo');
ielem=neleS;
ijunt=2;
alpha=pi*1;
gammau=1;
%minhdir=MRB.GethdirMinLPP(ielem, ijunt, alpha, gammau);
%fprintf('h = %12.6f\n', minhdir);
%chk('LPP, min hd', minhdir, -3.806448)
            coneSApoyo=MRB.elems{nSpok*2}.elems{ielem}.GetConeSjunta(ijunt);
            sdir = MRB.elems{nSpok*2}.elems{ielem}.GetSdir(ijunt, alpha);                  
            
            c = zeros(MRB.GetNs,1);
            c(coneSApoyo) = sdir; 
           
minhdirD=MRB.GethdirMinLPD(ielem, ijunt, alpha, gammau,vectQ,c);
fprintf('minhdirD=%f\n', minhdirD);
%chk('LPP==LPD, min hd', minhdir, minhdirD)
%chk('vectS LPP==LPD', MRB.GetVectS(1),MRB.GetVectS(2)); 

% %% CALCULO Y CHEQUEO DEL FACTOR DE CARGA DE COLAPSO PARA vectQ
% % La comprobacion solo es valida para vectQ y una geometria
% 
% subsection('LP');
% 
% minhdir=MRB.GethdirMinLPP(ielem, ijunt, alpha, gammau);
% %chk('LP', gammaQM, 18.8941)
% subsection ('LP')

%% DIBUJOS
%
subsection ('dibujos')

iniFigureArcoTSAM (2);

MRB.plot;
escf=1;
ihip=3;
MRB.plotf(escf, ihip);
%escf=1;
% ihip=1;
% MRB.plotf(escf, ihip);
% MRB.plotj;

iniFigureArcoTSAM (3);


h= MRB.plot;
set(h,'facealpha',.0)
%set(h,'facecolor','r')
esca=t/2;
iSol=1;
MRB.plotu( false,iSol,esca);
MRB.plotn;
MRB.plotuj(false,iSol,esca);

iniFigureArcoTSAM (4);

escf=-.025;
escu=0;
MRB.plot;
MRB.plotn;
MRB.plotRjULM(escf, false, iSol, escu);

pauseOctaveFig

%% Chequeos
%
Srv=-MRBa.elems{1}.VectS{1}(3)+MRBa.elems{MRBa.GetNelems}.VectS{1}(6) ...
    -MRBb.elems{1}.VectS{1}(3)+MRBb.elems{MRBa.GetNelems}.VectS{1}(6) ...
    -MRBc.elems{1}.VectS{1}(3)+MRBc.elems{MRBa.GetNelems}.VectS{1}(6);
Sq=qpml*lS*3;    

chk(sprintf('Suma reacciones verticales (%f) == suma cargas (%f)', ...
        Srv, Sq), Srv, Sq);

 
fprintf('Reacción horizontal en spoke 1: (%f)\n', MRBa.elems{1}.VectS{1}(2));
fprintf('Reacción vertical en spoke 1: (%f)\n',   MRBa.elems{1}.VectS{1}(3));

fprintf('Reacción horizontal en spoke 2: (%f)\n', MRBb.elems{1}.VectS{1}(2));
fprintf('Reacción horizontal en spoke 2: (%f)\n', MRBb.elems{1}.VectS{1}(3));

fprintf('Reacción vertical en spoke 3: (%f)\n',   MRBc.elems{1}.VectS{1}(2));
fprintf('Reacción vertical en spoke 3: (%f)\n',   MRBc.elems{1}.VectS{1}(3));
    