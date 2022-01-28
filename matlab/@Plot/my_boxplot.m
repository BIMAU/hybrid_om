function [f, h] = my_boxplot(self, varargin)

    switch nargin
      case 2
        array    = varargin{1};
        colors   = {'k', 'k'};
        style    = self.style;
        msize    = self.msize;
        x_index  = 1:size(array,2);

      case 3
        array    = varargin{1};
        colors   = varargin{2};
        style    = self.style;
        msize    = self.msize;
        x_index  = 1:size(array,2);

      case 4
        array    = varargin{1};
        colors   = varargin{2};
        style    = varargin{3};
        msize    = self.msize;
        x_index  = 1:size(array,2);

      case 5
        array    = varargin{1};
        colors   = varargin{2};
        style    = varargin{3};
        msize    = varargin{4};
        x_index  = 1:size(array,2);

      case 6
        array    = varargin{1};
        colors   = varargin{2};
        style    = varargin{3};
        msize    = varargin{4};
        x_index  = varargin{5};

      otherwise
        error('Unexpected input');
    end

    alpha     = 0.2;
    ylimMax   = 0.0;

    plot_mean    = self.plot_mean;
    plot_scatter = self.plot_scatter;
    plot_boxplot = self.plot_boxplot;
    plot_connections = self.plot_connections;

    Q = zeros(numel(x_index), 3);
    h = hggroup;

    for idx = x_index
        arr = array(:,idx);
        % scatterplot of all data

        if plot_scatter
            scatter(repmat(idx,1,size(array,1)), arr, ...
                    '+', 'markeredgealpha', alpha, ...
                    'sizedata', 10, ...
                    'markerfacecolor', colors{1}, ...
                    'markeredgecolor', colors{1}, ...
                    'markerfacealpha', alpha, ...
                    'linewidth', 0.01); hold on
        end

        % plot median
        q1 = quantile(arr,0.25);
        q2 = quantile(arr,0.5);
        q3 = quantile(arr,0.75);
        Q(idx, :) = [q1,q2,q3];

        if plot_boxplot
            f = plot(idx, q2, style{1}, 'markersize', msize{1},  ...
                     'linewidth',2, 'color', colors{1}, 'Parent', h);
            hold on

            % plot quantiles
            plot(repmat(idx,1,2), ...
                 [q1, q3], ...
                 style{2}, 'markersize', msize{2},  ...
                 'linewidth',2, 'color', colors{1}, 'Parent', h);
        end

        if plot_mean
            mn = mean(arr(~isnan(arr)));
            st = std(arr(~isnan(arr)));
            plot(idx, mn, ...
                 '*', 'markersize', 8, 'color', colors{2}, 'Parent', h);
        end

        ylimMax = max(ylimMax, 1.05*quantile(arr, 0.75));
    end

    if plot_connections
        f = plot(x_index, Q(x_index,:), style{3}, 'markersize', msize{2}, ...
                 'color', colors{2}, 'Parent', h);
        uistack(f, 'bottom');
        f = f(1);
    end

    xlim([min(x_index)-0.5, max(x_index)+0.5]);
    xticks([x_index]);

    if ylimMax > 0
        % ylim([0,ylimMax]);
    end

    hold off
end