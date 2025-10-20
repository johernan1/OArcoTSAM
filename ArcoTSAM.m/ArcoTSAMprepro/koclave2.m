function MRBrst1=clave2(MRBA, elemA,MRBB, elemB)

[MRBB.ucsX,MRBB.ucsY,MRBB.ucsZ] = rstGeom(MRBA, elemA, MRBB, elemB);
MRBrst1 = ArcoTSAM_Rst();
MRBrst1.Adds(MRBA.elems{elemA});
MRBrst1.Adds(MRBB.elems{elemB});

MRBrst1.RstAng=[[1,MRBA.ucsA];[1,MRBB.ucsA]];
end
