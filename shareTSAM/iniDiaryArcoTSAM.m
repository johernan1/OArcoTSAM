function  of = iniDiaryArcoTSAM(of)
%IniDiaryArcoTSAM inicia 'log'. Si existe el fichero log se borra
    if exist(of, 'file')==2
        delete(of);
    end
    diary (of)
end

