function  visdiff(if1,if2)
%VISDIFF 
section('visdiff AUN no definida en octave')
section(['system diff ' if1 ' ' if2 ' (funciona en linux con meld)'])
    if(system (['diff ' if1 ' ' if2]) ~= 0)
        warning ('Ficheros distintos');
        system(['meld ' if1 ' ' if2])
    end
end

