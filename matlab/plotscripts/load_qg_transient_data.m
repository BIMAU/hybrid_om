base_dir = '~/Projects/hybrid_om/data/experiments/';

exp_dirs = [];
exp_dirs{1} = 'QG_transient_modelonly/MC_1-1_SC_1-1_parallel_param_5.00e+02/'; %model only
exp_dirs{2} = 'QG_transient_ESN_Lambda1/MC_2-8_SC_1-5_parallel_param_5.00e+02/'; %ESN models
exp_dirs{3} = 'QG_transient_modelonly/MC_5-5_SC_1-5_parallel_param_5.00e+02/'; %DMDc
exp_dirs{4} = 'QG_transient_corr/MC_6-6_SC_1-5_parallel_param_5.00e+02/'; %corr
exp_dirs{5} = 'QG_transient_ESN/MC_2-8_NR_200-12800_parallel_param_5.00e+02/'; %ESN NR exp

% What's inside the exp_dirs, in the correct order
labels = {'model only', ...
          'ESN', ...
          'ESNc', ...
          'ESN+DMDc', ...
          'ESN (ROM)', ...
          'ESNc (ROM)',...
          'ESN+DMDc (ROM)', ...
          'DMDc', ...
          'DMDc (ROM)', ...
          'correction only', ...
          'correction only (ROM)'};

ORD_range = [1,2,3,8,10,4];
ROM_range = [1,5,6,9,11,7];

errs_dkl = [];
nums_dkl = [];
pids_dkl = [];
mdat_dkl = [];
spectra_dkl = [];
stats_dkl = [];
opts_dkl  = [];
preds_dkl = [];

% load transient data
DKL = [];
IGN_FLG = []; % ignore flags
FLD_FLG = []; % failed flags

Ndirs = numel(exp_dirs);
descr_string = [];

for d = 1:Ndirs

    if d == 5 %% HACK FIXME FIXME
        [errs_dkl{d}, nums_dkl{d}, pids_dkl{d}, ...
         mdat_dkl{d}, preds_dkl{d}, ~, ...
         spectra_dkl{d}, ...
         stats_dkl{d}] = Utils.gather_data([base_dir, exp_dirs{d}],50);
    else
        [errs_dkl{d}, nums_dkl{d}, pids_dkl{d}, ...
         mdat_dkl{d}, preds_dkl{d}, ~, ...
         spectra_dkl{d}, ...
         stats_dkl{d}] = Utils.gather_data([base_dir, exp_dirs{d}]);
    end

    [~, ~, ~, ~, ~, opts_dkl{d}] = Utils.unpack_metadata(mdat_dkl{d});
    descr_string = [descr_string, opts_dkl{d}];

    [R, N] = size(nums_dkl{d});
    trunc = 20*365;

    % R should be equal in the experiments
    DKL{d} = nan(R,N);

    % setup flags to identify failed transients
    [mn, mx, ign, fld] = Utils.global_bounds(stats_dkl{d}, 'Km');
    ign_flags = logical(ones(R,N));
    for i = 1:size(ign,1)
        ign_flags(ign(i,1),ign(i,2))=0;
    end
    IGN_FLG{d} = ign_flags;

    fld_flags = logical(ones(R,N));
    for i = 1:size(fld,1)
        fld_flags(fld(i,1),fld(i,2))=0;
    end
    FLD_FLG{d} = fld_flags;
end