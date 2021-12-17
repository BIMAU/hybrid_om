addpath('../');

if ~exist('romexp_p', 'var') || ...
        ~exist('gridexp_p', 'var') || ...
        ~exist('preds', 'var') || ...
        ~exist('spinup_stats', 'var')
    load_qg_data
end

exportdir = '~/Projects/doc/mlqg/figs/QG_scaling/';
invert = false;
%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
% % DRAW scaling experiments
figure(1)
gridexp_p.plot_mean = false;
gridexp_p.plot_scatter = false;

[nums,mdat,~,~,f] = gridexp_p.plot_experiment(false, false);
p.create_description(mdat)
legend([f{:}], 'imperfect model', 'ESN', 'ESNc', 'DMDc', ...
       'correction only', 'ESN+DMDc', 'interpreter', 'latex','location','northwest')
ylabel('accurate days', 'interpreter', 'latex')
xlabel('$N_r$', 'interpreter', 'latex')
fs = 14;
dims = [18,14];

title('');
exportfig([exportdir, 'results_gridexp.eps'], fs, dims, invert)

%-----------------------------------------------------------------------------
figure(2)

romexp_p.plot_mean = false;
romexp_p.plot_scatter = false;

[~,~,~,~,f] = romexp_p.plot_experiment(false, false);

legend([f{:}], 'ESNc, no scale separation, no reduction', 'ESNc, wavelet', ...
       'ESNc, POD', 'ESNc, local POD', ...
       'interpreter', 'latex','location','northwest')
ylabel('accurate days', 'interpreter', 'latex')
xlabel('$N_r$', 'interpreter', 'latex')
title('');
exportfig([exportdir, 'results_romexp.eps'], fs, dims, invert)
