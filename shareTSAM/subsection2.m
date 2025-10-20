function subsection2(varargin)
    % La 'profundidad' de la seccion es fija
    titulo=chkArg('_',varargin{:});
    depth1=chkArg(0,varargin{2:end});
    depth2=chkArg(0,varargin{3:end});
    c=chkArg('_',varargin{4:end});
    section(titulo, depth1, depth2, c, 3)
end

