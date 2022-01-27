addpath('../');

if ~exist('preds4', 'var') || ...
        ~exist('ref_preds', 'var') || ...
        ~exist('preds', 'var') || ...
        ~exist('spinup_stats', 'var')
    load_qg_data
end

if ~exist('stats_dkl', 'var')
    load_qg_transient_data
end

exportdir = '~/Projects/doc/mlqg/figs/QG_transients/';

cols = [0,0,0; min(1.0*lines(20),1)];

fs = 10;
dims = [24, 10];
windowsize = 50;

start_idx = [1, 1, windowsize, windowsize];
quantity = {'E', 'Z', 'Km', 'Ke'};
ylbls = {'$E$', '$Z$', '$K_m$', '$K_e$'};

set(groot,'defaultAxesTickLabelInterpreter','latex');
figure(1)
clf
h1 = subplot(1,2,1)
for idx = [3]

    plot_stats = { ref_stats{1,1}.(quantity{idx}), ...
                   stats_dkl{1}{1,1}.(quantity{idx}), ...
                   stats_dkl{2}{1,2}.(quantity{idx}), ...
                   stats_dkl{2}{1,3}.(quantity{idx}) };

    names = {'perfect QG', ...
             'imperfect QG', ...
             'ESNc', ...              % lambda 1
             'ESN+DMDc'};             % lambda 1

    colors = {cols(1,:), ...
              cols(2,:), ...
              cols(4,:), ...
              cols(7,:)}

    % -----------------------------------------------------------------------------
    % Reference spinup

    T1 = size(X_spinup, 2);
    T2 = T1 + size(X,2);
    trange_spin = (start_idx(idx):T1) / 365;
    trange_ref1 = (T1 + (start_idx(idx):size(X,2)))/365;
    trange_ref2 = (T2 + (start_idx(idx):size(ref_preds{1,1},1)))/365;

    trange_full = [trange_spin, trange_ref1, trange_ref2];
    tserie_full = [spinup_stats.(quantity{idx})', ...
                   stats_0.(quantity{idx})',...
                   ref_stats{1,1}.(quantity{idx})'];

    % Confidence interval
    trunc_ref = 50*365;
    mn = mean(tserie_full(trunc_ref:end));
    vr = var(tserie_full(trunc_ref:end));
    conf_hi = mn + 2*sqrt(vr);
    conf_lo = mn - 2*sqrt(vr);

    [f_ref, u_ref] = my_plot(trange_full, tserie_full,'color', cols(1,:));
    hold on
    f_c = plot(trange_full, repmat(conf_hi, 1, numel(trange_full)), '--', 'color', cols(1,:));
    f_c = plot(trange_full, repmat(conf_lo, 1, numel(trange_full)), '--', 'color', cols(1,:));

    %-----------------------------------------------------------------------------
    % model only
    trange = (T2+(start_idx(idx):size(stats_dkl{1}{1,1}.PS, 1))) / 365;

    tserie_modonly = plot_stats{2};
    f_modonly = my_plot(trange, tserie_modonly, 'color', colors{2});

    %-----------------------------------------------------------------------------
    % ESN
    % tserie_esnc = stats_dkl{2}{1,1}.(quantity{idx});
    % [f_esn, u_esn] = my_plot(trange, tserie_esnc, 'color', cols(3,:));

    %-----------------------------------------------------------------------------
    % ESNc
    tserie_esnc = plot_stats{3};
    f_esnc = my_plot(trange, tserie_esnc, 'color', colors{3});

    %-----------------------------------------------------------------------------
    % ESN+DMDc
    tserie_esndmdc = plot_stats{4};
    [f_esndmdc, u_esndmdc] = my_plot(trange, tserie_esndmdc, 'color', colors{4});
    uistack(u_esndmdc, 'bottom')
    uistack(u_ref, 'top')

    %-----------------------------------------------------------------------------
    % snapshot point
    % f_snap = plot([200,200],ylim(),'r:');
    hold off

    ylabel(ylbls{idx}, 'interpreter', 'latex');
    xlabel('time (years)', 'interpreter', 'latex');

    if strcmp(quantity{idx}, 'Km')
        ylim([0.003, 0.014]);
    end

    xlim([trange_full(365), trange_full(end)])
    lg = legend([f_ref, f_c, f_modonly, f_esnc, f_esndmdc], 'perfect QG', 'confidence interval', ...
                'imperfect QG', 'ESNc prediction', 'ESN+DMDc prediction',  ...
                'interpreter', 'latex', ...
                'orientation', 'vertical', 'location', 'southwest');

    %-----------------------------------------------------------------------------
    % PDF plot
    trunc_stats = 20*365;
    bins = 20;

    h2 = subplot(1,3,3);
    pdf_lines = [];
    for s = 1:numel(plot_stats)
        hold on
        pdf_lines{s} = plotpdf(plot_stats{s}(trunc_stats:end), bins, '.-', ...
                               'color', colors{s}, ...
                               'markersize',7);
    end
    hold off
    if strcmp(quantity{idx}, 'Km')
        ylim([0.003, 0.014]);
    end
    box on
    
    uistack(pdf_lines{4}, 'bottom')
    uistack(pdf_lines{1}, 'top')
    
    %ylabel(ylbls{idx}, 'interpreter', 'latex');
    set(gca,'xtick', [])
    set(gca,'ytick', [])
    
    set(h1,'Position', [0.13 0.11 0.65 0.815])
    set(h2,'Position', [0.81 0.11 0.13 0.815])
    
    xlabel('PDF', 'interpreter','latex')

    exportfig([exportdir, 'spinup_', quantity{idx}, '.eps'], fs, dims, invert);

end
%------------------------------------------------------------------














return

for idx = [3,4,2]
    plot_stats = {ref_stats{1,1}.(quantity{idx})(trunc_stats:end), ...
                  stats{1,1}.(quantity{idx})(trunc_stats:end), ...
                  stats{1,2}.(quantity{idx})(trunc_stats:end), ...
                  stats{1,3}.(quantity{idx})(trunc_stats:end), ...
                  stats4{1,2}.(quantity{idx})(trunc_stats:end), ...
                  stats2{1,2}.(quantity{idx})(trunc_stats:end), ...
                  stats{1,6}.(quantity{idx})(trunc_stats:end)};

    names = {'perfect QG', ...
             'imperfect QG', ...
             'ESN', ...               % lambda 1e-2
             'ESNc', ...              % lambda 1e-2
             'DMDc', ...              % lambda 30
             'correction only', ...   % lambda 10
             'ESN+DMDc'};             % lambda 1e-2

    pdf = [];
    figure(idx)
    clf
    for s = 1:numel(plot_stats)
        hold on
        pdf{s} = plotpdf(plot_stats{s}, bins, '.-', ...
                         'color', cols(s,:), ...
                         'markersize',10);
    end
    hold off
    if idx == 4
        lg = legend([pdf{:}], names{:}, ...
                    'interpreter', 'latex', 'location','northeast');
    end

    ylabel(ylbls{idx}, 'interpreter', 'latex');
    set(gca,'xtick', [])
    exportfig([exportdir, 'pdf_', quantity{idx}, '.eps'], fs, dims, invert);
end

%-----------------------------------------------------------------------------
% PDF plots ROM results

for idx = [3,4,2]
    plot_stats = {ref_stats{1,1}.(quantity{idx})(trunc_stats:end), ...
                  stats{1,1}.(quantity{idx})(trunc_stats:end), ...
                  stats{1,14}.(quantity{idx})(trunc_stats:end), ...
                  stats{1,15}.(quantity{idx})(trunc_stats:end), ...
                  stats{1,18}.(quantity{idx})(trunc_stats:end)};

    names = {'perfect QG', ...
             'imperfect QG', ...
             'ESN, local POD', ...
             'ESNc, local POD', ...
             'ESN+DMDc, local POD'};

    plot_cols = {cols(1,:), ...
                 cols(2,:), ...
                 cols(3,:), ...
                 cols(4,:), ...
                 cols(7,:)};

    pdf = [];
    figure(idx)
    clf
    for s = 1:numel(plot_stats)
        hold on
        pdf{s} = plotpdf(plot_stats{s}, bins, '.-', ...
                         'color', plot_cols{s}, ...
                         'markersize',10);
    end
    hold off

    if idx == 4
        lg = legend([pdf{:}], names{:} , ...
                    'interpreter', 'latex', 'location','northeast');
    end

    ylabel(ylbls{idx}, 'interpreter', 'latex');
    set(gca,'xtick', [])
    exportfig([exportdir, 'pdf_rom_', quantity{idx}, '.eps'], fs, dims, invert);

end
