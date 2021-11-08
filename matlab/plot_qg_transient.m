exp_dir = 'QG_transient/MC_1-8_serial_param_5.00e+02';

base_dir = '~/Projects/hybrid_om/data/experiments/';

dir = [base_dir, exp_dir, '/'];
p = Plot(dir);

opts.nx = 32;
opts.ny = 32;
opts.Re = 500;
opts.ampl = 2;
opts.stir = 0;

p.plot_qg_transient(opts);