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

% generate perfect model transient
dgen.T = 100;        % total time
dgen.dt_prf = 0.25;  % perfect model time step
dgen.trunc = 10;     % truncate period
dgen.generate_prf_transient();

% generate imperfect model predictions
% imperfect model time step (should be an integer multiple of dt_prf)
dgen.dt_imp = 2*dgen.dt_prf;
dgen.generate_imp_predictions();

% create experiment class
expObj = Experiment(dgen);
expObj.shifts = 2;
expObj.reps = 1;

% adjust hyperparam defaults
expObj.set_default_hyp('ReservoirSize', 1000);
expObj.set_default_hyp('BlockSize', 16);
expObj.set_default_hyp('TrainingSamples', 50);

% set experiments
expObj.add_experiment('ReservoirSize', [500, 1000]);
% expObj.add_experiment('BlockSize', [1, 4, 16]);

% run experiments
expObj.run();