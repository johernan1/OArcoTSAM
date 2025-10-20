

function dxf2arcoOLD(fichero, listaCapas, tol, varargin)
%DFX2ARCO Traducción aproximada a MATLAB de la versión Maple
%   dfx2arco(fichero, listaCapas, tol [, 'ndim', ndim])
%   - fichero: ruta al archivo .dxf
%   - listaCapas: cell array de nombres de capas (p.ej. {'0','CAPA1',...})
%   - tol: tolerancia usada por uniarco (si procede)
%   Opcional: pasar 'ndim', 2 o 3 para indicar dimensiones (por defecto 2).

%% Argumentos y opciones
ndim = 2;
if ~isempty(varargin)
    for k=1:2:length(varargin)
        if strcmpi(varargin{k},'ndim')
            ndim = varargin{k+1};
        end
    end
end
fprintf('ndim=%d\n', ndim);

%% Lectura por bloques (buffer) - parecido a readbytes en Maple
buffer = 50000;        % tamaño del bloque
Text = {};             % cell array para bloques leídos

fid = fopen(fichero,'r','n','US-ASCII'); % abrir en modo texto
if fid==-1
    error('No se puede abrir el fichero: %s', fichero);
end

ntext = 1;
while true
    % leemos 'buffer' bytes como char (si quedan menos, fread devuelve menos)
    block = fread(fid, buffer, '*char')';
    % todos los saltos de linea=\n
    block = strrep(block, sprintf('\r\n'), '\n');
    block = strrep(block, sprintf('\r'), '\n');
    if isempty(block)
        break;
    end
    Text{ntext} = block;
    ntext = ntext + 1;
end
fclose(fid);

fprintf('leido el fichero en %d cadenas\n', ntext-1);

%% Inicializar dxfarco (cell array, una celda por cada capa)
nCapas = numel(listaCapas);
dxfarco = cell(1,nCapas);
for i=1:nCapas
    dxfarco{i} = []; % equivalente a []
end

%% Procesar cada bloque concatenándolo progresivamente
for nt = 1:(ntext-1)
    fprintf('procesando cadena %d\n', nt);
    if nt == 1
        text = Text{nt};
    else
        % concatenar texto previo con nuevo bloque
        text = [text Text{nt}];
    end

    ST = 1;
    % loop principal: buscar polylines en el texto
    while ST ~= 0
        % si no es el último bloque, y el texto es corto, salimos (optimización)
        if nt ~= ntext-1
            if length(text) < buffer/10
                break;
            end
        end

        %% Buscar próxima POLYLINE o LWPOLYLINE
        ST_poly = strfind(text, 'POLYLINE');
        ST_lw   = strfind(text, 'LWPOLYLINE'); % versiones nuevas de acad
        fprintf ("ST_poly");
        ST_poly
        ST_lw
        if ~isempty(ST_lw)
            STpos = ST_lw(1);
        elseif ~isempty(ST_poly)
            STpos = ST_poly(1);
        else
            STpos = 0;
        end

        if STpos == 0
            text = ''; % no hay más polylines en este bloque
        else
            % recortamos desde la POLYLINE encontrada hasta el final
            text = text(STpos:end);
        end

        %% Buscar final de esa polyline: SEQEND o patrón de nueva versión
        STNF = strfind(text, sprintf('\n  0\n')); % patrón usado en versión nueva
        ST_seqend = strfind(text, 'SEQEND');

        % decidir final: si seqend no existe y STNF sí, usar STNF
        if isempty(ST_seqend) && ~isempty(STNF)
            % tomar primer STNF
            ST = STNF(1);
        elseif ~isempty(ST_seqend)
            ST = ST_seqend(1);
        else
            ST = 0;
        end

        if ST == 0
            textpolyline = text;
        else
            textpolyline = text(1:min(ST+1, length(text))); % substring
        end

        %% Determinar la capa en que está la polyline (buscar " 8\r" y el nombre)
        st = strfind(textpolyline, ' 8\n');
        capapol = '';
        if ~isempty(st)
            % recortar justo después de ' 8\r'
            sub = textpolyline(st(1)+3:end); % +3 saltamos " 8\r"
            % sscanf equivalente: extraer la primera palabra (nombre de capa)
            tokens = regexp(sub, '(\S+)', 'tokens');
            if ~isempty(tokens)
                capapol = tokens{1}{1};
            end
        end
        % fprintf('Encontrada una polyline en la capa %s\n', capapol);

        %% Comparar con listaCapas y procesar si coincide
        for capa = 1:nCapas
            if ~isempty(capapol) && strcmp(capapol, listaCapas{capa})
                % inicializar vector de nudos para esta polilinea
                nudosdxfdov = {}; % lista de vértices
                % buscar VERTEX o asumir LWPOLYLINE
                stv = strfind(textpolyline, 'VERTEX');
                if ~isempty(strfind(textpolyline,'LWPOLYLINE')) && isempty(stv)
                    % en LWPOLYLINE los vértices vienen en bloques "10", "20" (etc)
                    stv = 1; % activamos el procesamiento de vertices
                end

                if ~isempty(stv)
                    % recortamos desde el primer VERTEX encontrado (o inicio para LWPOLYLINE)
                    if isempty(strfind(textpolyline,'LWPOLYLINE'))
                        textpolyline2 = textpolyline(stv(1):end);
                    else
                        textpolyline2 = textpolyline;
                    end

                    % buscar ocurrencias del marcador de coordenada "10" (p.ej. newline + " 10\r")
                    pattern = sprintf('\n 10\n');
                    st_coord = strfind(textpolyline2, pattern);

                    % también intentar con solo " 10\n" por si CR/LF varía
                    if isempty(st_coord)
                        st_coord = strfind(textpolyline2, ' 10');
                    end

                    % procesar cada aparición (avanzando el texto)
                    pos = 1;
                    while ~isempty(st_coord)
                        % recortar desde la primera aparición
                        idx = st_coord(1);
                        % extraer substring empezando en idx
                        subcoord = textpolyline2(idx:end);

                        % EXTRAER COORDENADAS: buscamos los números siguientes en la línea
                        % Para robustez, usamos regexp para encontrar números con optional signo y decimales
                        if ndim == 3
                            % buscar tripletas: 10 x, 20 y, 30 z
                            % buscamos la primera aparición del patrón "10" y luego extraemos los números en orden
                            nums = regexp(subcoord, '10\D*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)\D*20\D*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)\D*30\D*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)','tokens','once');
                            if ~isempty(nums)
                                xver = str2double(nums{1});
                                yver = str2double(nums{2});
                                zver = str2double(nums{3});
                                nudosdxfdov{end+1} = [xver, yver, zver];
                            else
                                % intento más tolerante: capturar tres números cercanos
                                allnums = regexp(subcoord, '([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)','match');
                                if numel(allnums) >= 3
                                    xver = str2double(allnums{1});
                                    yver = str2double(allnums{2});
                                    zver = str2double(allnums{3});
                                    nudosdxfdov{end+1} = [xver, yver, zver];
                                end
                            end
                        else
                            % 2D: buscar 10 x, 20 y
                            nums = regexp(subcoord, '10\D*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)\D*20\D*([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)','tokens','once');
                            if ~isempty(nums)
                                xver = str2double(nums{1});
                                yver = str2double(nums{2});
                                nudosdxfdov{end+1} = [xver, yver];
                            else
                                allnums = regexp(subcoord, '([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)','match');
                                if numel(allnums) >= 2
                                    xver = str2double(allnums{1});
                                    yver = str2double(allnums{2});
                                    nudosdxfdov{end+1} = [xver, yver];
                                end
                            end
                        end

                        % avanzar el buffer para buscar la siguiente coordenada
                        if idx+1 <= length(textpolyline2)
                            textpolyline2 = textpolyline2(idx+1:end);
                        else
                            textpolyline2 = '';
                        end
                        st_coord = strfind(textpolyline2, pattern);
                        if isempty(st_coord)
                            st_coord = strfind(textpolyline2, ' 10');
                        end
                    end % while st_coord

                    % Si el primer y último nudo coinciden, eliminar el último (para evitar duplicados)
                    if ~isempty(nudosdxfdov)
                        firstV = nudosdxfdov{1};
                        lastV  = nudosdxfdov{end};
                        if isequal(firstV, lastV)
                            nudosdxfdov(end) = [];
                        end
                    end

                    % construir 'dov' similar al original: {nudos, indices}
                    if ~isempty(nudosdxfdov)
                        % convertir cell list de vértices a matriz (Nx2 o Nx3)
                        V = vertcat(nudosdxfdov{:});
                        indices = { (1:size(V,1)) };
                        dov = { V, indices };
                        % TODO: llamar a areas() y comprobar orientación - aquí se asume que existe función 'areas'
                        try
                            a = areas(dov); % espera que areas devuelva un escalar
                        catch
                            a = 0; % si no existe, evitamos fallo (debes implementar areas)
                        end
                        % si area negativa, invertir orden de indices (como en Maple)
                        if a < 0
                            % invertir orden
                            ni = (size(V,1)- (1:size(V,1)) + 1);
                            dov = { V, { ni } };
                        end
                    else
                        dov = [];
                    end
                else
                    dov = [];
                end % if vertices exist

                % Si tenemos una dov válida, añadirla al dxfarco de la capa correspondiente
                if ~isempty(dov)
                    if isempty(dxfarco{capa})
                        dxfarco{capa} = {dov}; % lista inicial
                    else
                        % 'unir' arcos con tolerancia usando función externa uniarco
                        try
                            % en Maple: dxfarco[capa] := eval(unionarco(dov,dxfarco[capa],tol))
                            % Aquí llamamos a uniarco(dov, existing, tol) y esperamos una estructura similar
                            existing = dxfarco{capa};
                            nueva = uniarco(dov, existing, tol); % TODO: implementar uniarco en MATLAB
                            dxfarco{capa} = nueva;
                        catch ME
                            warning('Fallo al unir arcos: %s', ME.message);
                            % si falla, simplemente añadimos al final
                            dxfarco{capa}{end+1} = dov;
                        end
                    end
                end % if dov not empty

            end % if capapol == listaCapas{capa}
        end % for capa

        % terminar while ST loop: si no hay más 'text' rompemos
        if isempty(text)
            ST = 0;
        else
            % si hemos recortado la polyline, dejamos ST=1 para buscar la siguiente en el mismo texto
            if isempty(strfind(text, 'POLYLINE')) && isempty(strfind(text,'LWPOLYLINE'))
                ST = 0;
            else
                ST = 1;
            end
        end

    end % while ST
end % for nt

%% Resultado
% En Maple la función devuelve dxfarco. En MATLAB podemos mostrarlo o guardarlo.
assignin('base','dxfarco', dxfarco); % opcional: dejar la variable en workspace
fprintf('Procesado finalizado. Resultado en variable ''dxfarco'' del workspace.\n');

end
