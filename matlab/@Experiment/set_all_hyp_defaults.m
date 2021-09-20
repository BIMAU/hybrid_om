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

    name = 'FilterCutoff';
    self.hyp.(name).range   = [1e-1];
    self.hyp.(name).descr   = ['FC', self.range2str(self.hyp.(name).range)];
    self.hyp.(name).default = 1e-1;

    name = 'SVDWaveletReduction';
    self.hyp.(name).range   = [1,2,4,8];
    self.hyp.(name).descr   = ['WB', self.range2str(self.hyp.(name).range)];
    self.hyp.(name).default = 1;

    name = 'SVDWaveletBlockSize';
    self.hyp.(name).range   = [2,4,8];
    self.hyp.(name).descr   = ['WB', self.range2str(self.hyp.(name).range)];
    self.hyp.(name).default = 8;

    name = 'TimeDelay';
    self.hyp.(name).range   = [0,1,4];
    self.hyp.(name).descr   = ['TD', self.range2str(self.hyp.(name).range)];
    self.hyp.(name).default = 0;

    name = 'TimeDelayShift';
    self.hyp.(name).range   = [10,100,400];
    self.hyp.(name).descr   = ['TD', self.range2str(self.hyp.(name).range)];
    self.hyp.(name).default = 100;

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

    name = 'RegressionSolver';
    self.hyp.(name).opts    = {'pinv', 'TikhonovNormalEquations', 'TikhonovTSVD'};
    self.hyp.(name).range   = [1, 2, 3];
    self.hyp.(name).descr   = ['RS', self.range2str(self.hyp.(name).range)];
    self.hyp.(name).default = 3;

    name = 'ScalingType';
    self.hyp.(name).opts    = {'none', 'minMax1', 'minMax2', 'minMaxAll', 'standardize'};
    self.hyp.(name).range   = [1:5];
    self.hyp.(name).descr   = ['ST', self.range2str(self.hyp.(name).range)];
    self.hyp.(name).default = 5;

    name = 'InputMatrixType';
    self.hyp.(name).opts    = ...
        {'sparse', 'sparseOnes', ...
         'balancedSparse', 'full', 'identity'};
    self.hyp.(name).range   = [1, 2];
    self.hyp.(name).descr   = ['WI', self.range2str(self.hyp.(name).range)];
    self.hyp.(name).default = 3;

    name = 'ModelConfig';
    self.hyp.(name).opts = ...
        {'model_only', 'esn_only', 'dmd_only', ...
         'hybrid_esn', 'hybrid_dmd', 'corr_only', ...
         'esn_plus_dmd', 'hybrid_esn_dmd'};
    self.hyp.(name).range   = [3];
    self.hyp.(name).descr   = ['MC', self.range2str(self.hyp.(name).range)];
    self.hyp.(name).default = 3;

    name = 'ScaleSeparation';
    self.hyp.(name).opts = ...
        {'none', 'wavelet', 'dmd', 'pod'};
    self.hyp.(name).range   = [1:4];
    self.hyp.(name).descr   = ['MC', self.range2str(self.hyp.(name).range)];
    self.hyp.(name).default = 1;
end