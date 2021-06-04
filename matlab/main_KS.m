addpath('models')

L      = 35;
N_prf  = 128;
N_imp  = 64;
ks_prf = KSmodel(L, N_prf);
ks_imp = KSmodel(L, N_imp);

ks_prf.initialize();
ks_imp.initialize();

dgen = DataGen(ks_prf, ks_imp);

dgen.dt = 0.25;
dgen.T  = 100;

dgen.generate_prf_transient();
X = dgen.X;
imagesc(X)
dgen.generate_imp_predictions();