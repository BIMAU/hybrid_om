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
bins = 100;

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
    p.my_boxplot(DKL(:,ORD_range));
    set(gca, 'yscale','log')
    set(gca, 'xticklabels', labels(ORD_range));
    xtickangle(45);
    title(qnt)
    ylabel('DKL')
    grid on
end
