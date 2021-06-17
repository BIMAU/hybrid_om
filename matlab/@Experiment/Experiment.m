classdef Experiment < handle

% Experiment class that creates hybrid DMD/ESN setups and performs
% training and prediction for many training data sets and many
% realizations of the random ESN operators W and Win. It stores a
% collection of ESN hyperparameters that we like to experiment with.

    properties
        hyp;     % hyperparameter collection
        hyp_ids; % field names

        exp_id = {}; % standard experiment

        shifts = 1;      % shifts in training_range
        reps   = 1;      % repetitions per shift
        max_preds = 100; % prediction barrier (in samples)

        testing_on = true; % if true/false we run the prediction with/without
                           % generating errors w.r.t. the truth.
        esn_on     = true; % enable/disable ESN
        model_on   = true; % enable/disable physics based model
        
        
        store_state = 'all';  % which state to store: 'all', 'final'

        % bounds of numeric range to string
        range2str = @ (range) ['_', num2str(range(1)), '-', num2str(range(end)), '_'];
    end

    methods

        function self = Experiment()
        % constructor            
            self.set_all_hyp_defaults();
        end
        
        function initialize_experiment()
        end
        
        function set_default_hyp(self, id, value)
        % adjust the default value for a hyperparameter
            self.hyp.(id).default = value;
        end
        
        function add_experiment(self, id, range)
        % Add an experiment: give a hyperparameter id and the range of values
        % of interest.
            
            self.exp_id = {self.exp_id{:}, id}; % append experiment id
            self.hyp.(id).range = range;     % set range
            
            % adjust hyperparam description
            str = self.hyp.(id).descr; 
            self.hyp.(id).descr = [str(1:2), self.range2str(range)];            
        end
    end
 
    methods (Access = private)
        [] = set_all_hyp_defaults(self);        
    end
end