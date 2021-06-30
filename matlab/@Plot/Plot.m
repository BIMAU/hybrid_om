classdef Plot < handle
% class that handles (box)plotting of the grid search experiment
% dir: it requires a directory dir

    properties (Access = public)
        
        % location of experiment results
        dir;
        
        % flag to add hyperparam settings in plot
        description = false;
        
    end

    methods (Access = public)

        function self = Plot(dir)
            self.dir = dir;
        end

        [] = plot_experiment(self);
    end

    methods (Access = private)
        % gather data from output .mat file
        [errs, nums, pids, ...
         metadata, predictions, ...
         truths] = gather_data(self, varargin);

        [description] = create_description(self, mdat);
        
        [f] = my_boxplot(self, varargin);
    end
end