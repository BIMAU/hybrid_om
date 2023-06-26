addpath('../');
addpath('~/local/matlab');
set(groot,'defaultAxesTickLabelInterpreter','latex');
figure(1)
clf
invert = false;

if ~exist('stats_dkl', 'var')
    load_qg_transient_data
end

base_dir = '/projects/p267904/Projects/hybrid_om/data/QGmodel/131072_2048';
% base_dir = '../..//data/QGmodel/131072_2048';

f_spinup    = [base_dir, '/spinup_T=100_dt=2.740e-03_param=2.0e+03.mat'];
f_transient = [base_dir, '/transient_T=100_dt=2.740e-03_param=2.0e+03.mat'];
f_remainder = [base_dir, '/remainder_T=50_dt=2.740e-03_param=2.0e+03.mat'];

fprintf('loading spinup\n');
d_spinup = load(f_spinup);
fprintf('loading transient\n');
d_transient = load(f_transient);
fprintf('loading remainder\n');
d_remainder = load(f_remainder);

full_transient = [d_spinup.X, d_transient.X, d_remainder.X];

% coarse QG with periodic bdc
qg_c = Utils.create_coarse_QG();

opts = [];
opts.windowsize = 50;
training_samples = 10000;

% reference transient statistics
ref_stats = Utils.get_qg_statistics(qg_c, full_transient, opts);
start_idx = [1, 1, opts.windowsize, opts.windowsize];
quantity = {'E', 'Z', 'Km', 'Ke'};
ylbls = {'$E$', '$Z$', '$K_m$', '$K_e$'};

names = {'perfect QG', ...
         'imperfect QG', ...
         'ESN', ...           % lambda = ??
         'ESNc'};             % lambda = ??

cols = [0,0,0; lines(3)];
colors = {cols(1,:), ...
          cols(2,:), ...
          cols(3,:), ...
          cols(4,:)};

fs = 10;
dims = [24, 10];
exportdir = '~/Projects/doc/mlqg/figs/QG_transients/';

for idx = [3]
    % plot_stats = { ref_stats.(quantity{idx}), ...
    %                stats_dkl{1}{1,1}.(quantity{idx}), ...
    %                stats_dkl{5}{1,5}.(quantity{idx}), ...
    %                stats_dkl{5}{1,12}.(quantity{idx}) };
    plot_stats = {ref_stats.(quantity{idx}),
                  stats_dkl{1}{1,1}.(quantity{idx}),
                  stats_dkl{4}{1,5}.(quantity{idx}),
                  stats_dkl{4}{1,12}.(quantity{idx})};

    T1 = size(full_transient, 2);
    T2 = 100 * 365 + training_samples;
    trange_full = (start_idx(idx):T1)/365;
    tserie_full = plot_stats{1};

    % Confidence interval for the reference run
    trunc_ref = 50*365;
    mn = mean(tserie_full(trunc_ref:end));
    vr = var(tserie_full(trunc_ref:end));
    conf_hi = mn + 2*sqrt(vr);
    conf_lo = mn - 2*sqrt(vr);

    h1 = subplot(1,2,1)
    % plot reference
    [f_ref, u_ref] = my_plot(trange_full, tserie_full, 'linewidth', 1.2, ...
                             'color', cols(1,:));
    hold on
    f_ref = plot(NaN, NaN, '.-', 'linewidth', 1.2, ...
                 'color', cols(1,:) ,...
                 'markerfacecolor', cols(1,:), 'markersize', 9);

    % plot corresponding confidence interval
    f_c = plot(trange_full, ...
               repmat(conf_hi, 1, numel(trange_full)), ...
               '--', 'color', cols(1,:));
    f_c = plot(trange_full, ...
               repmat(conf_lo, 1, numel(trange_full)), ...
               '--', 'color', cols(1,:));

    % create trange for predictions
    trange = T2 + start_idx(idx) + (1:numel(plot_stats{2}));
    trange = trange / 365; % convert to years

    tserie_modonly = plot_stats{2};
    f_modonly = my_plot(trange, tserie_modonly, 'linewidth', 1.2, ...
                        'color', colors{2});
    f_modonly = plot(NaN, NaN, 's-', 'linewidth', 1.2, ...
                     'color', cols(2,:),...
                      'markerfacecolor', cols(2,:), 'markersize', 3);

    tserie_esn = plot_stats{3};
    [f_esn, u_esn] = my_plot(trange, tserie_esn, 'linewidth', 1.2, ...
                             'color', colors{3});
    f_esn = plot(NaN, NaN, '^-', 'linewidth', 1.2, ...
                 'color', cols(3,:),...
                  'markerfacecolor', cols(3,:), 'markersize', 3);
    uistack(u_esn, 'bottom')

    tserie_esnc = plot_stats{4};
    [f_esnc, u_esnc] = my_plot(trange, tserie_esnc, 'linewidth', 1.2, ...
                               'color', colors{4});
    f_esnc = plot(NaN, NaN, 'o-', 'linewidth', 1.2, ...
                  'color', cols(4,:), ...
                  'markerfacecolor', cols(4,:), 'markersize', 3);
    uistack(u_ref, 'top')

    hold off

    ylabel(ylbls{idx}, 'interpreter', 'latex');
    xlabel('time (years)', 'interpreter', 'latex');

    if strcmp(quantity{idx}, 'Km')
        ylim([0.003, 0.019]);
    end

    xlim([1, trange(end)])
    lg = legend([f_ref, f_c, f_modonly, f_esn, f_esnc], ...
                'perfect QG', 'confidence interval', ...
                'imperfect QG', 'ESN prediction', 'ESNc prediction',  ...
                'interpreter', 'latex', ...
                'orientation', 'vertical', 'location', 'southwest');

    trunc_stats = 20*365;
    bins = 20;

    h2 = subplot(1,3,3);
    pdf_lines = [];
    styles = {'.-', 's-','>-', 'o-'}
    ms = {9,3,3,3}
    for s = 1:numel(plot_stats)
        pdf_lines{s} = plotpdf(plot_stats{s}(trunc_stats:end), bins, ...
                               styles{s}, ...
                               'markerfacecolor', colors{s}, ...
                               'color', colors{s}, ...
                               'markersize',ms{s}, ...
                               'linewidth',1.2);
        hold on
    end
    hold off
    if strcmp(quantity{idx}, 'Km')
        ylim([0.003, 0.019]);
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

    Utils.exportfig([exportdir, 'spinup_', quantity{idx}, '.eps'], ...
                    fs, dims, invert);
end
