function MRBrst1=clave(MRBA, elemA,MRBB, elemB, varargin)
nVarargs = length(varargin);
MRBrst1 = ArcoTSAM_Rst();
[MRBB.ucsX,MRBB.ucsY,MRBB.ucsZ] = rstGeom(MRBA, elemA, MRBB, elemB);
MRBrst1.Adds(MRBA.elems{elemA});
MRBrst1.Adds(MRBB.elems{elemB});
MRBrst1.RstAng=[[1,MRBA.ucsA]; [1,MRBB.ucsA]];
% ucs
MRBrst1.ucsA=MRBA.ucsA;
MRBrst1.ucsX=MRBA.ucsX;
MRBrst1.ucsY=MRBA.ucsY;
MRBrst1.ucsZ=MRBA.ucsZ;
MRBrst1.ucsA(2)=MRBB.ucsA;
MRBrst1.ucsX(2)=MRBB.ucsX;
MRBrst1.ucsY(2)=MRBB.ucsY;
MRBrst1.ucsZ(2)=MRBB.ucsZ;
j=3;
for k = 1:2:nVarargs
    MRBC=varargin{k};
    elemC= varargin{k+1};
    [MRBC.ucsX,MRBC.ucsY,MRBC.ucsZ] = rstGeom(MRBA, elemA, MRBC, elemC);
   
    MRBrst1.Adds(MRBC.elems{elemC});
    MRBrst1.RstAng=[MRBrst1.RstAng;[1,MRBC.ucsA]];
    
     MRBrst1.ucsA(j)=MRBC.ucsA;
     MRBrst1.ucsX(j)=MRBC.ucsX;
     MRBrst1.ucsY(j)=MRBC.ucsY;
     MRBrst1.ucsZ(j)=MRBC.ucsZ;
     j=j+1;
end
end
