function err = errVect (u_1, u)
    err=abs(u_1-u);
    for iu=1:size(u_1,1)
        if (u_1 ~= 0)
            err(iu)=err(iu)/u_1(iu);
        end
    end
end