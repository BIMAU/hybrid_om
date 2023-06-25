addpath('../')

if ~exist('ref_stats', 'var')
    load_reference_spinup
end

load_allstats=false;
allstats_file = '/home/erik/Projects/hybrid_om/data/QGmodel/spinup_stats.mat';
if load_allstats
    allstats = load(allstats_file);
end

if exist('allstats', 'var')
    % update only
    use_all_chunks = false
else
    use_all_chunks = true
end

qg_c = Utils.create_coarse_QG();

cols = [0,0,0; lines(10)];
colors = {}
for c = 1:size(cols,1)
    colors = [colors, cols(c,:)];
end

% spinup dir
folder_base = ['/home/erik/Projects/hybrid_om/data/QGmodel/', ...
               'return_from_'];

originsMap = struct();

originsMap.noise = struct('name', 'spinups from random initialization', ...
                          'simplename', 'noise', ...
                          'color', colors{8});
originsMap.modelonly = struct('name', 'spinups initialized with imperfect QG predictions', ...
                              'simplename', 'imperfect QG', ...
                              'color', colors{2});
originsMap.dmdc = struct('name', 'spinups initialized with DMDc predictions', ...
                         'simplename', 'DMDc', ...
                         'color', colors{5});
originsMap.corr = struct('name', 'spinups initialized with correction only predictions', ...
                         'simplename', 'correction only', ...
                         'color', colors{6});
originsMap.esn = struct('name', 'spinups initialized with ESN predictions', ...
                        'simplename', 'ESN', ...
                        'color', colors{3});
originsMap.esnc = struct('name', 'spinups initialized with ESNc predictions', ...
                         'simplename', 'ESNc', ...
                         'color', colors{4});
originsMap.esndmdc = struct('name', 'spinups initialized with ESN+DMDc predictions', ...
                            'simplename', 'ESN+DMDc', ...
                            'color', colors{7});

% options for statistics calculations
opts = [];
opts.windowsize = 50;

stat_keys = {'E', 'Z', 'Km', 'Ke'};

compensate.E = opts.windowsize;
compensate.Z = opts.windowsize;
compensate.Km = 0;
compensate.Ke = 0;

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
    for i = 1:Nsubdirs
        spinup_dir = [folder, '/', ...
                      subdir_names{i}, '/'];

        fprintf('%s\n', folder)
        fprintf('  %s\n', subdir_names{i})

        % get chunks:
        files = {dir(fullfile(spinup_dir, '*.mat')).name};

        % sort chunk files
        [files, chunks] = sort_chunkfiles(files, spinup_dir);

        % load data
        X = [];
        save_stats.Nfiles = numel(files);

        fprintf('#files: %d\n', numel(files))
        if numel(files) == 40 ...
                && exist('allstats', 'var') ...
                && kidx <= size(allstats,1) ...
                && numel(allstats{kidx, i}) > 0 ...
                && numel(allstats{kidx, i}.E) == 365*40
            % skip when we already have allstats for this spinup
            
            fprintf('numel(allstats{kidx, i}.E): %d\n', ...
                    numel(allstats{kidx, i}.E))
            continue
        end

        fprintf('loading X\n')
        for j = 1:min(numel(files),40)
            file = [spinup_dir, '/', files{j}];
            X = [X, load(file).X];
        end

        fprintf('time steps: %d\n', size(X,2))
        % compute statistics

        % compute statistics
        if use_all_chunks || kidx > size(allstats,1) || numel(allstats{kidx, i}) == 0
            stats = Utils.get_qg_statistics(qg_c, X, opts);
            for k = 1:numel(stat_keys)
                key = stat_keys{k};
                save_stats.(key) = stats.(key);
            end
            allstats{kidx, i} = save_stats;
        else
            % some logic to not compute to often TODO
            fprintf('computing only newly avaible statistics\n');
            old_stats = allstats{kidx, i};
            old_Nsamples = numel(old_stats.E);

            if old_Nsamples < size(X, 2)
                % reduce X
                X = X(:, old_Nsamples - opts.windowsize + 1 : end);
                new_stats = Utils.get_qg_statistics(qg_c, X, opts);
                for k = 1:numel(stat_keys)
                    key = stat_keys{k};
                    stats.(key) = [old_stats.(key); ...
                                   new_stats.(key)(compensate.(key)+1:end)];
                end
                allstats{kidx, i} = stats;
            end
        end
    end
    %%
end

save(allstats_file, 'allstats');

QG_draw_spinups

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
