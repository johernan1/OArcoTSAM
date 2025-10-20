function [ucsX, ucsY, ucsZ]=rstGeomJ( MRB1, elem1, junt1, MRB2, elem2, junt2)
%RSTGEOM Summary of this function goes here
%   Detailed explanation goes here

cdg_1=MRB1.elems{elem1}.GetCdgJunt;
cdg_1=cdg_1(junt1,:);
x1=cdg_1(1)*cos(MRB1.ucsA)+MRB1.ucsX;
y1=cdg_1(1)*sin(MRB1.ucsA)+MRB1.ucsY;
z1=cdg_1(2)+MRB1.ucsZ;

cdg_2=MRB2.elems{elem2}.GetCdgJunt;
cdg_2=cdg_2(junt2,:);
x2=cdg_2(1)*cos(MRB2.ucsA);%+MRB2.ucsX;
y2=cdg_2(1)*sin(MRB2.ucsA);%+MRB2.ucsY;
z2=cdg_2(2);%+MRB2.ucsZ;

ucsX=x1-x2;
ucsY=y1-y2;
ucsZ=z1-z2;
end
