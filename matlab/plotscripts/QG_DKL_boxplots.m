addpath('../')

if ~exist('ref_stats', 'var')
    load_qg_data
end

base_dir = '~/Projects/hybrid_om/data/experiments/';
exp_dirs = [];
exp_dirs{1} = 'QG_transient_modelonly/MC_1-1_SC_1-1_parallel_param_5.00e+02/'; %model only
exp_dirs{2} = 'QG_transient_ESN_Lambda1/MC_2-8_SC_1-5_parallel_param_5.00e+02/'; %ESN models
exp_dirs{3} = 'QG_transient_modelonly/MC_5-5_SC_1-5_parallel_param_5.00e+02/'; %DMDc
exp_dirs{4} = 'QG_transient_corr/MC_6-6_SC_1-5_parallel_param_5.00e+02/'; %corr

nums_dkl = [];
mdat_dkl = [];
spectra_dkl = [];
stats_dkl = [];

% load transient data
DKL = [];
FLG = [];
Ndirs = numel(exp_dirs);
for i = 1:Ndirs;

    [~, nums_dkl{i}, ~, ...
     mdat_dkl{i}, ~, ~, ...
     spectra_dkl{i}, ...
     stats_dkl{i}] = Utils.gather_data([base_dir, exp_dirs{i}]);

    [R, N] = size(nums_dkl{i});
    trunc = 20*365;

    % R should be equal in the experiments
    DKL = [DKL, zeros(R,N)];

    % setup flags to identify failed transients
    [mn, mx, ign] = Utils.global_bounds(stats_dkl{i}, 'Km');
    flags = logical(ones(R,N));
    for i = 1:size(ign,1)
        flags(ign(i,1),ign(i,2))=0;
    end

    FLG = [FLG, flags];
end

% ---
quantity = {'E', 'Z', 'Km', 'Ke'};
bins = 100;

for qnt_idx = 1:4
    qnt = quantity{qnt_idx};

    % setup bins
    [mn_ref, mx_ref] = Utils.global_bounds(ref_stats, qnt);
    sigma = sqrt(var(ref_stats{1,1}.(qnt)));
    lsp = linspace(mn_ref-2*sigma, mx_ref+2*sigma, bins);
    dx = lsp(2)-lsp(1);
    lsp = [lsp-dx/2, lsp(end)+dx/2];

end
