classdef Experiment < handle

% Experiment class creates ESN networks and performs training and
% prediction for many training data sets and many realizations of the
% random ESN operators W and Win. It stores a collection of ESN hyper
% parameters that we like to experiment with.

    properties

        hyp; % hyper parameter collection
        
    end

    methods

        function self = Experiment()

            self.set_default_hyp();

        end       
        
        function [] = set_default_hyp(self)
            self.hyp = struct();
            
            % hyp helper function: convert numeric range to formatted string
            range2str = @ (range) ['_', num2str(range(1)), '-', num2str(range(end)), '_'];
            
            % numeric options
            name = 'ReservoirSize';
            self.hyp.(name).range   = [3000];
            self.hyp.(name).descr   = ['NR', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 8000;
            
            name = 'BlockSize';
            self.hyp.(name).range   = [1,16];
            self.hyp.(name).descr   = ['BS', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 8;

            name = 'TrainingSamples';
            self.hyp.(name).range   = [1000,2000,3000,4000,5000,6000,7000];
            self.hyp.(name).descr   = ['SP', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 4000;

            name = 'ReductionFactor';
            self.hyp.(name).range   = [16, 32];
            self.hyp.(name).descr   = ['RF', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 1;

            name = 'Alpha';
            self.hyp.(name).range   = [0.2,1.0];
            self.hyp.(name).descr   = ['AP', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 0.2;
            
            name = 'RhoMax';
            self.hyp.(name).range   = [0.3];
            self.hyp.(name).descr   = ['RH', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 0.3;
            
            name = 'FeedthroughAmp';
            self.hyp.(name).range   = [0.1,0.7,1.0];
            self.hyp.(name).descr   = ['FA', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 1.0;
            
            name = 'ReservoirAmp';
            self.hyp.(name).range   = [0.1,1.0,10];
            self.hyp.(name).descr   = ['RA', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 1.0;

            name = 'InAmplitude';
            self.hyp.(name).range   = [1.0,10.0];
            self.hyp.(name).descr   = ['IA', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 1.0;

            name = 'AverageDegree';
            self.hyp.(name).range   = [5,10,20,30];
            self.hyp.(name).descr   = ['AD', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 10;

            name = 'Lambda';
            self.hyp.(name).range   = [1e-8, 1e-6, 1e-4, 1e-1];
            self.hyp.(name).descr   = ['LB', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 1e-1;

            % string based options
            name = 'SquaredStates';
            self.hyp.(name).opts    = {'disabled', 'append', 'even'};
            self.hyp.(name).range   = [1, 3];
            self.hyp.(name).descr   = ['SS', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 3;

            name = 'ReservoirStateInit';
            self.hyp.(name).opts    = {'zero', 'random'};
            self.hyp.(name).range   = [1, 2];
            self.hyp.(name).descr   = ['RI', range2str(self.hyp.(name).range)];
            self.hyp.(name).default = 2;
            
        end

    end
end