function m=mem()

    [tmp mem_usage] = system(['cat /proc/$(pgrep MATLAB)/status | grep VmSize']);

    if contains(mem_usage,'VmSize')
        m=round(str2num(strtrim(extractAfter(extractBefore(mem_usage, ' kB'), ':'))) / 1000);
    else
        m=0
    end
end
