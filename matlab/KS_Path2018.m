function [dir] = KS_Path2018(varargin)
    
    [pid, procs] = Utils.input_handling(nargin, varargin);

    % epsilon
    epsilon = 1.0;

    % create and initialize two KS models
    L      = 35;
    N      = 64;
    ks_prf = KSmodel(L, N);
    ks_imp = KSmodel(L, N);
    ks_imp.epsilon = epsilon;
    ks_prf.initialize();
    ks_imp.initialize();

    % create data generator for the two models
    dgen = DataGen(ks_prf, ks_imp);
    dgen.dimension = '1D';

    % generate perfect model transient
    dgen.trunc = 30; % truncate period
    dgen.T = 6000 + dgen.trunc; % total time
    dgen.dt_prf = 0.25; % perfect model time step
    dgen.generate_prf_transient();

    % generate imperfect model predictions
    % imperfect model time step (should be an integer multiple of dt_prf)
    dgen.dt_imp = dgen.dt_prf;
    dgen.generate_imp_predictions();

    % create experiment class
    expObj = Experiment(dgen, pid, procs);
    expObj.shifts = 100;
    expObj.reps = 1;
    expObj.store_state = 'final';
    expObj.nrmse_windowsize = 50;
    expObj.err_tol = 0.5;
    expObj.max_preds = round(200 / dgen.dt_imp);

    % adjust hyperparam defaults
    expObj.set_default_hyp('Alpha', 1);
    expObj.set_default_hyp('TrainingSamples', 20000);
    expObj.set_default_hyp('AverageDegree', 3);
    expObj.set_default_hyp('RhoMax', 0.4);
    expObj.set_default_hyp('BlockSize', 1);
    expObj.set_default_hyp('InAmplitude', 1);
    expObj.set_default_hyp('SVDWaveletBlockSize', 1);
    expObj.set_default_hyp('SVDWaveletReduction', 1);
    expObj.set_default_hyp('ReservoirSize', 1000);
    expObj.set_default_hyp('Lambda', 1e-6);

    % set experiments
    expObj.add_experiment('ReservoirSize', [200,400,800,1600,3200,6400]);
    expObj.add_experiment('ModelConfig', [1,2,3]);

    % run experiments
    dir = expObj.run();
    
end