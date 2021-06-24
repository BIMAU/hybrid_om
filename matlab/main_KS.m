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
dgen.build_grid_transfers('periodic', '1D');

% generate perfect model transient
dgen.T = 20;         % total time
dgen.dt_prf = 0.25;  % perfect model time step
dgen.trunc = 10;     % truncate period
dgen.generate_prf_transient();

% generate imperfect model predictions
% imperfect model time step (should be an integer multiple of dt_prf)
dgen.dt_imp = 2*dgen.dt_prf;
dgen.generate_imp_predictions();

% #TODO create training data struct
tr_data = struct();

model   = ks_imp;

% create experiment class
expObj = Experiment(tr_data, model);

% adjust experiment settings

expObj.dimension='2D';
expObj.set_default_hyp('ReservoirSize', 1000);
expObj.set_default_hyp('BlockSize', 16);
expObj.add_experiment('ReservoirSize', [500, 1000, 2000]);
expObj.add_experiment('BlockSize', [1, 4, 16]);

% run experiments
expObj.run();