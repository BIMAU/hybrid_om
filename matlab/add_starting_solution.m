% get old data set
% data = load('~/Projects/qg/matlab/MLQG/data/fullmodel/N64_Re1.0e+03_Tstart0_Tend100_F2_Stir0_Rot1.mat')

data = load('/data/p267904/Projects/hybrid_om/data/QGmodel/131072_131072/transient_T=250_dt=2.740e-03_param=2.0e+03.chunk_36136-36500.mat');
x_init = data.X(:,end);

Re = 2000;
ampl = 2;
dt = 1/365;
nx = 256;
ny = 256;
stir = 0;
step = 36500;

plot(max(data.X))

input('save final state?')

save('~/Projects/hybrid_om/data/QGmodel/starting_solutions/equilibrium_nx256_Re2e3_ampl2_stir0_rot1.mat', 'x_init', 'Re', 'ampl', 'stir', 'nx', 'ny', 'dt', 'step')