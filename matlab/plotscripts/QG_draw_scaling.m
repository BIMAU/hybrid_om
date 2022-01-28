addpath('../')

base_dir = '~/Projects/hybrid_om/data/experiments/';
exportdir = '~/Projects/doc/mlqg/figs/QG_scaling/';
invert = false;
set(groot,'defaultAxesTickLabelInterpreter','latex'); 
%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
% % DRAW scaling experiments
figure(1)
clf
gridexp_dir = 'QG_GridExp/MC_1-8_NR_200-12800_parallel_param_5.00e+02/';
gridexp_p = Plot([base_dir, gridexp_dir, '/']);

gridexp_p.plot_mean = false;
gridexp_p.plot_scatter = false;
gridexp_p.style = {'.', '-', '-'};
gridexp_p.msize = {15, 12};

[nums,mdat,~,~,f] = gridexp_p.plot_experiment(false, false);
Utils.create_description(mdat)
legend([f{:}], 'imperfect model', 'ESN', 'ESNc', 'DMDc', ...
       'correction only', 'ESN+DMDc', 'interpreter', 'latex','location','northwest')
ylabel('accurate days', 'interpreter', 'latex')
xlabel('$N_r$', 'interpreter', 'latex')
fs = 14;
dims = [18,14];

title('');
exportfig([exportdir, 'results_gridexp.eps'], fs, dims, invert)


%-----------------------------------------------------------------------------
% figure(2)
% romexp_dir = 'QG_NR_ScaleSep_T10000/NR_200-12800_SC_1-5_parallel_param_5.00e+02/';
% romexp_p = Plot([base_dir, romexp_dir, '/']);

% romexp_p.plot_mean = false;
% romexp_p.plot_scatter = false;

% [~,mdat,~,~,f] = romexp_p.plot_experiment(false, false);
% Utils.create_description(mdat)

% legend([f{:}], 'ESNc, no scale separation, no reduction', 'ESNc, wavelet', ...
%        'ESNc, POD', 'ESNc, local POD', ...
%        'interpreter', 'latex','location','northwest')
% ylabel('accurate days', 'interpreter', 'latex')
% xlabel('$N_r$', 'interpreter', 'latex')
% title('');
% exportfig([exportdir, 'results_romexp.eps'], fs, dims, invert)