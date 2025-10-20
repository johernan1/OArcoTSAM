function Elemen = topoRebajado(n)
%TOPOREBAJADO Summary of this function goes here
%   Detailed explanation goes here


% topoRebajado15:=proc(n)
% >                   local Elemen, i, n0;
% >
n0=1;    
% >                       if (nargs>=2) then n0:= args[2]; 
% >                                     else n0:= 1;
% >                       fi:
% > 
                       %Elemen=[];
                       Elemen={};
     
                   for i = n0 : n+n0-1 
% >                         do
                   %Elemen(end+1,:)=[-2-2*(i-1),1+2*(i-1),-3-2*(i-1),4+2*(i-1)];
                   Elemen{end+1}=[-2-2*(i-1),1+2*(i-1),-3-2*(i-1),4+2*(i-1)];
% >                         od;
% >                   end:
end