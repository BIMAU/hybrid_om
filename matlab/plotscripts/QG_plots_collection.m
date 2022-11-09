addpath('../');

if ~exist('preds4', 'var') || ...
        ~exist('ref_preds', 'var') || ...
        ~exist('preds', 'var') || ...
        ~exist('spinup_stats', 'var')
    load_qg_data
end
exportdir_pres = '~/Projects/doc/presentations/kitp2021/';
exportdir_papr = '~/Projects/doc/mlqg/figs/presentation/';

present_mode = false;
rom_plots = false;
if present_mode
    invert = true; % invert colors for white on black presentation
    exportdir = exportdir_pres;
else
    invert = false;
    exportdir = exportdir_papr;
end

if invert
    % start with white and make all colors brighter
    cols = [1,1,1; min(1.3*lines(20),1)];
else
    % start with black, normal brightness
    cols = [0,0,0; min(1.0*lines(20),1)];
end

%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
% % DRAW FIELDS
if present_mode
    fs = 14;
    dims = [14,12];
else
    fs = 12;
    dims = [14,12];
end

map = my_colmap(); % colormap
crange = [-0.3,0.3];

if 0
    figure(1)
    fields = {ref_preds{1,1}(round(T/2),:)', ...
              preds{1,1}(round(T/2),:)', ...
              preds{1,2}(round(T/2),:)', ...
              preds{1,3}(round(T/2),:)', ...
              preds{1,6}(round(T/2),:)'};

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
        colorbar
        caxis(crange)
        if present_mode
            axis off
            title(titles{j},'interpreter','latex')
        end
        Utils.exportfig(fnames{j}, fs, dims, invert)
    end

end

%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
% % DRAW SPECTRUM
if 0
    figure(3)
    trunc = 20*365; % truncate initial spinup

    fs = 12;
    dims = [16,10];


    spec_opts = [];
    spec_opts.windowsize = 10;
    spec_opts.trunc = trunc;
    spec_opts.skip = 90;
    spec_opts.conf_int = false;
    spec_opts.T = size(preds{1,1}(trunc:end,:),1);
    spec_opts.stircol = cols(1,:);

    [f_p, Pm_ref, Pv_ref] = p.plot_qg_mean_spectrum(qg_c, dgen.R*ref_preds{1,1}(trunc:end,:)', ...
                                                    spec_opts, '.-', 'color', cols(1,:));
    hold on
    [f_i, Pm_ref, Pv_ref, g] = p.plot_qg_mean_spectrum(qg_c, preds{1,1}(trunc:end,:)', ...
                                                      spec_opts,  '.-', 'color', cols(2,:));
    hold off
    grid on

    legend([f_p, f_i, g], 'perfect model', 'imperfect model', ...
           'stirring wavenumber',...
           'interpreter','latex', ...
           'location', 'southwest')

    if present_mode
        title('average (equilibrium) energy spectrum','interpreter','latex');
    end
    xlabel('wavenumber $\|\vec{k}\|_2$','interpreter','latex');
    set(gca,'yticklabels',[])
    set(gca,'xtick',[(3:10),15])
    ylim([1e-4,1e3])
    grid on

    Utils.exportfig([exportdir, 'motivating_powerspec.eps'], fs, dims, invert)

    %-------------------------------------------------------------------------
    clf
    [f_p, Pm_ref, Pv_ref] = p.plot_qg_mean_spectrum(qg_c, dgen.R*ref_preds{1,1}(trunc:end,:)', spec_opts, ...
                                                    '.-', 'color', cols(1,:));
    hold on
    f_ = [];

    normal = [1,2,3,6];
    local_pod = [1,14,15,18];

    range = normal;
    if rom_plots
        range = local_pod;
    end
    for j = 1:numel(range)
        [f_{range(j)}, ~, ~, g] = p.plot_qg_mean_spectrum(qg_c, preds{1,range(j)}(trunc:end,:)', ...
                                                          spec_opts,  '.-', 'color', cols(normal(j)+1,:));
        hold on
    end

    if ~rom_plots
        hold on
        spec_opts.T = size(preds2{1,1}(trunc:end,:),1);
        [f_dmdc, ~, ~, ~] = p.plot_qg_mean_spectrum(qg_c, preds4{1,2}(trunc:end,:)', ...
                                                    spec_opts,  '.-', 'color', cols(5,:));
        hold on
        spec_opts.T = size(preds2{1,1}(trunc:end,:),1);
        [f_corr, ~, ~, ~] = p.plot_qg_mean_spectrum(qg_c, preds2{1,2}(trunc:end,:)', ...
                                                    spec_opts,  '.-', 'color', cols(6,:));
    end
    hold off

    grid on
    if rom_plots
        legend([f_p, f_{range(1)}, f_{range(2)}, f_{range(3)}, f_{range(4)}, g], ...
               'perfect model', 'imperfect model', 'ESN, local POD', 'ESNc, local POD' , ...
               'ESN+DMDc, local POD', 'stirring wavenumber', ...
               'interpreter','latex','location','southwest')

    else

        legend([f_p, f_{range(1)}, f_{range(2)}, f_{range(3)}, f_{range(4)}, f_dmdc, f_corr, g], ...
               'perfect model', 'imperfect model', 'ESN', 'ESNc' , ...
               'ESN+DMDc', 'DMDc', 'correction only','stirring wavenumber', ...
               'interpreter','latex','location','southwest')
    end
    xlabel('wavenumber $\|\vec{k}\|_2$','interpreter','latex');
    set(gca,'yticklabels',[])
    set(gca,'xtick',[(3:10),15])
    grid on
    ylim([1e-4,1e3])
    if present_mode
        title('average (equilibrium) energy spectrum','interpreter','latex');
    end
    if rom_plots
        Utils.exportfig([exportdir, 'results_powerspec_rom.eps'], fs, dims, invert)
    else
        Utils.exportfig([exportdir, 'results_powerspec.eps'], fs, dims, invert)
    end
end

%%-----------------------------------------------------------------------------
% % DRAW TRANSIENTS
if 1
    fh4 = figure(4);
    fh4.Position = [100,100,1000,900];

    if present_mode
        dims = [24,15];
        fs = 9;
        bins = 20;
    else
        dims = [20,16];
        fs = 9;
        bins = 20;
    end

    start_idx = [1, 1, spec_opts.windowsize, spec_opts.windowsize, 1];
    quantity = {'E', 'Z', 'Km', 'Ke'};

    subplot(2,2,1)
    idx = 3;

    trange_0 = (start_idx(idx):size(X,2)) / 365;
    trange   = (size(X,2)+start_idx(idx):size(X,2)+size(ref_preds{1,1}, 1)) / 365;

    time_series0 = [stats_0.(quantity{idx})', ref_stats{1,1}.(quantity{idx})'];

    f_ref = plot([trange_0, trange], time_series0, '-', 'color', cols(1,:));
    hold on

    % plot confidence interval
    conf_hi = mean(time_series0) + 2*sqrt(var(time_series0));
    conf_lo = mean(time_series0) - 2*sqrt(var(time_series0));

    plot([trange_0, trange], repmat(conf_hi, 1, numel(time_series0)), '--', 'color', cols(1,:));
    f_c = plot([trange_0, trange], repmat(conf_lo, 1, numel(time_series0)), '--', 'color', cols(1,:));

    [n_shifts, n_hyp] = size(preds);
    trange = (size(X,2)+start_idx(idx):size(X,2)+size(preds{1,1}, 1)) / 365;

    time_series1 = stats{1,1}.(quantity{idx});
    f_modonly = plot(trange, time_series1, '-', 'color', cols(2,:)); hold on;

    hold off
    xmin = size(X,2)/365-20;
    xmax = size(X,2)/365+40;
    xlim([xmin,xmax])
    if ~present_mode
        xlabel('time (years)','interpreter', 'latex')
    end
    ylabel('$K_m$','interpreter', 'latex')
    set(gca, 'ytick', [])
    ylim('auto')
    ylm = ylim();
    if invert
        invertcolors()
    end
    if present_mode
        title('mean kinetic energy $K_m$', 'interpreter', 'latex')
    else

    end
    %--------------
    subplot(2,2,2)
    p1_2 = plotpdf(time_series0(trunc:end), bins, '.-', 'color', cols(1,:));
    hold on
    p2_2 = plotpdf(time_series1(trunc:end), bins, '.-', 'color', cols(2,:));
    hold on

    set(gca, 'xtick', [])
    set(gca, 'ytick', [])
    ylim(ylm);
    ylabel('$K_m$','interpreter', 'latex')
    legend([p1_2, p2_2], 'perfect model', 'imperfect model', ...
           'interpreter', 'latex','location','east')
    if present_mode
        title('equilibrium pdf estimate','interpreter', 'latex')
    end

    if invert
        invertcolors()
    end

    %-------------------------------------------------------------------------------
    subplot(2,2,3)
    idx = 4;
    trange_0 = (start_idx(idx):size(X,2)) / 365;
    trange   = (size(X,2)+start_idx(idx):size(X,2)+size(ref_preds{1,1}, 1)) / 365;

    time_series0 = [stats_0.(quantity{idx})', ref_stats{1,1}.(quantity{idx})'];

    f_ref = plot([trange_0, trange], time_series0, '-', 'color', cols(1,:));
    hold on

    % plot confidence interval
    extr_factor = 50;

    conf_hi = mean(time_series0) + 2*sqrt(var(time_series0));
    conf_lo = mean(time_series0) - 2*sqrt(var(time_series0));

    f_c = plot([trange_0, trange], repmat(conf_hi, 1, numel(time_series0)), '--', 'color', cols(1,:));
    plot([trange_0, trange], repmat(conf_lo, 1, numel(time_series0)), '--', 'color', cols(1,:));
    [n_shifts, n_hyp] = size(preds);
    trange = (size(X,2)+start_idx(idx):size(X,2)+size(preds{1,1}, 1)) / 365;

    time_series1 = stats{1,1}.(quantity{idx});
    f_modonly = plot(trange, time_series1, '-', 'color', cols(2,:)); hold on;

    hold off
    xlim([xmin,xmax])
    xlabel('time (years)','interpreter','latex')
    ylabel('$K_e$','interpreter','latex')
    if present_mode
        title('eddy kinetic energy $K_e$','interpreter','latex')
    end
    ylim('auto')
    ylm = ylim();
    set(gca, 'ytick', [])
    if invert
        invertcolors()
    end

    subplot(2,2,4)
    [hc, edg] = histcounts(time_series0(trunc:end), bins, 'normalization', 'pdf');
    edg = (edg(1:end-1)+edg(2:end))/2;
    p1_4 = plot(hc, edg, '.-', 'color', cols(1,:));
    hold on
    [hc, edg] = histcounts(time_series1(trunc:end), bins, 'normalization', 'pdf');
    edg = (edg(1:end-1)+edg(2:end))/2;
    p2_4 = plot(hc, edg, '.-', 'color', cols(2,:));
    hold on

    ylabel('$K_e$','interpreter','latex')
    ylim(ylm);
    set(gca, 'xtick', []);
    set(gca, 'ytick', []);
    if present_mode
        title('equilibrium pdf estimate','interpreter', 'latex');
    end

    if invert
        invertcolors()
    end
    Utils.exportfig([exportdir, 'motivating_transientplot.eps'], fs, dims, invert, ylm)

    %------------------------------------------------------------------
    subplot(2,2,1)
    idx = 3;

    if rom_plots
        time_series1 = stats{1,18}.(quantity{idx});
        hold on
        f_esnc = plot(trange, time_series1, '-', 'color', cols(7,:)); hold on;
    else
        time_series1 = stats{1,3}.(quantity{idx});
        hold on
        f_esnc = plot(trange, time_series1, '-', 'color', cols(4,:)); hold on;
    end

    hold off

    ylim('auto');
    ylm = ylim();

    if invert
        invertcolors()
    end

    subplot(2,2,2)
    ylim(ylm);

    if rom_plots
        plot_stats = {stats{1,14}.(quantity{idx})(trunc:end), ...
                      stats{1,15}.(quantity{idx})(trunc:end), ...
                      stats{1,18}.(quantity{idx})(trunc:end)};

    else
        plot_stats = {stats{1,2}.(quantity{idx})(trunc:end),...
                      stats{1,3}.(quantity{idx})(trunc:end),...
                      stats{1,6}.(quantity{idx})(trunc:end),...
                      stats4{1,2}.(quantity{idx})(trunc:end),...
                      stats2{1,2}.(quantity{idx})(trunc:end)};
    end

    plot_cols = {cols(3,:), ...
                 cols(4,:), ...
                 cols(7,:), ...
                 cols(5,:), ...
                 cols(6,:)};

    p3_2 = [];
    for s = 1:numel(plot_stats)
        hold on
        p3_2{s} = plotpdf(plot_stats{s}, bins, '.-', 'color', plot_cols{s});
    end
    hold off

    set(gca, 'xtick', [])

    ylabel('$K_m$','interpreter', 'latex')

    if rom_plots
        lg = legend([p1_2,p2_2, [p3_2{:}]], 'perfect model', 'imperfect model', ...
                    'ESN, local POD', 'ESNc, local POD', ...
                    'ESN+DMDc, local POD', 'interpreter', 'latex', 'location','east');
    else
        lg = legend([p1_2,p2_2, [p3_2{:}]], 'perfect model', 'imperfect model', ...
                    'ESN', 'ESNc', 'ESN+DMDc', 'DMDc', ...
                    'correction only', 'interpreter', 'latex', 'location','east');
    end

    lpos = lg.Position;
    lg.Position = [lpos(1), lpos(2)*0.95, lpos(3), lpos(4)];

    if invert
        invertcolors()
    end

    %----------------------
    subplot(2,2,3)
    idx = 4;

    if rom_plots
        hold on
        time_series1 = stats{1,18}.(quantity{idx});
        f_esnc = plot(trange, time_series1, '-', 'color', cols(7,:)); hold on;
    else
        hold on
        time_series1 = stats{1,3}.(quantity{idx});
        f_esnc = plot(trange, time_series1, '-', 'color', cols(4,:)); hold on;
    end

    hold off
    ylim('auto')
    ylm = ylim();

    if invert
        invertcolors()
    end

    subplot(2,2,4)
    if rom_plots
        plot_stats = {stats{1,14}.(quantity{idx})(trunc:end), ...
                      stats{1,15}.(quantity{idx})(trunc:end), ...
                      stats{1,18}.(quantity{idx})(trunc:end)};

    else
        plot_stats = {stats{1,2}.(quantity{idx})(trunc:end),...
                      stats{1,3}.(quantity{idx})(trunc:end),...
                      stats{1,6}.(quantity{idx})(trunc:end),...
                      stats4{1,2}.(quantity{idx})(trunc:end),...
                      stats2{1,2}.(quantity{idx})(trunc:end)};
    end

    p3_4 = [];
    for s = 1:numel(plot_stats)
        hold on
        p3_4{s} = plotpdf(plot_stats{s}, bins, '.-', 'color', plot_cols{s});
    end
    hold off

    hold off
    set(gca, 'xtick', [])
    ylabel('$K_e$','interpreter', 'latex')
    ylim(ylm);

    if invert
        invertcolors()
    end

    if rom_plots
        Utils.exportfig([exportdir, 'results_transientplot_rom.eps'], fs, dims, invert)
    else
        Utils.exportfig([exportdir, 'results_transientplot_all.eps'], fs, dims, invert)
        set(p3_2{4},'visible','off')
        set(p3_2{5},'visible','off')
        set(p3_4{4},'visible','off')
        set(p3_4{5},'visible','off')
        Utils.exportfig([exportdir, 'results_transientplot1.eps'], fs, dims, invert)

        set(p3_2{1},'visible','off')
        set(p3_2{2},'visible','off')
        set(p3_2{3},'visible','off')
        set(p3_4{1},'visible','off')
        set(p3_4{2},'visible','off')
        set(p3_4{3},'visible','off')

        set(p3_2{4},'visible','on')
        set(p3_2{5},'visible','on')
        set(p3_4{4},'visible','on')
        set(p3_4{5},'visible','on')
        Utils.exportfig([exportdir, 'results_transientplot2.eps'], fs, dims, invert)
    end
end

%-----------------------------------------------------------------------------
%-----------------------------------------------------------------------------
% % DRAW scaling experiments

if 0
    figure(5)

    gridexp_p.plot_mean = false;
    gridexp_p.plot_scatter = false;

    [nums,mdat,~,~,f] = gridexp_p.plot_experiment(false, false);
    Utils.create_description(mdat)
    legend([f{:}], 'imperfect model', 'ESN', 'ESNc', 'DMDc', ...
           'correction only', 'ESN+DMDc', 'interpreter', 'latex','location','northwest')
    ylabel('accurate days', 'interpreter', 'latex')
    if present_mode
        xlabel('ESN state size $N_r$', 'interpreter', 'latex')
        fs = 10;
        dims = [19,12];
    else
        xlabel('$N_r$', 'interpreter', 'latex')
        fs = 14;
        dims = [18,14];
    end
    title('');
    Utils.exportfig([exportdir, 'results_gridexp.eps'], fs, dims, invert)
end

if 0
    figure(6)

    romexp_p.plot_mean = false;
    romexp_p.plot_scatter = false;

    [~,~,~,~,f] = romexp_p.plot_experiment(false, false);

    fs = 10;
    dims = [19,12];
    legend([f{:}], 'ESNc, no scale separation, no reduction', 'ESNc, wavelet', 'ESNc, POD', 'ESNc, local POD', ...
           'interpreter', 'latex','location','northwest')
    ylabel('accurate days', 'interpreter', 'latex')
    xlabel('ESN state size $N_r$', 'interpreter', 'latex')
    title('');
    Utils.exportfig([exportdir, 'results_romexp.eps'], fs, dims, invert)
end