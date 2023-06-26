function [h, h_orig] = my_plot(x,y,varargin)
    h_orig = plot(x, y, varargin{:});
    hold on 
    h = plot(NaN, NaN, varargin{:}, 'LineWidth', 2.0);
end