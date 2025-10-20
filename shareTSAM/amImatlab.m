function b = amImatlab ()
    b=logical(strfind(version,'R'));
    if b
    else
        b=0;
    end
end