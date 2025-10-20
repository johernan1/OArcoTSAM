function Index = chkIndex( maxIndex, varargin )
%CHKINDEX Summary of this function goes here
%   Detailed explanation goes here

    if nargin == 1 || isempty(varargin)
        Index = maxIndex;
    else
        Index = varargin{1};
    end

    if Index <= maxIndex && Index >-maxIndex
        Index = mod(Index, maxIndex);
        if Index==0
            Index=maxIndex;
        end
    elseif Index ~= 0
        warning('Out of range (index=%d) > (maxIndex=%d)', Index, maxIndex)
        Index=[];
    end
end

