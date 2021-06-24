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

        store_state = 'all'; % which state to store: 'all', 'final'

        dimension = '1D'; % problem dimension: '1D' or '2D'

        % Modes object used for scale separation and order reduction
        modes;
    end

    properties (Access = private)
        data;   % training data object
        model;   % model object

        hyp;   % hyperparameter collection
        name;  % experiment name

        % default serial setting
        pid   = 0;
        procs = 1;

        % hyperparam identifier strings
        hyp_ids;

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

        id2ind  = @ (hyp_ids, str) find(strcmp(hyp_ids, str));

        % data storage for all runs
        predictions; % stores all predictions
        truths;      % stores all truths
        errors;      % stores the errors
        ESN_states;  % stores snapshots of the ESN state X

        % Number of predicted time steps that are within the error limit.
        num_predicted;

        % Number of training samples
        tr_samples;

        % Range of the training samples
        train_range;

        % Range of the test samples
        test_range;
    end

    methods (Access = public)

        function self = Experiment(data, pid, procs)
        % constructor
        %
        % data:     training data object
        % pid:      process id
        % procs:    total number of processes

            self.data      = data;
            self.model     = data.model_imp;
            self.dimension = data.dimension;
            
            switch nargin
              case 3
                self.pid = pid;
              case 4
                self.pid   = pid;
                self.procs = procs;
            end

            % Seed the rng with time and pid
            now = clock;
            rng(round(100*self.pid*sqrt(now(end))));

            self.print('\n')
            self.print('Experiment instance\n')
            self.print(' \x251C\x2500 procs  = %d \n', self.procs)
            self.print(' \x2514\x2500 pid    = %d \n', self.pid)

            self.set_all_hyp_defaults();
        end

        function run(self)
            self.create_descriptors();
            self.create_hyp_range();
            self.create_storage();

            for j = 1:self.num_hyp_settings
                self.print_hyperparams(j);
                [esn_pars, mod_pars] = self.distribute_params(j);
                self.modes = Modes('wavelet', mod_pars);
                
                self.print('transform input/output data with wavelet modes\n');
                % ?? self.data.X   = self.modes.V' * self.data.X;
                % ?? self.data.Phi = self.modes.V' * self.data.Phi;                
               
            end
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

        [] = print(self, varargin);

        [] = print_hyperparams(self, exp_idx);
        [esn_pars, mod_pars] = distribute_params(self, exp_idx);
    end
end