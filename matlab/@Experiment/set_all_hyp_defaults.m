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

    name = 'InputMatrixType';
    self.hyp.(name).opts    = {'sparse', 'balancedSparse'};
    self.hyp.(name).range   = [1, 2];
    self.hyp.(name).descr   = ['WI', self.range2str(self.hyp.(name).range)];
    self.hyp.(name).default = 2;
end