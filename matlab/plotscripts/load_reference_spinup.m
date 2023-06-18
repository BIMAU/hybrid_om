base_dir = '~/Projects/hybrid_om/data/QGmodel/131072_2048';

f_spinup    = [base_dir, '/spinup_T=100_dt=2.740e-03_param=2.0e+03.mat'];
f_transient = [base_dir, '/transient_T=100_dt=2.740e-03_param=2.0e+03.mat'];
f_remainder = [base_dir, '/remainder_T=50_dt=2.740e-03_param=2.0e+03.mat'];

fprintf('loading spinup\n');
d_spinup = load(f_spinup);
fprintf('loading transient\n');
d_transient = load(f_transient);
fprintf('loading remainder\n');
d_remainder = load(f_remainder);

full_transient = [d_spinup.X, d_transient.X, d_remainder.X];

qg_c = Utils.create_coarse_QG();

opts = [];
opts.windowsize = 50;
ref_stats = Utils.get_qg_statistics(qg_c, full_transient, opts);
