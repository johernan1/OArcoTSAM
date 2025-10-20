function chk (txt, val, varargin)
    OK=false;
    valOK=chkArg(ones(1,numel(val)), varargin{1:end});
    tol=chkArg(10^(-6), varargin{2:end});
    printOK=chkArg(true, varargin{3:end});
    if (size(val)==[1,1]) 
        %if abs(valOK)==0
        if abs(valOK)<=tol
            if abs(val-valOK)< tol
                OK=true; %section(sprintf('OK: %s', txt),2);
            else
                error('KO: %s \nKO: %f != %f (tol=%f)', txt, val, valOK, tol);
            end
        else
            if (abs((val-valOK)/valOK)< tol)
                OK=true; %section(sprintf('OK: %s', txt),2);
            else
                section(sprintf('K0: %s', txt ),2);
                error('KO: %f != %f\n (%f-%f)/%f=%f> %f\n', ...
                    val,valOK, val, valOK, valOK,...
                    abs((val-valOK)/valOK), tol);
            end
        end
    else
        nval=numel(val);
        ndigitos=floor(log10(nval))+1;
        pDigitos=sprintf('(%%%dd/%%%dd)',ndigitos,ndigitos);
        %fprintf(pDigitos, 0, numel(val));
        for idx = 1:nval
            %chk(sprintf('%s (%d)',txt, idx), val(idx), valOK(idx),tol, false)
            fprintf(pDigitos, idx, nval);
            chk('', val(idx), valOK(idx),tol, false)
            for ix=1:2*ndigitos+3
                    fprintf('\b')
            end
        end
        OK=true;
        
    end
    if (OK==true && printOK==true)
        section(sprintf('OK: %s', txt),2);
    end
end
