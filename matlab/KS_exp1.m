function [dir] = KS_exp1(varargin)
    
    switch nargin
      case 0
        pid      = 0;
        procs    = 1;
      case 2
        pid     = Utils.arg_to_value(varargin{1});
        procs   = Utils.arg_to_value(varargin{2});
      otherwise
        error('Unexpected input');
    end
    
    st = dbstack;
    fprintf('%s: pid %d  procs %d \n', st.name, pid, procs)

    % create and initialize two KS models
    L      = 35;
    N_prf  = 128;
    N_imp  = 64;
    ks_prf = KSmodel(L, N_prf);
    ks_imp = KSmodel(L, N_imp);

    ks_prf.initialize();
    ks_imp.initialize();

    % create data generator for the two models
    dgen = DataGen(ks_prf, ks_imp);

    % the grids are different so grid transfers are necessary
    dgen.dimension = '1D';
    dgen.build_grid_transfers('periodic');

    % initial state
    dgen.x_init_prf = zeros(N_prf, 1);
    dgen.x_init_prf(1) = 1;
    
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
    expObj.shifts = 50;
    expObj.reps   = 1;
    expObj.store_state = 'final';
    expObj.nrmse_windowsize = 50;
    expObj.err_tol = 0.5;
    expObj.max_preds = round(200 / dgen.dt_imp);

    % adjust hyperparam defaults
    expObj.set_default_hyp('Alpha', 1);
    expObj.set_default_hyp('TrainingSamples', 20000);
    expObj.set_default_hyp('AverageDegree', 3);
    expObj.set_default_hyp('RhoMax', 0.4);
    expObj.set_default_hyp('InputMatrixType', 1);
    expObj.set_default_hyp('InAmplitude', 1);
    expObj.set_default_hyp('WaveletBlockSize', 64);
    expObj.set_default_hyp('WaveletReduction', 1);
    expObj.set_default_hyp('ReservoirSize', 2000);
    
    % set experiments
    expObj.add_experiment('WaveletReduction', [1,2,4,8,16,32]);
    expObj.add_experiment('TrainingSamples', [2e4, 5e3]);

    % run experiments
    dir = expObj.run();

end