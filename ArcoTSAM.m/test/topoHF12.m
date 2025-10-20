%% Rose Windows. J Heyman. Fig 12
% Empuje máximo y mínimo en simple rose window.
% 

subsection ('topoHF12')
%% GEOMETRIA Y TOPOLOGIA
%
subsection ('        topo')

MRBiring = {};
MRBspoke = {};
MRB = ArcoTSAM_Modelo();
angulS=2*pi/nSpoke;
angulP=pi/6;
anguSP=pi-angulS/2-angulP
radioS=radioT/sin(anguSP)*sin(angulP)
longPe=radioT/sin(anguSP)*sin(angulS/2)
longSp=radioS-radioI;  % longitud del spoke
longRi = 2*radioI*sin(2*pi/nSpoke/2); % longitud de cada tramo del inner ring
for iSpoke =1:nSpoke
    %% Geometría y topología de Anillo
    x0=     0;
    z0=iSpoke/2;
    x1=longRi;
    z1=z0;
    MRBiring{iSpoke}=mpl2RB210(geomPuntal(x0,z0,x1,z1,t,neleRi),...
        topoRebajado(neleRi));
    
    ncx=0; while ncx < MRB.GetMaxConex;    ncx = ncx+100; end;
    MRBiring{iSpoke}.MoveConex(ncx);
    
    MRBiring{iSpoke}.ucsA=2*pi/nSpoke*(iSpoke-1)+pi/2+2*pi/nSpoke/2;
    MRBiring{iSpoke}.name=sprintf('R_{%d}', iSpoke);
    MRB.Adds(MRBiring{iSpoke});
    
    %% Geometría y topología de los radios
    x0=radioI;
    z0=iSpoke/2;
    x1=longSp+x0;
    z1=z0;
    MRBspoke{iSpoke}=mpl2RB210(geomPuntal(x0,z0,x1,z1,t,neleSp), ...
        topoRebajado(neleSp));
    
    ncx=0; while ncx < MRB.GetMaxConex;    ncx = ncx+100; end;
    MRBspoke{iSpoke}.MoveConex(ncx);
    
    MRBspoke{iSpoke}.ucsA=2*pi/nSpoke*(iSpoke);
    MRBspoke{iSpoke}.name=sprintf('S_{%d}', iSpoke);
    MRB.Adds(MRBspoke{iSpoke});
    
    %% Geometría y topología de petalos
    x0=radioT;
    z0=iSpoke/2;
    x1=longPe+x0;
    z1=z0;
    MRBpeta1{iSpoke}=mpl2RB210(geomPuntal(x0,z0,x1,z1,t,nelePe), ...
        topoRebajado(nelePe));
    
    ncx=0; while ncx < MRB.GetMaxConex;    ncx = ncx+100; end;
    MRBpeta1{iSpoke}.MoveConex(ncx);
    
    MRBpeta1{iSpoke}.ucsA=2*pi/nSpoke*(iSpoke)+(pi-anguSP);
    MRBpeta1{iSpoke}.name=sprintf('P1_{%d}', iSpoke);
    MRB.Adds(MRBpeta1{iSpoke});
     
    x0=x1+2;
    x1=longPe+x0;
    MRBpeta2{iSpoke}=mpl2RB210(geomPuntal(x0,z0,x1,z1,t,nelePe), ...
        topoRebajado(nelePe));
    
    ncx=0; while ncx < MRB.GetMaxConex;    ncx = ncx+100; end;
    MRBpeta2{iSpoke}.MoveConex(ncx);
    
    MRBpeta2{iSpoke}.ucsA=2*pi/nSpoke*(iSpoke)-(pi-anguSP);
    MRBpeta2{iSpoke}.name=sprintf('P2_{%d}', iSpoke);
    MRB.Adds(MRBpeta2{iSpoke});
    

    %% Reacciones
    MRBpeta1{iSpoke}.elems{nelePe}.Conex(2,:)=[0 0 0];
    MRBpeta1{iSpoke}.elems{nelePe}.name=sprintf('A2_{%d}', iSpoke);
    MRBpeta2{iSpoke}.elems{nelePe}.Conex(2,:)=[0 0 0];
    MRBpeta2{iSpoke}.elems{nelePe}.name=sprintf('A2_{%d}', iSpoke);
    
    %% Definición de las claves
    if iSpoke>1
        MRBkey{iSpoke-1}=claveJ(MRBiring{iSpoke-1}, neleRi, 2, ...
            MRBiring{iSpoke}, 1, 1, ...
            MRBspoke{iSpoke-1}, 1, 1);
        MRBkey{iSpoke-1}.elems{1}.name=sprintf('C_{%d}', iSpoke-1);
        MRBkey{iSpoke-1}.elems{2}.name=sprintf('C_{%d}', iSpoke-1);
        MRBkey{iSpoke-1}.elems{3}.name=sprintf('C_{%d}', iSpoke-1);
        % Los petalos
        MRBkey{iSpoke-1+nSpoke}=claveJ( ...
            MRBspoke{iSpoke-1}, neleSp, 2, ...
            MRBpeta1{iSpoke-1},1,1,...
            MRBpeta2{iSpoke-1},1,1);
    end
    if iSpoke==nSpoke
        MRBkey{iSpoke}=claveJ(MRBiring{iSpoke}, neleRi, 2, ...
            MRBiring{1}, 1, 1, ...
            MRBspoke{iSpoke}, 1, 1);
        MRBkey{iSpoke}.elems{1}.name=sprintf('C_{%d}', iSpoke);
        MRBkey{iSpoke}.elems{2}.name=sprintf('C_{%d}', iSpoke);
        MRBkey{iSpoke}.elems{3}.name=sprintf('C_{%d}', iSpoke);
       % Los petalos
        MRBkey{iSpoke+nSpoke}=claveJ( ...
            MRBspoke{iSpoke}, neleSp, 2, ...
            MRBpeta1{iSpoke},1,1,...
            MRBpeta2{iSpoke},1,1);
    end

    % Las restricciones tienen que añadirse al final, pues de otro modo
    % SetConeS no funciona correctamente
    
end
%% Se añaden las restricciones/claves al modelo MRB
%
subsection ('        claves')

ncx=1;
while ncx < MRB.GetMaxConex;    ncx = ncx+100; end;
for iKey =1:numel(MRBkey)
    MRBkey{iKey}.Conex=ncx:ncx+4;
    ncx=ncx+10;
    MRB.Adds(MRBkey{iKey});
end

%% ASIGNACION DEL VECTOR ConeS DE CADA ELEMENTO
% 
subsection ('        SetConeS')
MRB.SetConeS;

%% Dibujo topología, geometria,.. 2D
subsection ('        plot2D')

f=iniFigureArcoTSAM(101);
if(amImatlab) f.Name='topo2D, claves'; end;
global ucs2D;
ucs2D = true;
g=MRB.plot;
set(g,'facealpha',.0);

ucs2D = true;
%c=prism(numel(MRBkey));
c=colorcube(numel(MRBkey));
for iKey =1:numel(MRBkey)
    g=MRBkey{iKey}.plot;
    set(g,'facecolor',c(iKey,:));
    MRBkey{iKey}.plotname;
end
f=iniFigureArcoTSAM(102);
if (amImatlab) f.Name='nombre elementos'; end;
MRB.plot;
MRB.plotname;
f=iniFigureArcoTSAM(103); 
if (amImatlab) f.Name='numero elementos'; end;
MRB.plot;
MRB.plotn;
ucs2D = false;

%% Dibujo topología, geometria,.. 3D
subsection ('        plot3D')
f=iniFigureArcoTSAM(111);
if (amImatlab) f.Name='topo3D, juntas, apoyos'; end;

MRB.plot;    % Topología
MRB.plotj;   % juntas
MRB.plota;   % Apoyos
c=colorcube(numel(MRBkey));
for iKey =1:numel(MRBkey)
    g=MRBkey{iKey}.plot;
    set(g,'facecolor',c(iKey,:));
    MRBkey{iKey}.plotname;
end


f=iniFigureArcoTSAM(112);
if (amImatlab) f.Name='nombre elementos'; end;
MRB.plot;    % Topología
MRB.plotname;
f=iniFigureArcoTSAM(113);
if (amImatlab) f.Name='numero elementos'; end;
MRB.plot;    % Topología
MRB.plotn;   % numero de cada elemento

