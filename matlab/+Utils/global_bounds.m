function [mn, mx] = global_bounds(data, field)
    [R,N] = size(data);
    mn = Inf;
    mx = -Inf;
    for j = 1:N
        for i = 1:R
            series = data{i,j}.(field);
            mn = min(mn, min(series));
            mx = max(mx, max(series));
        end
    end
end