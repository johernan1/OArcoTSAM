function Nodos = geomPuntal(x1,y1,x2,y2,t,nd)


    Nodos=[];

    ix=(x2-x1);
    iy=(y2-y1);
    L=sqrt(ix*ix+iy*iy);
    vnx=ix/L;
    vny=iy/L;
    vtx=vny;
    vty=-vnx;
    ix=ix/nd;
    iy=iy/nd;




    for i = 0 : nd
        Nodos(end+1,:)=[x1+i*ix, y1+i*iy];
        Nodos(end+1,:)=[x1+i*ix+t*vtx, y1+i*iy+t*vty];
    end
end