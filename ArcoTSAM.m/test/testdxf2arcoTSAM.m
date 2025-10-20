%% Panteon.dxf
% Geometría y Topología
% 

addpath('../../shareTSAM/');
addpath('../OArcoTSAM/');
addpath('../ArcoTSAMprepro');
addpath('Datos');



subsection ('Panteon');
% midxf:=dxf2arcoTSAM("Datos/Panteon2010.dxf",["DEFPOINTS"],0.01);
% midxf:=dxf2arcoTSAM("Datos/Panteon14.dxf",["DEFPOINTS"],0.01);
%dxf2arco('Datos/PANTEON2010.DXF','DEFPOINTS',0.01);
leerPolilineasDXF('Datos/PANTEON2010.DXF')

