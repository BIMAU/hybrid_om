addpath('../');
addpath('~/local/matlab')

% Snapshots at the end of the transient prediction
% period. Time from start spinup is 100*365 + 10000 + 100*365;
T_since_start = 83000;
T_in_chunk = T_since_start - 82856 + 1;

base_dir = '/data/p267904/Projects/hybrid_om/data/';
ref_mat = ['QGmodel/131072_131072/', ...
           'transient_T=250_dt=2.740e-03_param=2.0e+03.chunk_82856-83220.mat'];

ref_mat = [base_dir, '/', ref_mat];

if ~exist('ref_dat', 'var')
    ref_dat = load(ref_mat);
end

if ~exist('preds_dkl', 'var')
    load_qg_transient_data;
end

exportdir = '~/Projects/doc/mlqg/figs/QG_snapshots/';

fs = 10;
dims = [11, 10];
invert = false;

map = Utils.my_colmap(); % colormap
crange = [-0.3,0.3];

% fine and coarse resolutions
nx_f = 256;
ny_f = nx_f;
nx_c = 32;
ny_c = nx_c;

% Create a QG instance
% fine QG with periodic bdc
Re_f = 2000;
ampl = 2; % stirring amplitude
stir = 0; % stirring type: 0 = cos(5x), 1 = sin(16x)
qg_f = QG(nx_f, ny_f, 1);
qg_f.set_par(5,  Re_f);  % Reynolds number
qg_f.set_par(11, ampl);  % stirring amplitude
qg_f.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)

% get QG nondimensionalization, which is the same for qg_f and qg_c
[Ldim, ~, Udim] = qg_f.get_nondim();
tdim = Ldim / Udim; % in seconds
scaling = 3600*24/tdim;

set(groot,'defaultAxesTickLabelInterpreter','latex');
figure(1)
fields = {ref_dat.X(:,T_in_chunk), ...
          preds_dkl{1}{1,1}(end,:)', ...
          preds_dkl{4}{1,5}(end,:)', ...   % lambda = ??
          preds_dkl{4}{1,12}(end,:)', ...  % lambda = ??
          preds_dkl{4}{1,19}(end,:)'};     % lambda = ??

titles = {'perfect model, vorticity (day$^{-1}$)', ...
          'imperfect model, vorticity (day$^{-1}$)', ...
          'ESN prediction, vorticity (day$^{-1}$)', ...
          'ESNc prediction, vorticity (day$^{-1}$)', ...
          'ESN+DMDc prediction, vorticity (day$^{-1}$)'};

state_dims = {[nx_f, ny_f], ...
              [nx_c, ny_c]};

fnames = {[exportdir, 'perfect_vort', '.eps'], ...
          [exportdir, 'imperfect_vort', '.eps'], ...
          [exportdir, 'ESN_vort', '.eps'], ...
          [exportdir, 'ESNc_vort', '.eps'], ...
          [exportdir, 'ESN+DMDc_vort', '.eps']};

for j = 1:numel(fields)
    nx = state_dims{min(2,j)}(1);
    ny = state_dims{min(2,j)}(2);
    plotQG(nx, ny, 1, scaling*fields{1,j}, true);
    colormap(map);
    c = colorbar;
    c.TickLabelInterpreter = 'latex';
    caxis(crange)
    set(gca,'xtick',[])
    set(gca,'ytick',[])
    Utils.exportfig(fnames{j}, fs, dims, invert)
end