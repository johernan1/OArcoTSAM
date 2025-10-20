function iniMatlabOctave ()
    section();
    if(amImatlab)
        section('Using: matlab');
    else
        section('Using: octave');
        % Funciones de matlab no definidas en octave
        pth=strsplit(path,':');
        for i=1:size(pth,2)
            if (findstr(cell2mat(pth(i)), 'shareTSAM'))
                addpath ([cell2mat(pth(i)) '/octave'])
            end
        end
    end
    section()
end