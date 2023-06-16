% Load initialization
start_solutions = '/home/erik/Projects/hybrid_om/data/QGmodel/starting_solutions'

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

% create data generator for the two models
dgen = DataGen(qg_f, qg_c);

% the grids are different so grid transfers are necessary
dgen.dimension = '2D';
dgen.build_grid_transfers('periodic');

R = dgen.R;
P = dgen.P;

base_dir = '../data/experiments/';
exp_dir_modelonly = 'QG_transient_modelonly/MC_1-1_SC_1-1_parallel_param_5.00e+02/';

exp_dir_ESNc = 'QG_transient_ESNscaling/MC_2-8_NR_200-12800_parallel_param_5.00e+02/'

[errs, nums, pids, ...
 metadata, predictions, corrections...
 truths, spectra, stats] = Utils.gather_data([base_dir, exp_dir_ESNc]);

for i = 1:size(predictions,1)
    x = P*predictions{i,12}';
    basename = 'esnc_prediction'
    fname = sprintf('%s/%s_%d.mat', start_solutions, basename, i)
    fprintf('saving to %s\n', fname)
    save(fname, 'x')
end