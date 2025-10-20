%% Boveda Segovia
% Asiento.
% 
clear all;

%% GEOMETRIA Y TOPOLOGIA
%

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro');
addpath('Datos');

wobinichTamino;
iniMatlabOctave();

topoBovedaSegovia;

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

f=iniFigureArcoTSAM(201);
if amImatlab f.Name='vectG'; end;
escf=1.25;
ihip=1;
MRB.plot;
MRB.plotf(escf, ihip);
%% CALCULO Y CHEQUEO DE Hdir
% La comprobacion solo es valida para vectQ y una geometria
xyzH=[];
% % for phi = 0.01:pi/20: 2*pi
% % for theta = pi/4:pi/8:pi/2
for theta = 0:pi/64: pi
for phi = 0:pi/64:2*pi
    
    % dirección hdir sobre la que se quiere calcular el hmax/hmin
    x=sin(phi)*cos(theta);
    y=sin(phi)*sin(theta);
    z=cos(phi);
    hdir=[x,y,z];
    if phi==0
        cosdA=1;   alphA=pi/2;
        cosdA5=1;  alphA5=pi/2;;
        cosdA12=1; alphA12=pi/2;
    elseif phi==pi/2
        cosdA=1;   alphA=-pi/2;
        cosdA5=1;  alphA5=-pi/2;;
        cosdA12=1; alphA12=-pi/2;
    else
        % Plano Pn definido por el eje z y hdir
        % vector normal plano Pn: perpendicular al eje z y a hdir
        % vn=[0,0,1]x[x,y,z]
        vn=[y, -x, 0];
        % Plano Pdir: contiene a hdir y es perpendicular al anterior
        % Esta definido por los vectores hdir y vn (perp a Pn), su vector
        % normal sera:
        % vndir=vn x hdir = [x,y,z]x[y, -x, 0]
        vndir=[z*x, y*z, -x^2-y^2];
        % Chequeos:
        % Si hdir esta contenido en el plano xy=>z=0 y vndir=[0,0,-x^2-y^2]
        % como |hdir|=1 vndir=[0,0,-1]. OK
        % Si hdir=[0,0,1] => vndir=[0,0,0] y hay que hacer otra cosa
        % Si hdir=[0,0.707,0.707] => vndir=[0,1/2,-1/2] OK
        
        % Plano del arco. Comonentes del vector director de la interseccion
        % con el plano z=0
        vxMRB1=cos(MRB01.ucsA);
        vyMRB1=sin(MRB01.ucsA);
        % hdirA: vector de la intersección del plano del arco y el plano
        % Pdir
        % hdir=[z*x, y*z, -x^2-y^2]x[vyMRB1,-vxMRB1,0]
        hdirA=[-(-x^2-y^2)*vxMRB1,-(-x^2-y^2)*vyMRB1, z*x*vxMRB1+y*z*vyMRB1]
        % ejemplo:
        % hdir=[1,0,0]=>vndir=[0,0,-1];
        %   direccion plano: [1,0,0]=>vPaPdir=[-1*1,-1*0,0]=[-1,0,0] OK
        %   direccion plano: [0.7,0.7,0]=>vPaPdir=[-1*0.7,-1*0.7,0] OK
        
        % Angulo que forma el vector anterior con la horizontal. Este es el
        % angulo con el que habrá que calcular MRB.GetCFoHdir
        cosXA=sqrt(hdirA(1)^2+hdirA(2)^2)/sqrt(hdirA(1)^2+hdirA(2)^2+hdirA(3)^2);
        alphA=acos(cosXA);%*sign([vxMRB1,vyMRB1]*[x,y]')
        alphA=pi/2-atan2(sqrt(hdirA(1)^2+hdirA(2)^2),hdirA(3));
        if (hdir(1)*hdirA(1) +hdir(2)*hdirA(2) +hdir(3)*hdirA(3)  <0)
            alphA=alphA-pi
        end
        
        % Coseno del angulo que forman hdir y hdirA
        cosdA=(hdirA(1)*hdir(1)+hdirA(2)*hdir(2)+hdirA(3)*hdir(3))/...
            sqrt(hdirA(1)^2+hdirA(2)^2+hdirA(3)^2)/sqrt(hdir(1)^2+hdir(2)^2+hdir(3)^2);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Idem arco5
        vxMRB5=cos(MRB05.ucsA);
        vyMRB5=sin(MRB05.ucsA);
        %
        hdirA=[-(-x^2-y^2)*vxMRB5,-(-x^2-y^2)*vyMRB5, z*x*vxMRB5+y*z*vyMRB5]
        %
        cosXA=sqrt(hdirA(1)^2+hdirA(2)^2)/sqrt(hdirA(1)^2+hdirA(2)^2+hdirA(3)^2);
        alphA5=pi/2-atan2(sqrt(hdirA(1)^2+hdirA(2)^2),hdirA(3));
        if (hdir(1)*hdirA(1) +hdir(2)*hdirA(2) +hdir(3)*hdirA(3)  <0)
            alphA5=alphA5-pi
        end
        %
        cosdA5=(hdirA(1)*hdir(1)+hdirA(2)*hdir(2)+hdirA(3)*hdir(3))/...
            sqrt(hdirA(1)^2+hdirA(2)^2+hdirA(3)^2)/sqrt(hdir(1)^2+hdir(2)^2+hdir(3)^2);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Idem arco12
        vxMRB12=cos(MRB12.ucsA);
        vyMRB12=sin(MRB12.ucsA);
        %
        hdirA=[-(-x^2-y^2)*vxMRB12,-(-x^2-y^2)*vyMRB12, z*x*vxMRB12+y*z*vyMRB12]
        %
        cosXA=sqrt(hdirA(1)^2+hdirA(2)^2)/sqrt(hdirA(1)^2+hdirA(2)^2+hdirA(3)^2);
        alphA12=pi/2-atan2(sqrt(hdirA(1)^2+hdirA(2)^2),hdirA(3));
        if (hdir(1)*hdirA(1) +hdir(2)*hdirA(2) +hdir(3)*hdirA(3)  <0)
            alphA12=alphA12-pi
        end
        %
        cosdA12=(hdirA(1)*hdir(1)+hdirA(2)*hdir(2)+hdirA(3)*hdir(3))/...
            sqrt(hdirA(1)^2+hdirA(2)^2+hdirA(3)^2)/sqrt(hdir(1)^2+hdir(2)^2+hdir(3)^2);
    end
% %         y=(x*vxMRB1+y*vyMRB1);
% %           if (sqrt(x^2+y^2) >0) 
% %               cosxyMRB1=cosxyMRB1/sqrt(x^2+y^2);
% %           end
% %         alphMRB1=atan2(z,cosxyMRB1);
% %         
% %         vxMRB5=cos(MRB05.ucsA);
% %         vyMRB5=sin(MRB05.ucsA);
% %         cosxMRB5=(x*vxMRB5+y*vyMRB5);
% %         if (sqrt(x^2+y^2) >0) 
% %             cosxMRB5=cosxMRB5/sqrt(x^2+y^2);
% %         end
% %         alphMRB5=atan2(z,cosxMRB5);
% %         
% %         vxMRB12=cos(MRB12.ucsA);
% %         vyMRB12=sin(MRB12.ucsA);
% %         cosxMRB12=(x*vxMRB12+y*vyMRB12);
% %         if (sqrt(x^2+y^2) >0) 
% %             cosxMRB12=cosxMRB12/sqrt(x^2+y^2);
% %         end
% %         alphMRB12=atan2(z,cosxMRB12);
%        xyzH=[xyzH; [x,y,z,theta,(pi/2-phi)*180/pi,alphA*180/pi,hdir,vn,vndir,vxMRB1,vyMRB1,0,hdirA]];
% % %       %fprintf('theta=%4.1f,phi=%4.1f,x=%4.3f, y=%4.3f, z=%5.3f, cos1=%4.3f, alphMRB1=%4.1f, cos5=%4.3f, alphMRB5=%4.1f,  cos12=%4.3f, alphMRB12=%4.1f \n', theta*180/pi, phi*180/pi, x,y,z,cosxMRB1, alphMRB1*180/pi,cosxMRB5, alphMRB5*180/pi,cosxMRB12, alphMRB12*180/pi) 
%      end
%  end
% xxx=xxxxxxxxcosxMRB1
% for theta = 0.0:pi/4:2*pi
%     for phi = 0.0:pi/4: pi
          %   abs(cosdA) se justifica pues ya se ha considerado el signo al calcular alphaA
          %   ver el if anterior para determinar alphA
          c = abs(cosdA)*MRB.GetCFoHdir(apoyoAsiento1,1,alphA);
%          c = MRB.GetCFoHdir(apoyoAsiento1,1,alphA);
         c = abs(cosdA)*MRB.GetCFoHdir(apoyoAsiento1,1,alphA)+...
             abs(cosdA5)*MRB.GetCFoHdir(apoyoAsiento5,2,alphA5)+...
             abs(cosdA12)*MRB.GetCFoHdir(apoyoAsiento12,1,alphA12);
        subsection('LP');
        minhdir = MRB.GethdirMinLPD(apoyoAsiento1,1,pi/2,2,vectG,c);
        %chk('LP', minhdir, 0.2593)
        subsection ('fin LP')
        
        %% DIBUJO Resultados 3D
        %
        ucs2D = false;
        subsection ('dibujos 3D')
        
        f=iniFigureArcoTSAM (302);
        if amImatlab f.Name='LP'; end;
        
        iSol=MRB.GetNsol;
        escf=-.05;
        escu=0;
        MRB.plot;
        MRB.plota;
        MRB.plotRjULM(escf, false, iSol, escu);
        
        pauseOctaveFig
        %ihip=3;
        %MRB.plotf(escf, ihip);
        %escf=1;
        %ihip=1;
        %MRB.plotf(escf, ihip);
        %MRB.plotj;
        
        f=iniFigureArcoTSAM (301);
        if amImatlab f.Name='MEC'; end
        
        h= MRB.plot;
        set(h,'facealpha',.0)
        %set(h,'facecolor','r')
        esca=.25/4;
        %esca=1;
        iSol=MRB.GetNsol;
        MRB.plotu( false,iSol,esca);
        MRB.plotuj(false,iSol,esca);
        
        %% DIBUJO Resultados 2D
        %
        ucs2D = true;
        subsection ('dibujos 2D')
        
        ucs2D = true;
        f=iniFigureArcoTSAM (402);
        if amImatlab f.Name='LP'; end;
        
        %iSol=1;
        %escf=-.25;
        %escu=0;
        MRB.plot;
        MRB.plota;
        MRB.plotRjULM(escf, false, iSol, escu);
        
        pauseOctaveFig
        
        f=iniFigureArcoTSAM (401);
        if amImatlab f.Name='MEC'; end
        
        h= MRB.plot;
        set(h,'facealpha',.0)
        %set(h,'facecolor','r')
        esca=.25/4;
        %esca=1;
        iSol=MRB.GetNsol;
        MRB.plotu( false,iSol,esca);
        MRB.plotuj(false,iSol,esca);
        
        %% Chequeos
        %
        
        subsection('Chequeo desplazamientos. Clave 1')
        vectUa=MRBrst1.elems{1}.VectU{1};
        vectUb=MRBrst1.elems{2}.VectU{1};
        vectUc=MRBrst1.elems{3}.VectU{1};
        vectUr=MRBrst1.VectU{1};
        cdgJa=MRBrst1.elems{1}.GetCdg;
        cdgJb=MRBrst1.elems{2}.GetCdg;
        cdgJc=MRBrst1.elems{3}.GetCdg;
        % El desplazamiento vertical tiene que ser el mismo
        chk(' v junta MRBa / v MRBrst', vectUr(3),vectUa(2)-cdgJa(1)*vectUa(3))
        chk(' v junta MRBb / v MRBrst', vectUr(3),vectUb(2)-cdgJb(1)*vectUb(3))
        chk(' v junta MRBc / v MRBrst', vectUr(3),vectUc(2)-cdgJc(1)*vectUc(3))
        
        chk('Ux junta MRBa / ux*c+uy*s MRBrst', vectUa(1)+cdgJa(2)*vectUa(3), ...
            vectUr(1)*cos(MRBrst1.RstAng(1,2))+vectUr(2)*sin(MRBrst1.RstAng(1,2)))
        chk('Ux junta MRBb / ux*c+uy*s MRBrst', vectUb(1)+cdgJb(2)*vectUb(3), ...
            vectUr(1)*cos(MRBrst1.RstAng(2,2))+vectUr(2)*sin(MRBrst1.RstAng(2,2)))
        chk('Ux junta MRBc / ux*c+uy*s MRBrst', vectUc(1)+cdgJc(2)*vectUc(3), ...
            vectUr(1)*cos(MRBrst1.RstAng(3,2))+vectUr(2)*sin(MRBrst1.RstAng(3,2)))
        
        
        chk('Uy MRBa / ux*s-uy*c MRBrst', MRBrst1.elems{1}.VectUy{1}(2), ...
            vectUr(1)*sin(MRBrst1.RstAng(1,2))-vectUr(2)*cos(MRBrst1.RstAng(1,2)))
        chk('Uy MRBb / ux*s-uy*c MRBrst', MRBrst1.elems{2}.VectUy{1}(2), ...
            vectUr(1)*sin(MRBrst1.RstAng(2,2))-vectUr(2)*cos(MRBrst1.RstAng(2,2)))
        chk('Uy MRBc / ux*s-uy*c MRBrst', MRBrst1.elems{3}.VectUy{1}(2), ...
            vectUr(1)*sin(MRBrst1.RstAng(3,2))-vectUr(2)*cos(MRBrst1.RstAng(3,2)))
        xyzH=[xyzH; [x*minhdir,y*minhdir,z*minhdir,minhdir, alphA,cosdA],phi,theta];
    end
end
iniFigureArcoTSAM
hdir_graf=plot3(xyzH(:,1),xyzH(:,2),xyzH(:,3),'o')
save("out_testBovedaSGM_CGRS");