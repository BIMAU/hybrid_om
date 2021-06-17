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

        function [] = set_all_hyp_defaults(self)
            self.hyp = struct();

            % numeric options
            name = 'ReservoirSize';
            self.hyp.(name).range   = [3000];
            self.hyp.(name).descr   = ['NR', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 8000;

            name = 'BlockSize';
            self.hyp.(name).range   = [1,16];
            self.hyp.(name).descr   = ['BS', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 8;

            name = 'TrainingSamples';
            self.hyp.(name).range   = [1000,2000,3000,4000,5000,6000,7000];
            self.hyp.(name).descr   = ['SP', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 4000;

            name = 'ReductionFactor';
            self.hyp.(name).range   = [16, 32];
            self.hyp.(name).descr   = ['RF', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 1;

            name = 'Alpha';
            self.hyp.(name).range   = [0.2,1.0];
            self.hyp.(name).descr   = ['AP', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 0.2;

            name = 'RhoMax';
            self.hyp.(name).range   = [0.3];
            self.hyp.(name).descr   = ['RH', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 0.3;

            name = 'FeedthroughAmp';
            self.hyp.(name).range   = [0.1,0.7,1.0];
            self.hyp.(name).descr   = ['FA', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 1.0;

            name = 'ReservoirAmp';
            self.hyp.(name).range   = [0.1,1.0,10];
            self.hyp.(name).descr   = ['RA', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 1.0;

            name = 'InAmplitude';
            self.hyp.(name).range   = [1.0,10.0];
            self.hyp.(name).descr   = ['IA', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 1.0;

            name = 'AverageDegree';
            self.hyp.(name).range   = [5,10,20,30];
            self.hyp.(name).descr   = ['AD', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 10;

            name = 'Lambda';
            self.hyp.(name).range   = [1e-8, 1e-6, 1e-4, 1e-1];
            self.hyp.(name).descr   = ['LB', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 1e-1;

            % string based options
            name = 'SquaredStates';
            self.hyp.(name).opts    = {'disabled', 'append', 'even'};
            self.hyp.(name).range   = [1, 3];
            self.hyp.(name).descr   = ['SS', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 3;

            name = 'ReservoirStateInit';
            self.hyp.(name).opts    = {'zero', 'random'};
            self.hyp.(name).range   = [1, 2];
            self.hyp.(name).descr   = ['RI', self.range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 2;

        end

    end
end