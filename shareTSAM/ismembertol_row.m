function [idxFilasComunesA, idxFilasComunesB] = ismembertol_rows(A, B, tol)
%ISMEMBERTOL_ROWS  Compara filas de A y B con tolerancia.
%
%   Lia = ismembertol_rows(A, B, tol)
%   devuelve un vector lógico Lia tal que Lia(i) = true si
%   existe alguna fila en B que esté a una distancia < tol
%   de la fila A(i,:).
%
%   [Lia, Locb] = ismembertol_rows(A, B, tol)
%   también devuelve Locb(i) = índice de la fila coincidente en B
%   o 0 si no hay coincidencia.
%
%   Ejemplo:
%       A = [1 2; 3 4; 5 6];
%       B = [3.00001 4.00001; 1.000001 2.000001];
%       [Lia, Locb] = ismembertol_rows(A,B,1e-4);

    if nargin < 3
        tol = 1e-6;
    end

    % Verificaciones básicas
    if size(A,2) ~= size(B,2)
        error('A y B deben tener el mismo número de columnas.');
    end

    nA = size(A,1);
    nB = size(B,1);
    idxFilasComunesA = zeros(nA,1);
    idxFilasComunesB = zeros(nA,1);

    % --- Comparación fila a fila ---
    for i = 1:nA
        ai = A(i,:);  % fila actual de A
        % Calcula las diferencias absolutas respecto a todas las filas de B
        diff = abs(B - ai);  % [nB x nCols]
        % Calcula la norma fila a fila
        dist = sqrt(sum(diff.^2, 2));
        % Busca coincidencias dentro de la tolerancia
        [minDist, idx] = min(dist);
        if minDist < tol
            idxFilasComunesA(i) = i;
            idxFilasComunesB(i) = idx;
        end
    end

end
