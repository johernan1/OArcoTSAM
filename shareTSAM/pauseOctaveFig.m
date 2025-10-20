function pauseOctaveFig()
    if(~amImatlab)
        printf('para continuar pulse figura %d\n',get(0, 'currentfigure'));
        w = waitforbuttonpress;
    end
end

