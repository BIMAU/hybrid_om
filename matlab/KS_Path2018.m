function [dir] = KS_Path2018(varargin)

    [pid, procs] = Utils.input_handling(nargin, varargin);

    % epsilon
    epsilon = 1;

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

    % add experiment identification
    expObj.ident = 'Pathak2018repl';

    % experimental setup
    expObj.shifts = 5;
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
    expObj.set_default_hyp('ReservoirSize', 128);
    expObj.set_default_hyp('Lambda', 1e-6);
    expObj.set_default_hyp('TimeDelay', 0);
    expObj.set_default_hyp('TimeDelayShift', 100);

    % Scaling of the data:
    % (1) none
    % (2) minMax1
    % (3) minMax2
    % (4) minMaxAll
    % (5) standardize
    expObj.set_default_hyp('ScalingType', 3);

    % Scale separation (modes) options:
    % (1) none
    % (2) wavelet
    % (3) dmd
    % (4) pod
    expObj.set_default_hyp('ScaleSeparation',1);

    % Model configuration options:
    % (1) model_only
    % (2) esn_only
    % (3) dmd_only
    % (4) hybrid_esn
    % (5) hybrid_dmd
    % (6) corr_only
    % (7) esn_plus_dmd
    % (8) hybrid_esn_dmd
    expObj.add_experiment('ModelConfig', [1,2,4,5,6,8]);

    expObj.add_experiment('ReservoirSize', [200,400,800,1600,3200,6400]);

    % run experiments
    dir = expObj.run();
end