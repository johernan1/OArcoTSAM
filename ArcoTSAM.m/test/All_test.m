%% Chequeo objetos ArcoTSAM_f 
testF
%% Chequeo objetos ArcoTSAM_fsis
testfsis
%% Chequeo objetos ArcoTSAM_RB 
% ArcoTSAM_RB es un RB generico con propiedades comunes a todos los
% RB como geometria, juntas,...
% No está definida GetH (por ejemplo) pues esta depende de  
% objetos particulares derivados de ArcoTSAM_RB 
% Sin embargo, si están definidas funciones comunes a todos los RB, como 
% chkEQU o isEQU. Estas funciones sólo 'funcionarán' en los RBxxx derivados
% de esta clase en los cuales se define GetH
testRB0
%% Chequeo objetos ArcoTSAM_RB210 y ArcoTSAM_Modelo
% Este RB deriva de ArcoTSAM_RB y ya es 'operativo'. ArcoTSAM_Modelo
% es un Modelo de RB. Entre sus funciones se incluye GetCFoHdir
% que calcula el vector c de la función objetivo en un problema de 
% max/min h, o GetMaxGammaLPD, GethdirMinLPD que plantean y resuelven
% el LP
% Se calcula y chequea el FACTOR DE CARGA DE COLAPSO de un 
% ArcoTSAM_Modelo particular 
testRB210
%% Chequeo de objetos ArcoTSAM_RB210 y ArcoTSAM_Modelo.
% Se utilizan las funciones mpl2RB210, geomEscarzano y topoRebajado
% (similares las útimas a las originales de maple) para definir geometría,
% topología, etc.
testEscarzano
testRB222
testRB210b
testRB210c
testEscarzanoc
testRB210d
testRB210g
testRB210h
testEscarzanoh
%% Chequeo resistencia
testResEscarzano
testResEscarzanoc
%% Chequeo bóvedas
testBoveda2
testBoveda3
testBovedaSGEM
testBovedaSGGM
testBovedaVVEM
testBovedaVVGM