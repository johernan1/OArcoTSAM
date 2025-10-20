function MRBrst1=clave3(MRBA, elemA,MRBB, elemB, MRBC, elemC)

[MRBB.ucsX,MRBB.ucsY,MRBB.ucsZ] = rstGeom(MRBA, elemA, MRBB, elemB);
[MRBC.ucsX,MRBC.ucsY,MRBC.ucsZ] = rstGeom(MRBA, elemA, MRBC, elemC);
MRBrst1 = ArcoTSAM_Rst();
MRBrst1.Adds(MRBA.elems{elemA});
MRBrst1.Adds(MRBB.elems{elemB});
MRBrst1.Adds(MRBC.elems{elemC});

MRBrst1.RstAng=[[1,MRBA.ucsA];[1,MRBB.ucsA];[1,MRBC.ucsA]];
end
