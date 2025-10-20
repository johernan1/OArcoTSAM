%function MRB = dfx2arco(fichero, listaCapas, tol)
    function  dfx2arco(fichero, listaCapas, tol)
%DFX2ARCO Summary of this function goes here
%   Detailed explanation goes here

% dxf2arcoTSAM15:=proc(fichero, listaCapas, tol) 
% >     local text, line, dxfarco, ST, textpolyline, st, capapol, 
% >           nudosdxfdov, coorver, xver, yver, dov,i, capa, buffer;
% >  
% >     Args:=select(type,[args],equation):
% >     hasoption( Args, ndim, 'ndim');
% >     print("ndim=",ndim);
% > 
% >     # tamaño maximo de TEXT aprox 520000 en sistemas 32
% >     # Ademas maple es mas eficiente manejando cadenas cortas
% >     # por lo que se lee el fichero en varias cadenas de longitud:
% >     buffer:=50000;
% >     ntext:=1:
% >     Text[ntext]:=readbytes(fichero,buffer):
% >     while(Text[ntext]<>0) do
% >         ntext:=ntext+1;
% >         Text[ntext]:=readbytes(fichero,buffer):    
% >     od:
% > 
% > 
% > 
% >     print("leido el fichero en ",ntext-1," cadenas"); 
filetext = fileread(fichero);
% >     dxfarco := ([seq([],i=1 .. nops(listaCapas))]);
% > 
% > 
% > for nt from 1 to ntext-1
% > do
% >     print("procesando cadena ",nt); 
% >     if nt=1 then 
% >         text:=convert(Text[nt],'bytes');
% >     else
% >         text:=convert(text,'bytes');
% >         text:=convert([op(text),op(Text[nt])],'bytes');
% >     fi:
% > 

% >     ST := 1;  
% >     while ST <> 0 do
% >         if (nt<>ntext-1) then
% > #            print("chequeando longitud de cadena: ",length(text),"nt=,ntext-1=",nt,ntext-1);
% >             if (length(text)<buffer/10) then break fi:
% > #            printf("No se ha hecho break");
% >         fi: 
% >         #######################################################
% >         #### Se busca la proxima polilinea ####################
% >         ####################################################### 
% >         ST := SearchText("POLYLINE",text);
% >         STN:= SearchText("LWPOLYLINE",text);  ### versiones nuevas de acad
% > # print("ST=",ST,"STN=",STN);
% >         if STN<>0 then ST=STN fi;             ### versiones nuevas de acad
% >          
% >         if ST = 0 then 
% >             text := "" 
% >         else 
% >             text := substring(text,ST + 1 .. length(text))
% >         fi;
% >         #######################################################
% >         #### Y el final de la misma  ##########################
% >         #######################################################
% >         STNF := SearchText("\n  0\r",text);       ### versiones nuevas de acad        
% >         ST := SearchText("SEQEND",text);
% >         # print("ST=",ST,"STN=",STN,"...");
% > 
% >         if ((ST = 0) and (STNF <> 0)) then ST := STNF; fi; ### versiones nuevas de acad
% >         #print("ST=",ST,"STN=",STN);
% > 
% >         if ST = 0 then 
% >             textpolyline := text 
% >         else 
% >             textpolyline := substring(text,1 .. ST+1) 
% >         fi;
% >         #######################################################
% >         #### Se determina la capa en la que esta ##############
% >         #######################################################          
% >         st := SearchText(" 8\r",textpolyline); 
% >         textpolyline := substring(textpolyline,st+2 .. length(textpolyline));
% >         capapol := sscanf(textpolyline,"%s"); 
% > # print("Encontrada una polylinea en la capa ",capapol,whattype(capapol)); 
% > # print(textpolyline);
% >         for capa from 1 to nops(listaCapas)
% >         do 
% >           if capapol[1] = listaCapas[capa] then
% > # print(textpolyline);  
% >             nudosdxfdov := [];
% >             #######################################################
% >             #### Se busca el proximo vertice ######################
% >             #######################################################
% >             st := SearchText("VERTEX",textpolyline);
% > # print("st=",st,"STN",STN,"...");
% >             if STN<>0 then st:=1 fi;    ### version nueva de acad
% > # print("st=",st);
% >             if (st<>0) then 
% >                 textpolyline := substring(textpolyline,
% >                                           st+1 .. length(textpolyline)); 
% >                 st := SearchText("\n 10\r",textpolyline);  
% >                 while st <> 0 do 
% >                     textpolyline := substring(textpolyline,
% >                                               st+1 .. length(textpolyline));
% >                     if ndim=3 then
% >                          coorver := sscanf(textpolyline,"%s%f%s%f%s%f");
% >                          xver := coorver[2]; 
% >                          yver := coorver[4]; 
% >                          zver := coorver[6];
% > #print(xver,yver,coorver); 
% >                          nudosdxfdov := [op(nudosdxfdov), [xver, yver, zver]];
% >                     else; 
% >                          coorver := sscanf(textpolyline,"%s%f%s%f");                         
% >                          xver := coorver[2]; 
% >                          yver := coorver[4];
% > #print(xver,yver,coorver); 
% >                          nudosdxfdov := [op(nudosdxfdov), [xver, yver]];
% >                      fi;
% >                     st := SearchText("\n 10\r",textpolyline) 
% >                 od; 
% > #print(nudosdxfdov);
% >                 if  nudosdxfdov[1]=nudosdxfdov[nops(nudosdxfdov)] then
% >                     nudosdxfdov:=[seq(nudosdxfdov[i],
% >                                   i=1..nops(nudosdxfdov)-1)];
% >                 fi;
% >                 dov := [nudosdxfdov, [[seq(i,i = 1 .. nops(nudosdxfdov))]]];
% > #print("AREA=",areas(dov));
% >                 if op(arcoTSAM:-areas(dov))<0 then
% >                     dov := [nudosdxfdov, [[seq(nops(nudosdxfdov)-i+1,
% >                                            i=1 .. nops(nudosdxfdov))]]];
% >                 fi  
% >             fi; 
% >           fi;
% > 
% > #print(dov); 
% > #print("dxfarco",dxfarco); 
% > 
% >           if type(dov,list) then
% >             if dxfarco[capa] = [] then 
% >                 dxfarco[capa] := dov 
% >             else
% > #print("se añade un elemento. En total nudos=",nops(dxfarco[capa][1]),
% > #      "elementos:=",nops(dxfarco[capa][2])); 
% >                 dxfarco[capa] := eval(unionarco(dov,dxfarco[capa],tol)) 
% >             fi
% >           fi;
% >           dov:='dov':
% >         od; 
% >     od;
% > od; 
% >     dxfarco 
% > ### WARNING: `ntext` is implicitly declared local
% > ### WARNING: `Text` is implicitly declared local
% > ### WARNING: `nt` is implicitly declared local
% > end:


end

