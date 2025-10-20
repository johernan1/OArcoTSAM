function  outArg = chkArg( defArg, varargin )
%CHKARG Summary of this function goes here
%   Detailed explanation goes here

    if nargin == 1 || isempty(varargin) || isempty(varargin{1})
        outArg = defArg;
    else
        outArg = varargin{1};
    end

end

