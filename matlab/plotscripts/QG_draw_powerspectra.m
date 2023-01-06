addpath('../')
addpath('~/local/matlab');

if ~exist('spectra_dkl', 'var')
    load_qg_transient_data;
end          

if ~exist('ref_preds', 'var')
    load_qg_reference;
end          

base_dir = '/data/p267904/Projects/hybrid_om/data/';
exportdir = '~/Projects/doc/mlqg/figs/QG_spectra/';

trunc = 20*365; % truncate initial spinup
cols = [0,0,0; lines(10)];

spec_opts = [];
spec_opts.windowsize = 10; % doesn't seem to do anything.. legacy
spec_opts.trunc = trunc;
spec_opts.skip = 40; % is the plot sensitive to this? no.
spec_opts.conf_int = false;
spec_opts.stircol = cols(1,:);

p = Plot();

Pm_modonly = spectra_dkl{1}{1,1,1}(:,trunc/365:end);
Pv_modonly = spectra_dkl{1}{1,1,2}(:,trunc/365:end);

Pm_esn = spectra_dkl{4}{1,5,1}(:,trunc/365:end);
Pv_esn = spectra_dkl{4}{1,5,2}(:,trunc/365:end);

Pm_esnc = spectra_dkl{4}{1,12,1}(:,trunc/365:end);
Pv_esnc = spectra_dkl{4}{1,12,2}(:,trunc/365:end);

Pm_esndmdc = spectra_dkl{4}{1,19,1}(:,trunc/365:end);
Pv_esndmdc = spectra_dkl{4}{1,19,2}(:,trunc/365:end);

Pm_corr = spectra_dkl{3}{1,1,1}(:,trunc/365:end);
Pv_corr = spectra_dkl{3}{1,1,2}(:,trunc/365:end);

plot_data = {ref_preds{1,1}(trunc:end,:)',...
             {Pm_modonly, Pv_modonly}, ...
             {Pm_esn, Pv_esn}, ...
             {Pm_esnc, Pv_esnc},...
             {Pm_esndmdc, Pv_esndmdc},...
             {Pm_corr, Pv_corr}};

names = {'perfect QG', ...
         'imperfect QG', ...
         'ESN', ...
         'ESNc', ...
         'ESN+DMDc', ...
         'correction only'};

colors = {cols(1,:),...
          cols(2,:),...
          cols(3,:),...
          cols(4,:),...
          cols(5,:),...
          cols(6,:)};

f = plot_spectra(qg_c, p, plot_data(1:4), ...
                 names(1:4), colors(1:4), spec_opts);

fs = 10;
dims = [12,8];
Utils.exportfig([exportdir, 'results_powerspec.eps'], fs, dims, invert);

return
%-----------------------------------------------------------------------------
% ROM results

plot_data = {dgen.R*ref_preds{1,1}(trunc:end,:)',...
             preds{1,1}(trunc:end,:)',...
             preds{1,14}(trunc:end,:)',...
             preds{1,15}(trunc:end,:)',...
             preds{1,18}(trunc:end,:)',...
            };

names = {'perfect QG', ...
         'imperfect QG', ...
         'ESN, local POD', ...
         'ESNc, local POD', ...
         'ESN+DMDc, local POD'};

colors = {cols(1,:), ...
          cols(2,:), ...
          cols(3,:), ...
          cols(4,:), ...
          cols(7,:)};
f = plot_spectra(qg_c, p, plot_data, names, colors, spec_opts);
Utils.exportfig([exportdir, 'results_powerspec_rom.eps'], fs, dims, invert)
%-----------------------------------------------------------------------------

function [f] = plot_spectra(qg, p, plot_data, names, colors, opts)
    f = [];
    for j = 1:numel(plot_data)
        opts.T = size(plot_data{j},2);
        [f{j}, Pm_ref, Pv_ref, g] = p.plot_qg_mean_spectrum(qg, plot_data{j}, ...
                                                            opts, '.-', ...
                                                            'color', colors{j});
        hold on
        drawnow
    end
    hold off

    legend([f{:},g], {names{:},'stirring wavenumber'}, ...
           'interpreter','latex', ...
           'location', 'southwest');

    xlabel('wavenumber $\|\vec{k}\|_2$','interpreter','latex');
    set(gca,'yticklabels',[])
    set(gca,'xtick',[(3:10),15])
    ylim([1e-4,1e3])
    grid on
end