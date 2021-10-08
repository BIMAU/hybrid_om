% get old data set
data = load('~/Projects/qg/matlab/MLQG/data/fullmodel/N64_Re1.0e+03_Tstart0_Tend100_F2_Stir0_Rot1.mat')
x_init = data.states(:,end);

Re = data.Re;
ampl = data.ampl;
dt = data.dt;
nx = data.nx;
ny = data.ny;
stir = data.stir;

plot(max(data.states))

input('save final state?')

save('~/Projects/hybrid_om/data/QGmodel/starting_solutions/equilibrium_nx64_Re1e3_ampl2_stir0_rot1.mat', 'x_init', 'Re', 'ampl', 'stir', 'nx', 'ny', 'dt')