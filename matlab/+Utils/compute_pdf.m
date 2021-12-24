function [hc, edg] = compute_pdf(series, bins, varargin)
    [hc, edg] = histcounts(series, bins, 'normalization', 'pdf');
    edg = (edg(1:end-1)+edg(2:end))/2;
end