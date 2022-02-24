addpath('../');

if ~exist('preds4', 'var') || ...
        ~exist('ref_preds', 'var') || ...
        ~exist('preds', 'var') || ...
        ~exist('spinup_stats', 'var')
    load_qg_data
end

if ~exist('preds_dkl', 'var')
    load_qg_transient_data
end   

exportdir = '~/Projects/doc/mlqg/figs/QG_snapshots/';

fs = 10;
dims = [11, 10];

map = my_colmap(); % colormap
crange = [-0.3,0.3];

% snapshots at 200 years since initial spinup
T = 200*365-10000-100*365;
set(groot,'defaultAxesTickLabelInterpreter','latex');

figure(1)
fields = {ref_preds{1,1}(end,:)', ...
          preds_dkl{1}{1,1}(end,:)', ...
          preds_dkl{5}{1,5}(end,:)', ...   % lambda = 1
          preds_dkl{5}{1,12}(end,:)', ...  % lambda = 1
          preds_dkl{5}{1,19}(end,:)'};     % lambda = 1

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
    exportfig(fnames{j}, fs, dims, invert)
end