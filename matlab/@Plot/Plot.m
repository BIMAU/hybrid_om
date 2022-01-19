classdef Plot < handle
% class that handles (box)plotting of the grid search experiment
% dir: it requires a directory dir

    properties (Access = public)

        % location of experiment results
        dir;

        % enable or disable legend
        legend = true;

        % flag to add hyperparam settings in plot
        description = false;

        % enable/disable title
        show_title = true;

        % scales the amount of samples
        scaling = 1.0;

        % overwrites ylabel prescribed in data
        ylab = {};

        % overwrites xlabel prescribed in data
        xlab = {};

        % enable/disable grid
        grid = true;

        % plot the mean together with the boxplot
        plot_mean = true;

        % show the whole dataset in the background
        plot_scatter = true;

        % show a boxplot
        plot_boxplot = true;
    end

    methods (Access = public)

        function self = Plot(dir)
            self.dir = dir;
        end

        [nums, mdat, preds, truths, f] = plot_experiment(self, ignore_nans, flip_axes);
        [] = movie_qg(self, data, opts);

        [f, Pm, Pv, g] = plot_qg_mean_spectrum(self, qg, states, opts, varargin);
    end

    methods (Access = private)

        [f] = my_boxplot(self, varargin);

    end
end