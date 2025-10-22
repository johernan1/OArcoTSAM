function swapXZinFig(ax)
%SWAPXZINFIG Intercambia los ejes X y Z de un dibujo 3D en MATLAB.
%
%   swapXZinFig(h)
%       Intercambia las coordenadas X y Z de todos los objetos gráficos
%       3D de la figura indicada por 'ax'.
%
%   Parámetros:
%       h - handle a una figura (Figure).
%
%   Notas:
%       - Modifica los objetos directamente (no crea una copia).

if nargin < 1 || isempty(h)
    ax = gca;
end
h = findobj(ax, '-property', 'XData');

for k = 1:length(h)
    try
  	  X = get(h(k), 'XData');
      Y = get(h(k), 'YData');
      Z = get(h(k), 'ZData');

      % Intercambiar X y Z
      set(h(k), 'XData', Z, 'ZData', X);
    end
end

% Objetos tipo texto
texts = findobj(ax, 'Type', 'text');
for k = 1:length(texts)
    pos = get(texts(k), 'Position'); % [X Y Z]
    if numel(pos) >= 3
        % Intercambiar X y Z
        set(texts(k), 'Position', [pos(3) pos(2) pos(1)]);
    end
end

% Objetos tipo quivers
quivers = findobj(ax, 'Type', 'Quiver');
for k = 1:length(quivers)
    % Extraer datos
    U = get(quivers(k), 'UData');
    V = get(quivers(k), 'VData');
    W = get(quivers(k), 'WData');

    % Intercambiar X <-> Z
    set(quivers(k), ...
        'UData', W, 'WData', U);
end

axis tight;    
axis equal
end
