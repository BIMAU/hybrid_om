function [mn, mx, ign, fld] = global_bounds(data, field, mn, mx)
    [R,N] = size(data);
    if nargin < 3
        mn = Inf;
        mx = -Inf;
    end

    ign = []; % ignore these runs (unavailabl)
    fld = []; % mark these runs as failed

    for j = 1:N
        for i = 1:R
            if isempty(data{i,j})
                fprintf('unavailable run: %d %d \n', i, j);
                ign = [ign;i,j];
            else
                series = data{i,j}.(field);
                if series(end) == 0
                    fprintf('failed run: %d %d \n', i, j);
                    fld = [fld;i,j];
                    keyboard
                else
                    mn = min(mn, min(series));
                    mx = max(mx, max(series));
                end
            end
        end
    end
end