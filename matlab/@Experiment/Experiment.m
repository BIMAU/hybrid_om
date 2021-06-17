classdef Experiment < handle

% Experiment class that creates hybrid DMD/ESN setups and performs
% training and prediction for many training data sets and many
% realizations of the random ESN operators W and Win. It stores a
% collection of ESN hyperparameters that we like to experiment with.

    properties (Access = public)
        hyp;     % hyperparameter collection
        name;    % experiment name

        shifts = 1;      % shifts in training_range
        reps   = 1;      % repetitions per shift
        max_preds = 100; % prediction barrier (in samples)

        testing_on = true; % if true/false we run the prediction with/without
                           % generating errors w.r.t. the truth.
        esn_on     = true; % enable/disable ESN
        model_on   = true; % enable/disable physics based model

        store_state = 'all';  % which state to store: 'all', 'final'
    end

    properties (Access = private)
        hyp_ids;

        exp_id = {};

        range2str = @ (range) ['_', num2str(range(1)), '-', num2str(range(end)), '_'];

    end

    methods (Access = public)

        function self = Experiment()
        % constructor
            self.set_all_hyp_defaults();
        end

        function run(self)
            self.initialize();
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
        function initialize(self)
            
            id2ind = @ (str) find(strcmp(self.hyp_ids, str));
                    
            self.hyp_ids = fieldnames(self.hyp);
            exp_ind = []; file_descr = [];

            for i = 1:numel(self.exp_id)
                exp_ind{i}    = id2ind(self.exp_id{i});
                file_descr{i} = self.hyp.(self.exp_id{i}).descr;
            end

            assert(~isempty(exp_ind));

            self.name = [[file_descr{:}], ...
                         'ESN', num2str(self.esn_on), '_', ...
                         'MDL', num2str(self.model_on)];
            % ....... TODO
        end

        [] = set_all_hyp_defaults(self);
    end
end