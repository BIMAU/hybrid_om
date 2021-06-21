classdef Experiment < handle

% Experiment class that creates hybrid DMD/ESN setups and performs
% training and prediction for many training data sets and many
% realizations of the random ESN operators W and Win. It stores a
% collection of ESN hyperparameters that we like to experiment with.

    properties (Access = public)

        shifts    = 5;   % shifts in training_range
        reps      = 3;   % repetitions per shift
        max_preds = 100; % prediction barrier (in samples)

        testing_on = true; % if true/false we run the prediction with/without
                           % generating errors w.r.t. the truth.
        esn_on     = true; % enable/disable ESN
        model_on   = true; % enable/disable physics based model

        store_state = 'all';  % which state to store: 'all', 'final'
    end

    properties (Access = private)
        tr_data; % training data struct
        model;   % model object
        
        hyp;   % hyperparameter collection
        name;  % experiment name
        
        % default serial setting
        pid   = 0; 
        procs = 1;

        % All hyperparam settings
        hyp_range;

        % Total number of different hyperparam settings.
        num_hyp_settings;

        % Experiment descriptor for output file
        file_descr;

        exp_id  = {}; % experiment identifiers
        exp_ind = []; % experiment identifier index

        range2str = @ (range) ['_', num2str(range(1)), ...
                            '-', num2str(range(end)), '_'];
        
        % data storage for all runs
        predictions; % stores all predictions
        truths;      % stores all truths
        errors;      % stores the errors
        ESN_states;  % stores snapshots of the ESN state X
        
        % Number of predicted time steps that are within the error limit.
        num_predicted;
    end

    methods (Access = public)

        function self = Experiment(tr_data, model, pid, procs)
        % constructor
        %
        % tr_data:  training data struct
        % pid:      process id
        % procs:    total number of processes
            
            self.tr_data = tr_data;
            self.model   = model;
            
            switch nargin
              case 3
                self.pid = pid;
              case 4
                self.pid   = pid;
                self.procs = procs;
            end
            
            self.set_all_hyp_defaults();
        end

        function run(self)
            self.create_descriptors();
            self.create_hyp_range();
            self.create_storage();
        end

        function set_default_hyp(self, id, value)
        % adjust the default value of a hyperparameter
            self.hyp.(id).default = value;
        end

        function add_experiment(self, id, range)
        % Add an experiment: give a hyperparameter id and the range of values
        % of interest.

            self.exp_id = {self.exp_id{:}, id}; % append experiment id
            self.hyp.(id).range = range;        % set range

            % adjust hyperparam description
            str = self.hyp.(id).descr;
            self.hyp.(id).descr = [str(1:2), self.range2str(range)];
        end
    end

    methods (Access = private)

        [] = set_all_hyp_defaults(self);
        [] = create_descriptors(self);
        [] = create_hyp_range(self);
        [] = create_storage(self);
        
        [inds] = my_indices(self, pid, procs, Ni);
    end
end