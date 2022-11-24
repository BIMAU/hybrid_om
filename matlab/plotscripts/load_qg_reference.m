% For the reference run I initially used a fine model transient in the
% experiment framework. That was doable for a fine grid with nx = 64.
% Now that we moved to nx = 256 I choose to get a transient over the
% same timeperiod from the run performed with QG_spinup.m. Note that,
% for a fair comparison, the reference transient starts after 10000
% 'training' days.
base_dir = '../../data/experiments';
exp_dir = 'QG_transient_reference';

ref_dir = [base_dir, '/', exp_dir];

% This spinup and transient data is already restricted to the coarse
% grid using restrict_chunks.m. This to save memory.
% Spinup: T = 0 -> T = 100
spinup_file = 'spinup_T=100_dt=2.740e-03_param=2.0e+03.mat';
% transient: T = 100 -> T = 200
transient_file = 'transient_T=100_dt=2.740e-03_param=2.0e+03.mat';
% remainder: T = 200 -> T = 250
remainder_file = 'remainder_T=50_dt=2.740e-03_param=2.0e+03.mat';

time = tic();
fprintf('loading\n')
spinup = load([ref_dir, '/', spinup_file]);
transient = load([ref_dir, '/', transient_file]);
remainder = load([ref_dir, '/', remainder_file]);
training_samples = 10000;

% concatenate transient to get a 100 year transient to compare against
% (reference predictions)
ref_preds = {[transient.X(:, training_samples+1:end), remainder.X(:, 1:training_samples)]'};
fprintf('loading done  %3.2f\n', toc(time))

% Setup the coarse QG model
Re_c = 500; % Reynolds
nx_c = 32;  % grid size
ny_c = nx_c;

ampl = 2; % stirring amplitude
stir = 0; % stirring type: 0 = cos(5x), 1 = sin(16x)

% coarse QG with periodic bdc
qg_c = QG(nx_c, ny_c, 1);
qg_c.set_par(5,  Re_c);  % Reynolds number
qg_c.set_par(11, ampl);  % stirring amplitude
qg_c.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)

opts.windowsize = 50;

addpath('../')
s = Utils.get_qg_statistics(qg_c, ref_preds{1, 1}', opts);
ref_stats = {s};