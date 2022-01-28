addpath('../')

if ~exist('ref_stats', 'var')
    load_qg_data
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

for qnt_idx = 1:numel(quantity)
    qnt = quantity{qnt_idx};

    % Setup bins. Go twice the standard deviation beyond the full range of
    % the reference pdf.    
    [mn_ref, mx_ref] = Utils.global_bounds(ref_stats, qnt);
    sigma = sqrt(var(ref_stats{1,1}.(qnt))); % standard deviation
    lsp = linspace(mn_ref-2*sigma, mx_ref+2*sigma, bins);
    dx = lsp(2)-lsp(1);
    lsp = [lsp-dx/2, lsp(end)+dx/2];

    [ref_pdf, cnt] = Utils.compute_pdf(ref_stats{1,1}.(qnt)(trunc:end), lsp, ...
                                       'normalization', 'probability');

    col_idx = 0;
    for d = 1:Ndirs
        [R,N] = size(stats_dkl{d});
        for j = 1:N
            col_idx = col_idx + 1;
            for i = 1:R
                if ~FLG(i, col_idx)
                    fprintf('failed run: i = %d, col_idx = %d\n', i, col_idx);
                    continue;
                end
                series = stats_dkl{d}{i,j}.(qnt)(trunc:end);
                [pdf, cnt] = Utils.compute_pdf(series, lsp, 'normalization', 'probability');
                DKL(i,col_idx) = Utils.dkl(ref_pdf', pdf', true);
            end
        end
    end
    
    figure(qnt_idx)
    clf
    p = Plot();
    p.plot_mean = false;
    p.plot_scatter = false;
    p.plot_connections = false;
    p.style = {'.', '.-', '-'};
    p.msize = {14, 14};
    p.my_boxplot(DKL(:,ORD_range));
        
    set(gca, 'yscale','log')
    set(gca, 'xticklabels', labels(ORD_range));
    xtickangle(45);
    ylabel(['$D_{KL}$, ', qntlabels{qnt_idx}], 'interpreter','latex');
    grid on
    fs = 10;
    dims = [7,15];
    invert = false;
    ylim([3*10^(-2),10^2])
    exportfig([exportdir, qnt, '.eps'], fs, dims, invert)

    clf
    p.my_boxplot(DKL(:,ROM_range));
        
    set(gca, 'yscale','log')
    set(gca, 'xticklabels', labels(ROM_range));
    xtickangle(45);
    ylabel(['$D_{KL}$, ', qntlabels{qnt_idx}], 'interpreter','latex');
    grid on
    fs = 10;
    dims = [7,15];
    invert = false;
    ylim([3*10^(-2),10^2])
    exportfig([exportdir, qnt, '_ROM.eps'], fs, dims, invert)
end
