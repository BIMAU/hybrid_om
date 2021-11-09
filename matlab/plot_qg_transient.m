exp_dir = 'QG_transient/MC_1-8_serial_param_5.00e+02';

base_dir = '~/Projects/hybrid_om/data/experiments/';

dir = [base_dir, exp_dir, '/'];
p = Plot(dir);

% give some information on QG that we could also get from a mat file somewhere
opts.nx = 32;
opts.ny = 32;
opts.nun = 2;
opts.Re = 500;
opts.ampl = 2;
opts.stir = 0;
opts.Ldim = 1e6;
opts.Udim = 3.171e-2;
opts.windowsize = 50;
[nums, mdat, preds, truths, s] = p.plot_qg_transient(opts);