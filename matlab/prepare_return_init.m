% Load initialization
start_solutions = '~/Projects/hybrid_om/data/QGmodel/starting_solutions'

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

% on habrok
% base_dir = '/projects/p267904/Projects/hybrid_om/data/experiments/';

% local machine
base_dir = '~/Projects/hybrid_om/data/experiments/';


exp_dir_struct.modelonly = ['QG_transient_modelonly/',...
                    'MC_1-1_SC_1-1_parallel_param_5.00e+02/'];

exp_dir_struct.corr = ['QG_transient_corr/',...
                    'MC_6-6_SC_1-1_parallel_param_5.00e+02/'];

exp_dir_struct.dmdc = ['QG_transient_DMDc/',...
                    'MC_5-5_SC_1-1_parallel_param_5.00e+02/'];


exp_dir_struct.esn = ['QG_transient_ESNscaling/',...
                    'MC_2-8_NR_200-12800_parallel_param_5.00e+02/'];

exp_dir_struct.esnc = exp_dir_struct.esn;
exp_dir_struct.esndmdc = exp_dir_struct.esn;

% current options:
% 'modelonly'  % model only (imperfect QG)
% 'dmdc' % DMDc (lambda = 10)
% 'corr' % correction only (lambda = 5)
% 'esn'  % ESN (Nr = 3200, lambda = 8)
% 'esnc' % ESNc (Nr = 3200, lambda = 8)
% 'esndmdc' % ESN + DMDc (Nr = 3200, lambda = 8)

% correct indices for the predictions array
jdx_struct.modelonly = 1;
jdx_struct.dmdc = 1;
jdx_struct.corr = 1;
jdx_struct.esn = 5;
jdx_struct.esnc = 12;
jdx_struct.esndmdc = 19;

% Select experiment
exp = 'esndmdc';
jdx = jdx_struct.(exp);
basename = [exp,'_prediction'];
exp_dir = exp_dir_struct.(exp);


[errs, nums, pids, ...
 metadata, predictions, corrections...
 truths, spectra, stats] = Utils.gather_data([base_dir, exp_dir]);

[labels, Nvalues, par_names, ...
 exp_ind, I, opts_str] = Utils.unpack_metadata(metadata);

lambda_range = sqrt(metadata.hyp.Lambda.range)

for i = 1:size(predictions,1)
    x = P*predictions{i,jdx}';

    fname = sprintf('%s/%s_%d.mat', start_solutions, basename, i);
    fprintf('saving to %s\n', fname);
    save(fname, 'x');
end