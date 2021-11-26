function [errs, nums, pids, ...
          metadata, predictions, ...
          truths] = gather_data(self, varargin)

    switch nargin
      case 2
        dir = varargin{1};
        assert(exist(dir) == 7, ...
               'experiment directory does not exist');

        % number of procs = number of files in dir:
        [~, fc] = system(['ls ', dir, ' -1 | grep mat | wc -l']);
        procs = str2num(fc);

      case 3
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
        fprintf('loading %s\n', fileNames{d});
        data = load(fileNames{d});
        time = toc;
        fprintf('loading %s done (%fs) \n', fileNames{d}, time);

        if initialize
            [n_ens, n_hyps] = size(data.num_predicted);

            errs = cell(n_ens, n_hyps);
            pids = cell(n_ens, n_hyps);

            predictions = cell(n_ens, n_hyps);
            truths = cell(n_ens, n_hyps);
            nums = nan(n_ens, n_hyps);

            initialize = false;
        end

        for i = data.my_inds
            for j = data.my_hyps
                errs{i, j} = data.errs{i, j};
                pids{i, j} = d;

                predictions{i, j} = data.predictions{i, j};
                truths{i, j}      = data.truths{i, j};

                num = data.num_predicted(i, j);
                if num > 0
                    nums(i, j) = num;
                end
            end
        end
    end

    assert(i == size(data.num_predicted, 1), ...
           'failed assertion, probably wrong procs');
    % export additional labels for plotting
    metadata = struct();
    importlabs = {'xlab', ...
                  'ylab', ...
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