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

    alpha     = 0.8;
    ylimMax   = 0.0;

    plot_mean    = self.plot_mean;
    plot_scatter = self.plot_scatter;
    plot_boxplot = self.plot_boxplot;
    plot_connections = self.plot_connections;
    plot_q_conn = self.plot_q_conn;

    assert(numel(plot_q_conn) == 3);
    assert(sum(plot_q_conn) >= 1);
    assert(sum(plot_q_conn) <= 3);
    Q = zeros(numel(x_index), sum(plot_q_conn));
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
                    'linewidth', 0.1, 'Parent', h);
            hold on
        end

        % plot median
        q(1) = quantile(arr,0.25);
        q(2) = quantile(arr,0.5);
        q(3) = quantile(arr,0.75);

        q_arr = [];
        for i = 1:numel(plot_q_conn)
            if plot_q_conn(i) == 1
                q_arr = [q_arr, q(i)];
            end
        end
        Q(idx, :) = q_arr;

        if plot_boxplot
            f = plot(idx, q(2), style{1}, 'markersize', msize{1},  ...
                     'linewidth',2, 'color', colors{1}, 'Parent', h);
            hold on

            % plot quantiles
            plot(repmat(idx,1,2), ...
                 [q(1), q(3)], ...
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
        f = [];
        for j = 1:size(Q,2)
            if numel(style{3}) > 1
                st = style{3}{j};
            else
                st = style{3};
            end
            f(j) = plot(x_index, Q(x_index,j), st, 'markersize', msize{2}, ...
                        'color', colors{2}, 'Parent', h);
            uistack(f, 'bottom');
        end
        if numel(f) > 1
            f = f(2);
        end
    end

    xlim([min(x_index)-0.5, max(x_index)+0.5]);
    xticks([x_index]);

    if ylimMax > 0
        % ylim([0,ylimMax]);
    end

    hold off
end