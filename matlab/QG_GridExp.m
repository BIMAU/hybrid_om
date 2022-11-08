function [dir] = QG_GridExp(varargin)
    [pid, procs] = Utils.input_handling(nargin, varargin);
    Utils.add_paths();

    % Create two QG models with different grids and different Reynolds
    % numbers.
    Re_f = 2000;
    Re_c = 500;
    nx_f = 256;
    ny_f = nx_f;
    nx_c = 32;
    ny_c = nx_c;

    ampl = 2; % stirring amplitude
    stir = 0; % stirring type: 0 = cos(5x), 1 = sin(16x)

    % fine QG with periodic bdc
    qg_f = QG(nx_f, ny_f, 1);
    qg_f.set_par(5,  Re_f);  % Reynolds number
    qg_f.set_par(11, ampl);  % stirring amplitude
    qg_f.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)

    % coarse QG with periodic bdc
    qg_c = QG(nx_c, ny_c, 1);
    qg_c.set_par(5,  Re_c);  % Reynolds number
    qg_c.set_par(11, ampl);  % stirring amplitude
    qg_c.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)

    % get QG nondimensionalization, which is the same for qg_f and qg_c
    [Ldim, ~, Udim] = qg_f.get_nondim();

    % create data generator for the two models
    dgen = DataGen(qg_f, qg_c);

    % the grids are different so grid transfers are necessary
    dgen.dimension = '2D';
    dgen.build_grid_transfers('periodic');

    % load appropriate initial solution for QG
    init_sol = load('~/Projects/hybrid_om/data/QGmodel/starting_solutions/equilibrium_nx256_Re2e3_ampl2_stir0_rot1.mat');

    % check that what we got is ok
    assert(init_sol.Re == Re_f);
    assert(init_sol.nx == nx_f);
    assert(init_sol.ny == ny_f);
    assert(init_sol.ampl == ampl);
    assert(init_sol.stir == stir);

    % set initial solution in datagen
    dgen.x_init_prf = init_sol.x_init;
    
    % set the time step to one day
    Tdim = Ldim / Udim; % in seconds
    day  = 24*3600; % in seconds
    year = day*365; % in seconds
    dt_prf = day / Tdim;
    dgen.dt_prf = dt_prf;

    % compute 100 years, which should give 36500 snapshots
    dgen.T = round(100 * year / Tdim);
    dgen.output_freq = 10;    
    
    dgen.generate_prf_transient();

    % generate imperfect model predictions
    % imperfect model time step (should be an integer multiple of dt_prf)
    dgen.dt_imp = dgen.dt_prf;
    dgen.generate_imp_predictions();

    % create experiment class
    expObj = Experiment(dgen, pid, procs);

    expObj.reps = 1;
    expObj.store_state = 'final';
    expObj.max_preds = 365;

    % adjust hyperparam defaults
    expObj.set_default_hyp('Alpha', 0.2);
    expObj.set_default_hyp('TrainingSamples', 10000);
    expObj.set_default_hyp('AverageDegree', 3);
    expObj.set_default_hyp('RhoMax', 0.4);
    expObj.set_default_hyp('InAmplitude', 1);
    expObj.set_default_hyp('SVDWaveletBlockSize', 1);
    expObj.set_default_hyp('SVDWaveletReduction', 1);
    expObj.set_default_hyp('ReservoirSize', 3200);
    expObj.set_default_hyp('FilterCutoff', 0.01);
    expObj.set_default_hyp('TimeDelay', 0);
    expObj.set_default_hyp('TimeDelayShift', 100);
    expObj.set_default_hyp('SeparateUnknowns', false);

    % Input matrix type
    % (1) sparse
    % (2) sparseOnes
    % (3) balancedSparse
    % (4) full
    % (5) identity
    expObj.set_default_hyp('InputMatrixType', 3);

    % Scaling of the data:
    % (1) none
    % (2) minMax1
    % (3) minMax2
    % (4) minMaxAll
    % (5) standardize
    expObj.set_default_hyp('ScalingType', 5);

    % Spatial scale separation (modes) options:
    % (1) none
    % (2) wavelet
    % (3) dmd
    % (4) pod
    % (5) local_pod
    % (6) wav+pod
    expObj.set_default_hyp('ScaleSeparation', 1);
    expObj.set_default_hyp('BlockSize', 64);
    expObj.set_default_hyp('ReductionFactor', 1);

    % Add details
    % (1) disabled
    % (2) from model
    expObj.set_default_hyp('AddDetails',2);

    % Model configuration options:
    % (1) model_only
    % (2) esn_only
    % (3) dmd_only
    % (4) hybrid_esn
    % (5) hybrid_dmd
    % (6) corr_only
    % (7) esn_plus_dmd
    % (8) hybrid_esn_dmd

    expObj.error_windowsize = 10;
    expObj.err_type = 'norm';
    expObj.err_tol = 0.4;
    expObj.shifts = 50;
    
    expObj.ident = 'QG_GridExp_tol0.4';
    expObj.set_default_hyp('Lambda', 1e-8);
    expObj.add_experiment('ModelConfig', [1, 2, 4, 5, 6, 8]);
    expObj.add_experiment('ReservoirSize', [100, 200, 400, 800, 1600, 3200, 6400, 12800]);

    % run experiments
    dir = expObj.run();
end
