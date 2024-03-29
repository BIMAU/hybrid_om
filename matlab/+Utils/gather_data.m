function [errs, nums, pids, ...
          metadata, predictions, corrections...
          truths, spectra, stats] = gather_data(varargin)

    switch nargin
      case 1
        dir = varargin{1};
        assert(exist(dir) == 7, ...
               'experiment directory does not exist');

        % number of procs = number of files in dir:
        [~, fc] = system(['ls ', dir, ' -1 | grep [^k].mat | wc -l']);
        procs = str2num(fc);

      case 2
        dir = varargin{1};
        procs = varargin{2};

      otherwise
        error('Unexpected input');
    end

    if procs > 1
        serial = false;
    else
        serial = true;
    end

    fileNames = cell(procs,1);

    if serial
        fileNames{1} = sprintf([dir, 'results.mat']);
    else
        for i = 1:procs
            fileNames{i} = sprintf([dir, 'results_%d.mat'], i-1);
            if ~exist(fileNames{i}, 'file')
                fprintf('%s does not exist\n', fileNames{i});
                fileNames{i} = 'failedproc';
            end
        end
    end

    initialize = true;
    for d = 1:procs
        if strcmp(fileNames{d}, 'failedproc')
            continue;
        end

        tic
        fprintf('loading %s / %d\n', fileNames{d}, procs);
        data = load(fileNames{d});
        time = toc;
        fprintf('loading %s done (%fs) \n', fileNames{d}, time);

        if initialize
            [n_ens, n_hyps] = size(data.num_predicted);

            errs = cell(n_ens, n_hyps);
            pids = nan(n_ens, n_hyps);

            predictions = cell(n_ens, n_hyps);
            corrections = cell(n_ens, n_hyps);
            truths = cell(n_ens, n_hyps);
            stats = cell(n_ens, n_hyps);
            spectra = cell(n_ens, n_hyps, 4); % contains Pm, Pv, Qm, Qv
            nums = nan(n_ens, n_hyps);

            initialize = false;
        end

        % backward compatibility
        if isfield(data, 'my_hyps')
            j_range = data.my_hyps;
        else
            j_range = 1:n_hyps;
        end

        if isfield(data, 'my_reps_hyps')
            % new parallelization:
            idx_set = data.my_reps_hyps;
        else
            % old parallelization:
            idx_set = combvec(data.my_inds, j_range)';
        end

        for k = 1:size(idx_set,1)
            if isfield(data, 'hyps_first') && data.hyps_first
                i = idx_set(k,2);
                j = idx_set(k,1);
            else
                i = idx_set(k,1);
                j = idx_set(k,2);
            end

            errs{i, j} = data.errs{i, j};
            pids(i, j) = d;

            predictions{i, j} = data.predictions{i, j};
            if isfield(data, 'corrections')
                corrections{i, j} = data.corrections{i, j};
            end
            truths{i, j} = data.truths{i, j};

            if isfield(data, 'stats') && ...
                    isfield(data, 'spectra')
                spectra{i, j, 1} = data.spectra{i, j, 1};
                spectra{i, j, 2} = data.spectra{i, j, 2};

                if size(data.spectra, 3) == 4
                    spectra{i, j, 3} = data.spectra{i, j, 3};
                    spectra{i, j, 4} = data.spectra{i, j, 4};
                end

                stats{i, j} = data.stats{i, j};
            end

            num = data.num_predicted(i, j);
            if num > 0 && errs{i,j}(end) ~= 999
                nums(i, j) = num;
            end

        end
    end

    % export additional labels for plotting
    metadata = struct();
    importlabs = {'xlab',...
                  'ylab',...
                  'hyp_range',...
                  'hyp',...
                  'exp_id',...
                  'exp_ind',...
                  'esn_on',...
                  'model_on',...
                  'esn_pars',...
                  'damping',...
                 };

    for l = 1:numel(importlabs)
        lab = importlabs{l};
        if isfield(data, lab)
            metadata.(lab) = data.(lab);
        end
    end
end