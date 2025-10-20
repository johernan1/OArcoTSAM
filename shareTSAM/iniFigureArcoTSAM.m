function f = iniFigureArcoTSAM( varargin )
%iniFigureArcoTSAM Summary of this function goes here
%   Detailed explanation goes here
    f = figure(varargin{:});
    clf;
    set ( gca, 'Ydir', 'reverse', 'Zdir', 'reverse' );
    daspect([1 1 1]);
    view(0,0);
    global ucs; 
    ucs.alpha=0; % ucs definido como en acad
    ucs.x0=0;
    ucs.y0=0;
    ucs.z0=0;
    global interplUy; % valores para interpolar uy en 2.5D con interpl
    hold on;
end

