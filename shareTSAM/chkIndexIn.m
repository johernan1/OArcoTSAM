function  Index = chkIndexIn( endIndex, varargin )
%CHKINDEXIN Summary of this function goes here
%   Detailed explanation goes here
% index ={} -> Index=endIndex+1
% index = i -> Index=i
% index = 0 -> Index=endIndex
% index =-i -> Index=endIndex-i

    if nargin == 1 || isempty(varargin)
        Index = endIndex+1;
    else
        Index = varargin{1};
    end

    if Index > 0
        if Index > endIndex+1
            warning('index (%d) > endIndex + 1 (%d)', Index, endIndex+1);
        end
    else
        if Index <= 0 && Index >-endIndex
            Index = mod(Index, endIndex);
            if Index==0
                Index=endIndex;
            end
        else
            warning('Out of range (index=%d) > (maxIndex=%d)-> index=%d', Index, endIndex, endIndex+1)
            Index=endIndex+1;
        end
    end
end

