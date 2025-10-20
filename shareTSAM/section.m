function  section(varargin)
%SECTION Summary of this function goes here
%   Detailed explanation goes here
    titulo=chkArg('_',varargin{:});
    depth1=chkArg(0,varargin{2:end})*4;
    depth2=chkArg(0,varargin{3:end});
    c=chkArg('_',varargin{4:end});
    c=double(c);
    depth0=chkArg(size(dbstack,1),varargin{5:end});
    
    nBlancos=depth0-1-depth2;
    txt=c*ones(1,80);
    txt(1:4*(nBlancos-1))=32;
    sizeTit=size(titulo,2);
    txt(4*nBlancos+2+depth1:4*nBlancos+2+depth1+sizeTit-1)=titulo(1:sizeTit);
    disp(char(txt));
end

