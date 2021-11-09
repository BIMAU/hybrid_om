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

        [nums, mdat, preds, truths] = plot_experiment(self, ignore_nans, flip_axes);
        [nums, mdat, preds, truths, s] = plot_qg_transient(self, opts);
        [stats] = get_qg_statistics(self, qg, data, opts);
        [] = movie_qg(self, data, opts);
    end

    methods (Access = private)
        % gather data from output .mat file
        [errs, nums, pids, ...
         metadata, predictions, ...
         truths] = gather_data(self, varargin);

        [description] = create_description(self, mdat);
        
        [f] = my_boxplot(self, varargin);
        
        function [out] = compute_qg_enstrophy(self, field)
        % assume QG ordering
            nun = 2;    
            out = sum(field(1:nun:end).^2);    
        end
        
        function [out] = compute_qg_energy(self, field)
        % assume QG ordering
            nun = 2;    
            out = sum(field(1:nun:end).*field(2:nun:end));
        end
    end
end