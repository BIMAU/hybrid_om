function [hc, cnt] = compute_pdf(series, bins, varargin)
    [hc, edg] = histcounts(series, bins, varargin{:});
    cnt = (edg(1:end-1)+edg(2:end))/2;
end