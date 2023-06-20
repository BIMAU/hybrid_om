addpath('../')

if ~exist('ref_stats', 'var')
    load_reference_spinup
end

if exist('allstats', 'var')
    % update only
    use_all_chunks = false
else
    use_all_chunks = true
end

qg_c = Utils.create_coarse_QG();

cols = [0,0,0; lines(5)];
colors = {cols(1,:), ...
          cols(2,:), ...
          cols(3,:), ...
          cols(4,:), ...
          cols(5,:), ...
          cols(6,:), ...
         };

% spinup dir
folder_base = ['/home/erik/Projects/hybrid_om/data/QGmodel/', ...
               'return_from_'];

originsMap = struct();

originsMap.noise = struct('name', 'spinups from random initialization', ...
                              'color', colors{5});
originsMap.modelonly = struct('name', 'spinups initialized with imperfect QG predictions', ...
                              'color', colors{2});
originsMap.esn = struct('name', 'spinups initialized with ESN predictions', ...
                        'color', colors{3});
originsMap.esnc = struct('name', 'spinups initialized with ESNc predictions', ...
                         'color', colors{4});

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
        for j = 1:numel(files)
            file = [spinup_dir, '/', files{j}];
            X = [X, load(file).X];
        end

        fprintf('time steps: %d\n', size(X,2))
        % compute statistics


        % compute statistics
        if use_all_chunks
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

set(groot,'defaultAxesTickLabelInterpreter','latex');
% quantities = {'Km', 'Ke', 'Z'};
quantities = {'Km'};
plot_types = {'density', 'lines'};

for qu = 1:numel(plot_types)
    plot_type = plot_types{qu};
    quantity = quantities{1};
    clf()
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
        values = nan(Nsubdirs, 365*40);
        for i = 1:Nsubdirs
            stst = allstats{kidx, i}.(quantity);
            values(i,1:numel(stst)) = stst;
        end

        time = (idxMap.(quantity) + (1:size(values,2)) ) / 365;

        subplot(2,2,kidx)
        if strcmp(plot_type, 'density')
        
        
            T = repmat(time,50,1);
            nbins = 100;

            Tbins = linspace(min(T(:)), max(T(:)), nbins);
            Vbins = linspace(0, 0.025, nbins);

            h = hist3( [T(:), values(:)], ...
                       'ctrs', {Tbins',  Vbins'});


            imagesc( Tbins, Vbins, h');
            my_colmap = [1,1,1; summer(128)];

            colormap(my_colmap);
            caxis([0,700]);

            set(gca,'ydir','normal')
            
        elseif strcmp(plot_type, 'lines')

            handles = my_plot(time, values, ...
                              'color', originsMap.(key).color, ...
                              'linewidth', 0.1);

            p(kidx) = handles(1);
            legnames = [legnames, originsMap.(key).name];
        end
        hold on

        xlabel('years');
        ylabel(ylbls.(quantity), 'interpreter', 'latex');
        xlabel('time (years)', 'interpreter', 'latex');
        f_c = plot(xlim(), [conf_hi, conf_hi], ...
                   '--', 'color', cols(1,:), 'linewidth',1.8);
        f_c = plot(xlim(), [conf_lo, conf_lo], ...
                   '--', 'color', cols(1,:), 'linewidth',1.8);

        if strcmp(quantity, 'Km')
            ylim([0.003, 0.025]);
        end
        xlim([opts.windowsize/365, 40]);

        grid on
        hold off
    end

    legnames = [legnames, 'confidence interval (reference QG)'];

    sp = subplot(2,2,3);
    if strcmp(plot_type, 'lines')
        legend(sp, [p, f_c], legnames, ...
               'interpreter', 'latex', ...
               'orientation', 'vertical', 'location', 'best');
    elseif strcmp(plot_type, 'density')
        legend(sp, [f_c], legnames, ...
               'interpreter', 'latex', ...
               'orientation', 'vertical', 'location', 'best');
    end

    % exporting
    fs = 10;
    dims = [25, 21];
    invert = false;
    exportdir = '~/Projects/doc/mlqg/figs/QG_transients/';
    Utils.exportfig([exportdir, 'returnspinups_', ...
                     quantity, '_', plot_type, '.png'], ...
                    fs, dims, invert);
end
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
