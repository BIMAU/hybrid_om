function [pdf, cnt] = compute_pdf(series, bins, varargin)
    fprintf('computing pdf, size series: %d\n', numel(series));
    [pdf, edg] = histcounts(series, bins, varargin{:});
    cnt = (edg(1:end-1)+edg(2:end))/2;
end