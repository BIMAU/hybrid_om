function [p] = plotpdf(series, bins, varargin)
    [hc, edg] = Utils.compute_pdf(series, bins, 'normalization', 'pdf');
    p = plot(hc, edg, varargin{:});
end