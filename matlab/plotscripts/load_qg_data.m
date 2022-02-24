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
