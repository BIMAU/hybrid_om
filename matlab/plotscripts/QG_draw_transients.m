addpath('../');

if ~exist('preds4', 'var') || ...
        ~exist('ref_preds', 'var') || ...
        ~exist('preds', 'var') || ...
        ~exist('spinup_stats', 'var')
    load_qg_data
end

exportdir = '~/Projects/doc/mlqg/figs/QG_transients/';

cols = [0,0,0; min(1.0*lines(20),1)];

fs = 10;
dims = [24, 10];
windowsize = 10;

start_idx = [1, 1, windowsize, windowsize];
quantity = {'E', 'Z', 'Km', 'Ke'};
ylbls = {'$E$', '$Z$', '$K_m$', '$K_e$'};

for idx = [3]
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
    trange = (T2+(start_idx(idx):size(preds{1,1}, 1))) / 365;
    tserie_modonly = stats{1,1}.(quantity{idx});
    f_modonly = my_plot(trange, tserie_modonly, 'color', cols(2,:));

    %-----------------------------------------------------------------------------
    % % ESN
    % tserie_esnc = stats{1,2}.(quantity{idx});
    % [f_esn, u_esn] = my_plot(trange, tserie_esnc, 'color', cols(3,:));

    %-----------------------------------------------------------------------------
    % ESNc
    tserie_esnc = stats{1,3}.(quantity{idx});
    f_esnc = my_plot(trange, tserie_esnc, 'color', cols(4,:));

    %-----------------------------------------------------------------------------
    % ESN+DMDc
    tserie_esndmdc = stats{1,6}.(quantity{idx});
    [f_esndmdc, u_esndmdc] = my_plot(trange, tserie_esndmdc, 'color', cols(7,:));
    uistack(u_esndmdc, 'bottom')
    uistack(u_ref, 'top')

    %-----------------------------------------------------------------------------
    % snapshot point
    f_snap = plot([200,200],ylim(),'r--');
    hold off

    ylabel(ylbls{idx}, 'interpreter', 'latex');
    xlabel('time (years)', 'interpreter', 'latex');
    ylim([0.003, 0.014])
    xlim([trange_full(365), trange_full(end)])
    lg = legend([f_ref, f_c, f_modonly, f_esnc, f_esndmdc, f_snap], 'perfect QG', 'confidence interval', ...
                'imperfect QG', 'ESNc prediction', 'ESN+DMDc prediction', 'snapshot point ($200$y)', ...
                'interpreter', 'latex', ...
                'orientation', 'vertical', 'location', 'southwest');

    exportfig([exportdir, 'spinup_', quantity{idx}, '.eps'], fs, dims, invert);
    % -----------------------------------------------------------------------------
end

%-----------------------------------------------------------------------------
% PDF plots

trunc_stats = 20*365;
dims = [9,16];
fs = 14;
bins = 20;
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
