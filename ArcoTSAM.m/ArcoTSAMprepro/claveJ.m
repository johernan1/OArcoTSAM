function MRBrst1=claveJ(MRBA, elemA, juntA, MRBB, elemB, juntB, varargin)
nVarargs = length(varargin);
MRBrst1 = ArcoTSAM_Rst();
[MRBB.ucsX,MRBB.ucsY,MRBB.ucsZ] = rstGeomJ(MRBA, elemA, juntA, ...
    MRBB, elemB, juntB);
MRBrst1.Adds(MRBA.elems{elemA});
MRBrst1.Adds(MRBB.elems{elemB});
% En MRB.RstAng se numera en primer lugar el sólido. Así, juntA+1, etc
auxRstAng=[[juntA+1,MRBA.ucsA]; [juntB+1,MRBB.ucsA]];
% ucs de cada uno de los elemntos de la rst (para dibujo 2.5D)
% MRBrst1.ucsa{1}=MRBA.ucsA;
% MRBrst1.ucsx{1}=MRBA.ucsX;
% MRBrst1.ucsy{1}=MRBA.ucsY;
% MRBrst1.ucsz{1}=MRBA.ucsZ;
% MRBrst1.ucsa{2}=MRBB.ucsA;
% MRBrst1.ucsx{2}=MRBB.ucsX;
% MRBrst1.ucsy{2}=MRBB.ucsY;
% MRBrst1.ucsz{2}=MRBB.ucsZ;
MRBrst1.ucsA=MRBA.ucsA;
MRBrst1.ucsX=MRBA.ucsX;
MRBrst1.ucsY=MRBA.ucsY;
MRBrst1.ucsZ=MRBA.ucsZ;
MRBrst1.ucsA(2)=MRBB.ucsA;
MRBrst1.ucsX(2)=MRBB.ucsX;
MRBrst1.ucsY(2)=MRBB.ucsY;
MRBrst1.ucsZ(2)=MRBB.ucsZ;

j=3;
for k = 1:nVarargs:3
    
    MRBC=varargin{k};
    elemC= varargin{k+1};
    juntC= varargin{k+2};
    [MRBC.ucsX,MRBC.ucsY,MRBC.ucsZ] = rstGeomJ(MRBA, elemA, juntA, ...
        MRBC, elemC, juntC);
    
    MRBrst1.Adds(MRBC.elems{elemC});
    auxRstAng=[auxRstAng;[juntC+1,MRBC.ucsA]];
%     MRBrst1.ucsa{2+k}=MRBC.ucsA;
%     MRBrst1.ucsx{2+k}=MRBC.ucsX;
%     MRBrst1.ucsy{2+k}=MRBC.ucsY;
%     MRBrst1.ucsz{2+k}=MRBC.ucsZ;
     MRBrst1.ucsA(j)=MRBC.ucsA;
     MRBrst1.ucsX(j)=MRBC.ucsX;
     MRBrst1.ucsY(j)=MRBC.ucsY;
     MRBrst1.ucsZ(j)=MRBC.ucsZ;
     j=j+1;
end
MRBrst1.RstAng=auxRstAng;
end
