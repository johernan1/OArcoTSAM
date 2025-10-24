function polilineas = leerPolilineasDXF(fichero)
%LEERPOLILINEASDXF Lee un archivo DXF y extrae todas las polilíneas.
%
%   polilineas = leerPolilineasDXF('archivo.dxf')
%
%   Devuelve un struct array con campos:
%     - tipo: 'POLYLINE' o 'LWPOLYLINE'
%     - capa: nombre de la capa
%     - vertices: matriz Nx2 o Nx3 con las coordenadas
%
%   NOTA: funciona con DXF ASCII. No con DXF binarios.

%% Leer archivo
txt = fileread(fichero);

% Normalizar saltos de línea (importante para compatibilidad)
% Reemplazar \r\n -> \n
txt = strrep(txt, sprintf('\r\n'), sprintf('\n'));

% Reemplazar \r solitarios -> \n
txt = strrep(txt, sprintf('\r'), sprintf('\n'));

%% Dividir por entidades
% Cada entidad DXF empieza con "0\nPOLYLINE" o "0\nLWPOLYLINE"
pat = '(?<=\n0\n)(POLYLINE|LWPOLYLINE)([\s\S]*?)(?=\n0\nENDSEC|\n0\nPOLYLINE|\n0\nLWPOLYLINE|$)';
pat = '(?<=\n  0\nLWPOLYLINE\n)([\s\S]*?)(?=\n  0\n)'; % hasta el siguiente 0
bloques = regexp(txt, pat, 'tokens');

if isempty(bloques)
    warning('No se encontraron polilíneas en %s.', fichero);
    polilineas = [];
    return
end

%% Inicializar salida
polilineas = struct('capa', {}, 'vertices', {});

%% Procesar cada bloque
for i = 1:numel(bloques)
    %tipo = strtrim(bloques{i}{1});
    contenido = bloques{i}{1};

    % Buscar capa (Group Code 8)
    capa = '';
    tcap = regexp(contenido, '\n  8\s*\n([^\n]+)', 'tokens', 'once');
    if ~isempty(tcap)
        capa = strtrim(tcap{1});
    end

    % Buscar vértices (Group Codes 10, 20, 30)
    x = regexp(contenido, '\n 10\s*\n([-\d\.eE]+)', 'tokens');
    y = regexp(contenido, '\n 20\s*\n([-\d\.eE]+)', 'tokens');
    z = regexp(contenido, '\n 30\s*\n([-\d\.eE]+)', 'tokens');

    nx = numel(x);
    ny = numel(y);
    nz = numel(z);

    if nx == ny && nx > 0
        X = str2double([x{:}]);
        Y = str2double([y{:}]);
        if nz == nx
            Z = str2double([z{:}]);
            V = [X(:), Y(:), Z(:)];
        else
            V = [X(:), -Y(:)];
        end
    else
        % Si no hay pares 10/20, intentamos LWPOLYLINE compacta
        data = regexp(contenido, '10\s*\n([-\d\.eE]+)\n20\s*\n([-\d\.eE]+)', 'tokens');
        if ~isempty(data)
            V = cellfun(@(c)[str2double(c{1}), str2double(c{2})], data, 'UniformOutput', false);
            V = vertcat(V{:});
        else
            V = [];
        end
    end

    % Añadir al resultado
    %polilineas(end+1).tipo = tipo;
    polilineas(end+1).capa = capa;
    polilineas(end).vertices = V;
end

fprintf('Se encontraron %d polilíneas en "%s".\n', numel(polilineas), fichero);
end


