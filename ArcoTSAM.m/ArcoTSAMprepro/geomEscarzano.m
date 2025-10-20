function Nodos = geomEscarzano(l,f,e,n)
%GEOMESCARZANO Summary of this function goes here
%   Detailed explanation goes here

    r1=1/8*(4*f^2+l^2)/f;
    r2=r1+e;
    phi=-(pi/2-atan2(-(4*f^2-l^2)/(4*f^2+l^2),4*l*f/(4*f^2+l^2)));
    alpha=-phi;

        %%TODO incluir argumentos 6º y 7º
    %Nodos = geomRebajado(r1,r2,phi,alpha,n,1,1);
    Nodos = geomRebajado(r1,r2,phi,alpha,n);
end
