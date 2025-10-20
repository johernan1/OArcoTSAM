function  mtoc = mytoc(txt,option)
%MYTOC almacena los resultado de una sucesión de toc
%
%
% Syntax
% mytoc(txt)
% mytoc(txt, option)
%
% Description
% toc displays the elapsed time, in seconds, since the most recent
% execution of the TIC command.
% mytoc almacena lo resutados de varios toc
% Las opciones disponibles son: 'item', 'toc', 'plot'
%
% Example
% clear mytoc;
% tic;
% mytoc('item1');
% mytoc('item2');
% mytoc('texto');
% mytoc(' ', "plot");
%
% See also my_execute, my_fetch, my_sqlwrite, mytoc

persistent n mytoc_txt mytoc_toc
if isempty(n)
    n=0;
    %mytoc_tx(1,:)="inicio";
    %mytoc_txt=mytoc_tx;
    mytoc_tx={'inicio'};
    mytoc_txt=mytoc_tx;
end
if nargin == 1
    n=n+1;
    mtoc = toc;
    %mytoc_txt(n,:)=convertCharsToStrings(txt);
    mytoc_txt(n)={strcat(num2str(n),'_',txt)};
    mytoc_toc(n)=mtoc;
else
    if strcmp(option,'item')
        mtoc=mytoc_txt;
    elseif strcmp(option,'toc')
        mtoc=mytoc_toc;
    elseif strcmp(option,'plot')
        bar(mytoc_toc);
        title('Categorías ordenadas en la salida');
        mtoc=mytoc_txt'
    else
        warning 'Opciones de mytoc: "item", "toc" y "plot"';
    end
end
end

