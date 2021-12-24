addpath('../')
    
Re_f = 1000;
Re_c = 500;
nx_f = 64;
ny_f = nx_f;
nx_c = 32;
ny_c = nx_c;

ampl = 2; % stirring amplitude
stir = 0; % stirring type: 0 = cos(5x), 1 = sin(16x)

opts.nun = 2;
opts.nx = nx_c;
opts.ny = ny_c;
opts.Re = Re_c;
opts.ampl = ampl;
opts.stir = stir;
opts.windowsize = 10;

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
[Ldim, ~, Udim] = qg_c.get_nondim();
opts.Ldim = Ldim;
opts.Udim = Udim;

% create data generator for the two models
dgen = DataGen(qg_f, qg_c);

% the grids are different so grid transfers are necessary
dgen.dimension = '2D';
dgen.build_grid_transfers('periodic');

% store the grid transfers in the options
opts.R = dgen.R;

% load appropriate initial solution for QG
init_sol = load('~/Projects/hybrid_om/data/QGmodel/starting_solutions/equilibrium_nx64_Re1e3_ampl2_stir0_rot1.mat');

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
day = 24*3600; % in seconds
year = day*365; % in seconds
dt_prf = day / Tdim;
dgen.dt_prf = dt_prf;
scaling = 3600*24/Tdim;

% compute 100 years, which should roughly give 36500 snapshots
dgen.T = round(100 * year / Tdim);
dgen.verbosity = 10;
dgen.generate_prf_transient();

%% ------------------------------------------------------------------
% load reference solution
base_dir = '~/Projects/hybrid_om/data/experiments/';
exp_dir = 'QG_reference_transient/MC_1-1_serial_param_1.00e+03/';
ref_dir = [base_dir, exp_dir, '/'];
training_samples = 10000;
X = opts.R*dgen.X(:,1:training_samples);

stats_0 = Utils.get_qg_statistics(qg_c, X, opts);
[~, ~, ref_preds, ~, ref_stats] = Utils.get_qg_transient_data(ref_dir, opts);

%% ------------------------------------------------------------------
% load spinup
fprintf('load spinup data ...\n');
spinup_data = load('~/Projects/qg/matlab/MLQG/data/fullmodel/N64_Re1.0e+03_Tstart0_Tend100_F2_Stir0_Rot1.mat');
X_spinup = opts.R * spinup_data.states;
spinup_stats = Utils.get_qg_statistics(qg_c, X_spinup, opts);

%%------------------------------------------------------------------

% exp_dir = 'QG_transient/MC_4-8_LB_10-1e-06_parallel_param_5.00e+02/';
% exp_dir = 'QG_transient/MC_4-8_SC_1-5_parallel_param_5.00e+02/';
% exp_dir = 'QG_transient/MC_4-8_RH_0.1-0.8_parallel_param_5.00e+02/';
% exp_dir = 'QG_transient/MC_1-8_SC_1-5_parallel_param_5.00e+02/';
exp_dir = 'QG_transient_LB_0.01/MC_1-8_SC_1-5_parallel_param_5.00e+02/';

dir = [base_dir, exp_dir, '/'];
[~, exp_mdat, preds, ~, stats] = Utils.get_qg_transient_data(dir, opts);
[labels, Nvalues, par_names, exp_ind, I, opts_str] = Utils.unpack_metadata(exp_mdat)

%%-----------------------------------------------------------------------------

%%
% load extra DMD and correction runs with different regularization
exp_dir2 = 'QG_transient/MC_5-6_LB_10-10_serial_param_5.00e+02/'

p2 = Plot([base_dir, exp_dir2, '/']);
[~, exp_mdat2, preds2, ~, stats2] = Utils.get_qg_transient_data([base_dir, exp_dir2, '/'], opts);
[~, ~, ~, ~, ~, opts_str2] = Utils.unpack_metadata(exp_mdat2)

%%
exp_dir3 = 'QG_transient/MC_5-5_LB_100-0.39062_parallel_param_5.00e+02/';
p3 = Plot([base_dir, exp_dir3, '/']);
[~, exp_mdat3, preds3, ~, stats3] = Utils.get_qg_transient_data([base_dir, exp_dir3, '/'], opts);
[~, ~, ~, ~, ~, opts_str3] = Utils.unpack_metadata(exp_mdat3);

%%
exp_dir4 = 'QG_transient/MC_5-5_LB_25-45_parallel_param_5.00e+02';
p4 = Plot([base_dir, exp_dir4, '/']);
[~, exp_mdat4, preds4, ~, stats4] = Utils.get_qg_transient_data([base_dir, exp_dir4, '/'], opts);
[~, ~, ~, ~, ~, opts_str4] = Utils.unpack_metadata(exp_mdat4);

%%
