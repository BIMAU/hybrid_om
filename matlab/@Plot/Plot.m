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
    end

    methods (Access = public)

        function self = Plot(dir)
            self.dir = dir;
        end

        [nums, mdat, preds, truths, f] = plot_experiment(self, ignore_nans, flip_axes);
        [nums, mdat, preds, truths, s] = get_qg_transient_data(self, opts);
        [] = movie_qg(self, data, opts);
        % gather data from output .mat file
        [errs, nums, pids, ...
         metadata, predictions, ...
         truths] = gather_data(self, varargin);

        [description] = create_description(self, mdat);
        [f, Pm, Pv, g] = plot_qg_mean_spectrum(self, qg, states, opts, varargin);
        [labels, Nvalues, xlab, exp_ind, I, opts_str] = unpack_metadata(self, mdat);
    end

    methods (Access = private)

        [f] = my_boxplot(self, varargin);

    end
end