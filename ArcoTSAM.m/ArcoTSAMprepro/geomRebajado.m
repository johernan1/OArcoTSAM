function Nodos = geomRebajado(R1,R2,theta1,theta2,nd)


% geomRebajado15:=proc(R1,R2,theta1,theta2,nd)
% >      local Nodos, thetai, i, ex_, ey_, Args,
% >            x, x0, xi_, y, y0, yi_, coseno, seno, R;
% > 
% >      Args:=select(type,[args],equation):
         ex_=1;
         ey_=1;
% >      ex_:=1: hasoption( Args, ex, 'ex_');
% >      ey_:=1: hasoption( Args, ey, 'ey_');
% >      if hasoption( Args, yi, 'yi_') then R:=R1: fi:
% >      if hasoption( Args, ye, 'yi_') then R:=R2: fi:     
% >      if hasoption( Args, xi, 'xi_') then R:=R1: fi:
% >      if hasoption( Args, xe, 'xi_') then R:=R2: fi:
% >       
     Nodos=[];
     thetai=(theta2-theta1)/nd;
 
% >      #################################################################
% >      # Opcion yi=[], ye=[]
% >      #################################################################
% > 
% >      if (type(yi_,list)) then
% >          yi_:=sort(yi_);
% > 
% >          y0:=R*cos(theta1)*ey_;
% >          for y in yi_
% >          do
% >             
% >              coseno:=evalf((y+y0)/(R*ey_));
% >              if (abs(coseno) > 1) then next; fi;
% >              thetai:=-arccos(coseno);
% >              Nodos:=[op(Nodos),map(evalf,[R1*sin(thetai),
% >                                           R1*cos(thetai)])];
% >              Nodos:=[op(Nodos),map(evalf,[R2*sin(thetai)*ex_,
% >                                           R2*cos(thetai)*ey_])];
% >          od;
% >          RETURN (Nodos);   
% >      fi:
% > 
% > 
% >      #################################################################
% >      # Opcion xi=[], xe=[]
% >      #################################################################
% > 
% >      if (type(xi_,list)) then
% >          xi_:=sort(xi_);
% > 
% >          x0:=R*sin(theta1)*ex_;
% >          for x in xi_
% >          do      
% >              seno:=evalf((x+x0)/(R*ex_));
% >              if (abs(seno) > 1) then next; fi;
% >              thetai:=arcsin(seno);
% >              Nodos:=[op(Nodos),map(evalf,[R1*sin(thetai),
% >                                           R1*cos(thetai)])];
% >              Nodos:=[op(Nodos),map(evalf,[R2*sin(thetai)*ex_,
% >                                           R2*cos(thetai)*ey_])];
% >          od;
% >          RETURN (Nodos);   
% >      fi:
% > 
% > 
% >      #################################################################
% >      #################################################################
% >      
% >  
      for i = 0 : nd
         Nodos(end+1,:)=[R1*sin(theta1+i*thetai), ...
                                      -R1*cos(theta1+i*thetai)];
         Nodos(end+1,:)=[R2*sin(theta1+i*thetai)*ex_, ...
                                      -R2*cos(theta1+i*thetai)*ey_];
      end
end