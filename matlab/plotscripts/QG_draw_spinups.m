% coarse QG with periodic bdc
nx_c = 32;
ny_c = nx_c;
Re_c = 500;
ampl = 2; % stirring amplitude
stir = 0; % stirring type: 0 = cos(5x), 1 = sin(16x)

qg_c = QG(nx_c, ny_c, 1);
qg_c.set_par(5,  Re_c);  % Reynolds number
qg_c.set_par(11, ampl);  % stirring amplitude
qg_c.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = si

% spinup dir
folder = ['/home/erik/Projects/hybrid_om/data/QGmodel/',...
          'return_from_modelonly'];

% subfolder names
subdir_names = {dir(folder).name};

% keep everything with the correct name
subdir_names = subdir_names(contains(subdir_names, ...
                                     'spinup'));
Nsubdirs = numel(subdir_names);

% sort subdirs
subdir_indices = zeros(Nsubdirs,1);
for i = 1:Nsubdirs
    subdir_index = regexp(subdir_names{i}, 'spinup_(\d+)_', ...
                          'tokens', 'once');
    subdir_indices(i) = str2num(subdir_index{1});
end
[subdir_indices, permutation] = sortrows(subdir_indices);
subdir_names = {subdir_names{permutation}};

all_stats = cell(Nsubdirs,1);
for i = 1:Nsubdirs
    spinup_dir = [folder, '/', ...
                  subdir_names{i}, '/'];

    fprintf('%s\n', subdir_names{i})

    % get chunks:
    files = {dir(fullfile(spinup_dir, '*.mat')).name};
    Nfiles = numel(files);

    % sort chunkfiles
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

    % load data
    X = [];
    for j = 1:Nfiles
        file = [spinup_dir, '/', files{j}];
        X = [X, load(file).X];
    end

    fprintf('time steps: %d\n', size(X,2))

    % compute statistics
    opts = [];
    opts.windowsize = 50;
    allstats{i} = Utils.get_qg_statistics(qg_c, X, opts);
end
%%

for i = 1:Nsubdirs
    values = allstats{i}.Km;
    time = (1:numel(values)) / 365;
    plot(time, allstats{i}.Km);
    xlabel('years')
    hold on
end
hold off