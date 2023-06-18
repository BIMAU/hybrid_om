if ~exist('ref_stats', 'var')
    load_reference_spinup
end

qg_c = Utils.create_coarse_QG();

cols = [0,0,0; lines(3)];
colors = {cols(1,:), ...
          cols(2,:), ...
          cols(3,:), ...
          cols(4,:)};

% spinup dir
folder_base = ['/home/erik/Projects/hybrid_om/data/QGmodel/', ...
               'return_from_'];

originsMap = struct();
originsMap.modelonly = struct('name', 'spinups initialized with imperfect QG predictions', ...
                              'color', colors{2});
originsMap.esnc = struct('name', 'spinups initialized with ESNc predictions', ...
                         'color', colors{4});

% options for statistics calculations
opts = [];
opts.windowsize = 50;

keys = fieldnames(originsMap);
for kidx = 1:numel(keys)
    key = keys{kidx};
    folder = [folder_base, key];

    % subfolder names
    subdir_names = {dir(folder).name};

    % keep everything with the correct name
    subdir_names = subdir_names(contains(subdir_names, ...
                                         'spinup'));

    % sort subdirs
    subdir_names = sort_subdirs(subdir_names);

    Nsubdirs = numel(subdir_names);
    all_stats = cell(Nsubdirs,1);
    for i = 1:Nsubdirs
        spinup_dir = [folder, '/', ...
                      subdir_names{i}, '/'];

        fprintf('%s\n', subdir_names{i})

        % get chunks:
        files = {dir(fullfile(spinup_dir, '*.mat')).name};
        
        % sort chunk files
        [files, chunks] = sort_chunkfiles(files, spinup_dir);
        
        % load data
        X = [];
        for j = 1:numel(files)
            file = [spinup_dir, '/', files{j}];
            X = [X, load(file).X];
        end

        fprintf('time steps: %d\n', size(X,2))

        % compute statistics
        allstats{kidx, i} = Utils.get_qg_statistics(qg_c, X, opts);
    end
    %%

end

set(groot,'defaultAxesTickLabelInterpreter','latex');
quantity = 'Km';

idxMap.E = 0;
idxMap.Z = 0;
idxMap.Km = opts.windowsize;
idxMap.Ke = opts.windowsize;

ylbls.E = '$E$';
ylbls.Z = '$Z$';
ylbls.Km = '$K_m$';
ylbls.Ke = '$K_e$';

% Confidence interval for the reference run
tserie_full = ref_stats.(quantity);
trunc_ref = 50*365;
mn = mean(tserie_full(trunc_ref:end));
vr = var(tserie_full(trunc_ref:end));
conf_hi = mn + 2*sqrt(vr);
conf_lo = mn - 2*sqrt(vr);

legnames = {};
for kidx = 1:numel(keys)
    key = keys{kidx};
    for i = 1:Nsubdirs
        values = allstats{kidx, i}.(quantity);
        time = (idxMap.(quantity) + (1:numel(values)) ) / 365;
        p(kidx) = plot(time, values, ...
                       'color', originsMap.(key).color);
        % p(kidx) = plot(time, values);
        xlabel('years');
        ylabel(ylbls.(quantity), 'interpreter', 'latex');
        xlabel('time (years)', 'interpreter', 'latex');
        hold on
    end
    legnames = [legnames, originsMap.(key).name];
end

if strcmp(quantity, 'Km')
    ylim([0.003, 0.025]);
    xlim([opts.windowsize/365, 40]);
end

f_c = plot(xlim(), [conf_hi, conf_hi], ...
           '--', 'color', cols(1,:));
f_c = plot(xlim(), [conf_lo, conf_lo], ...
           '--', 'color', cols(1,:));

legnames = [legnames, 'confidence interval (original perfect QG spinup)'];

legend([p, f_c], legnames, ...
       'interpreter', 'latex', ...
       'orientation', 'vertical', 'location', 'southeast');
hold off

% exporting
fs = 10;
dims = [24, 10];
exportdir = '~/Projects/doc/mlqg/figs/QG_transients/';
Utils.exportfig([exportdir, 'returnspinups_', ...
                 quantity, '.eps'], ...
                fs, dims, invert);

%-------------------------------------------------------
% supporting functions

function [subdir_names] = sort_subdirs(subdir_names)
    Nsubdirs = numel(subdir_names);
    subdir_indices = zeros(Nsubdirs,1);
    for i = 1:Nsubdirs
        subdir_index = regexp(subdir_names{i}, 'spinup_(\d+)_', ...
                              'tokens', 'once');
        subdir_indices(i) = str2num(subdir_index{1});
    end
    [subdir_indices, permutation] = sortrows(subdir_indices);
    subdir_names = {subdir_names{permutation}};
end

function [files, chunks] = sort_chunkfiles(files, spinup_dir)
% sort chunkfiles
    Nfiles = numel(files);
    chunks = zeros(Nfiles,2);
    for j = 1:Nfiles
        file = [spinup_dir, '/', files{j}];
        chunk_first = regexp(file, 'chunk_(\d+)-', ...
                             'tokens', 'once');
        chunk_last = regexp(file, '-(\d+).mat', ...
                            'tokens', 'once');
        chunks(j,1) = str2num(chunk_first{1});
        chunks(j,2) = str2num(chunk_last{1});
    end
    [chunks, permutation] = sortrows(chunks);
    files = {files{permutation}};
end

