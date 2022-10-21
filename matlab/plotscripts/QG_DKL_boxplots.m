addpath('../')

if ~exist('ref_stats', 'var')
    load_reference_solution
end

if ~exist('stats_dkl', 'var')
    load_qg_transient_data
end

% compute DKL for all PDFs for transients with truncation <trunc> and
% bins <bins>.

quantity = {'Km', 'Ke', 'Z'};
qntlabels = {'mean kinetic energy $K_m$', 'eddy kinetic energy $K_e$', 'enstrophy $Z$'};

bins = 100;

exportdir = '~/Projects/doc/mlqg/figs/QG_dkl_boxplots/';
Ndirs = numel(exp_dirs);
for qnt_idx = 1:numel(quantity)
    qnt = quantity{qnt_idx};

    % Setup bins. Go twice the standard deviation beyond the full range of
    % the reference pdf.
    [mn_ref, mx_ref] = Utils.global_bounds(ref_stats, qnt);
    sigma = sqrt(var(ref_stats{1,1}.(qnt))); % standard deviation
    lsp = linspace(mn_ref-2*sigma, mx_ref+2*sigma, bins);
    dx = lsp(2)-lsp(1);
    lsp = [lsp-dx/2, lsp(end)+dx/2];

    ref_series = ref_stats{1,1}.(qnt)(trunc:end);
    [ref_pdf, cnt] = Utils.compute_pdf(ref_series, lsp, ...
                                       'normalization', 'probability');
    col_idx = 0;

    for d = 1:Ndirs
        [R,N] = size(stats_dkl{d});
        for j = 1:N
            col_idx = col_idx + 1;
            for i = 1:R
                if ~IGN_FLG{d}(i, j)
                    fprintf('unavailable run: i = %d, col_idx = %d\n', i, col_idx);
                    continue;
                end
                if ~FLD_FLG{d}(i, j)
                    fprintf('failed run: i = %d, col_idx = %d\n', i, col_idx);
                    continue
                end

                series = stats_dkl{d}{i,j}.(qnt)(trunc:end);
                [pdf, cnt] = Utils.compute_pdf(series, lsp, 'normalization', 'probability');
                DKL{d}(i,j) = Utils.dkl(ref_pdf', pdf', true);
            end
        end
    end
    cols = [0,0,0; min(1.0*lines(20),1)];
    p = Plot();
    p.plot_mean = false;
    p.plot_scatter = false;
    p.plot_connections = true;
    p.style = {'.', '.-', '-'};
    p.msize = {14, 14};

    do_dklcomp=false
    if do_dklcomp
        figure(qnt_idx)
        clf

        sp1 = subplot(1,2,1);
        hmod  = p.my_boxplot(repmat(DKL{1}(:,1),1,3), ...
                             {cols(2,:), cols(2,:)}, ...
                             p.style, p.msize, 1); hold on
        hdmdc = p.my_boxplot(repmat(DKL{3}(:,1),1,3), ...
                             {cols(5,:), cols(5,:)}, ...
                             p.style, p.msize, 2); hold on
        hcorr = p.my_boxplot(repmat(DKL{4}(:,1),1,3), ...
                             {cols(6,:), cols(6,:)}, ...
                             p.style, p.msize, 3); hold on
        hold off
        set(gca, 'yscale','log')
        ylim([3*10^(-2),10^2])
        xticks(1:3);
        set(groot,'defaultAxesTickLabelInterpreter','latex');
        set(gca, 'xticklabels', {'imperfect QG', 'DMDc', 'correction only'});
        yticks([0.1,1,10])
        xlim([0.5,3.5])
        xtickangle(45);
        grid on
        ylabel(['$D_{KL}$, ', qntlabels{qnt_idx}], 'interpreter','latex');

        sp2 = subplot(1,2,2);

        ESN_range = 1:7;
        ESNc_range = 8:14;
        ESNDMDc_range = 15:21;

        fESNDMDc = p.my_boxplot(DKL{5}(:,ESNDMDc_range),  {cols(7,:), cols(7,:)}); hold on
        fESN     = p.my_boxplot(DKL{5}(:,ESN_range), {cols(3,:), cols(3,:)}); hold on
        fESNc    = p.my_boxplot(DKL{5}(:,ESNc_range),  {cols(4,:), cols(4,:)}); hold on

        hold off

        set(gca, 'yscale','log')
        ylim([3*10^(-2),10^2])
        set(gca, 'xticklabels', {'200','400','800','1600','3200','6400','12800'});
        xlabel('$N_r$','interpreter','latex');
        set(gca, 'yticklabels', {});
        xtickangle(45);
        grid on

        legend([fESN, fESNc, fESNDMDc], 'ESN', 'ESNc', 'ESN+DMDc', 'interpreter','latex','location','southwest')

        set(sp1,'Position', [0.13 0.195 0.13 0.78])
        set(sp2,'Position', [0.31 0.195 0.57 0.78])

        fs = 10;
        dims = [20, 8];
        invert = false;
        exportfig([exportdir, 'dkl_Nr_', quantity{qnt_idx}, '.eps'], fs, dims, invert);
    end

    %-------------------------------------------------------------------
    do_lamtest=true;
    if do_lamtest

        ESN_range=1:20;
        ESNc_range=21:40;
        DMDc_range=41:60;

        corr_range=1:20;
        ESNDMDc_range=21:40;

        z = linspace(0.05,2.7,20);
        a = z(2)-z(1);
        b = z(1)-a;
        xlabs = 0.1:0.3:2.8;
        xt = (xlabs-b)/a;

        figure(qnt_idx);
        clf
        fESN  = p.my_boxplot(DKL{6}(:,ESN_range),   {cols(3,:), cols(3,:)}); hold on
        fESNc = p.my_boxplot(DKL{6}(:,ESNc_range),  {cols(4,:), cols(4,:)}); hold on
        fDMDc = p.my_boxplot(DKL{6}(:,DMDc_range),  {cols(5,:), cols(5,:)}); hold on
        [fcorr, hcorr] = p.my_boxplot(DKL{7}(:,corr_range),  {cols(6,:), cols(6,:)}); hold on
        [fESNDMDc, hESNDMDc] = p.my_boxplot(DKL{7}(:,ESNDMDc_range),  {cols(7,:), cols(7,:)}); hold on

        uistack(hcorr,'top')
        uistack(hESNDMDc,'bottom')
        
        legend([fESN, fESNc, fDMDc, fcorr, fESNDMDc], 'ESN', 'ESNc', 'DMDc', 'correction only', 'ESN+DMDc', 'interpreter','latex','location','northeastoutside')

        set(gca, 'yscale','log')
        ylim([3*10^(-2),10^2])
        hold off
        xlabel('$\sqrt{\lambda}$','interpreter','latex');
        set(gca, 'xtick', (xt));

        xs = round(min(z),1);
        xe = round(max(z),1);
        xrange = round(z,2);
        set(gca, 'xticklabels', xlabs);

        ylabel(['$D_{KL}$, ', qntlabels{qnt_idx}], 'interpreter','latex');
        grid on

        fs = 10;
        dims = [20, 8];
        invert = false;
        exportfig([exportdir, 'dkl_lamtest_', quantity{qnt_idx}, '.eps'], fs, dims, invert);
    end

    % ------------------------------------------------------------------
    % ROM version
    do_rom=false
    if do_rom
        figure(qnt_idx)
        clf

        sp1 = subplot(1,2,1);
        hmod  = p.my_boxplot(repmat(DKL{1}(:,1),1,3), ...
                             {cols(2,:), cols(2,:)}, ...
                             p.style, p.msize, 1); hold on
        hdmdc = p.my_boxplot(repmat(DKL{3}(:,2),1,3), ...
                             {cols(5,:), cols(5,:)}, ...
                             p.style, p.msize, 2); hold on
        hcorr = p.my_boxplot(repmat(DKL{4}(:,2),1,3), ...
                             {cols(6,:), cols(6,:)}, ...
                             p.style, p.msize, 3); hold on
        hold off
        set(gca, 'yscale','log')
        ylim([3*10^(-2),10^2])
        xticks(1:3);
        set(gca, 'xticklabels', {'imperfect QG', 'DMDc, local POD', 'correction only, local POD'});
        yticks([0.1,1,10])
        xlim([0.5,3.5])
        xtickangle(45);
        grid on
        ylabel(['$D_{KL}$, ', qntlabels{qnt_idx}], 'interpreter','latex');

        sp2 = subplot(1,2,2);

        fESNDMDc = p.my_boxplot(DKL{6}(:,ESNDMDc_range),  {cols(7,:), cols(7,:)}); hold on
        fESN     = p.my_boxplot(DKL{6}(:,ESN_range), {cols(3,:), cols(3,:)}); hold on
        fESNc    = p.my_boxplot(DKL{6}(:,ESNc_range),  {cols(4,:), cols(4,:)}); hold on

        hold off

        set(gca, 'yscale','log')
        ylim([3*10^(-2),10^2])
        set(gca, 'xticklabels', {'200','400','800','1600','3200','6400','12800'});
        xlabel('$N_r$','interpreter','latex');
        set(gca, 'yticklabels', {});
        xtickangle(45);
        grid on

        legend([fESN, fESNc, fESNDMDc], 'ESN, local POD', 'ESNc, local POD', 'ESN+DMDc, local POD', ...
               'interpreter','latex','location','southwest')

        set(sp1,'Position', [0.13 0.195 0.13 0.78])
        set(sp2,'Position', [0.31 0.195 0.57 0.78])

        fs = 10;
        dims = [20, 8];
        invert = false;
        exportfig([exportdir, 'dkl_Nr_ROM_', quantity{qnt_idx}, '.eps'], fs, dims, invert);
    end
end