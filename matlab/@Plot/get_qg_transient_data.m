function [nums, mdat, preds, truths, s] = get_qg_transient_data(self, opts)
    [errs, nums, pids, mdat, preds, truths] = ...
        self.gather_data(self.dir);

    [T,n] = size(preds{1,1});

    % When we compute coarse quantities with fine data:
    if n ~= opts.nx*opts.ny*opts.nun
        restrict_preds = true;
        assert(isfield(opts,'R'), 'no restriction operator given in opts');
        R = opts.R;
    else
        restrict_preds = false;
        R = speye(n,n);
    end

    qg = QG(opts.nx, opts.ny, 1); % QG with periodic bdc
    qg.set_par(5, opts.Re); % Reynolds number for coarse model
    qg.set_par(18, opts.stir); % Stirring type: 0 = cos(5x), 1 = sin(16x)
    qg.set_par(11, opts.ampl); % Stirring amplitude

    [n_shifts, n_hyp] = size(preds);
    s = cell(n_shifts, n_hyp);

    % get all statistics
    for j = 1:n_hyp
        for i = 1:n_shifts
            fprintf('Getting statistics, shift: %d/%d, hyp: %d/%d\n', i, n_shifts, j, n_hyp);
            if ~isempty(preds{i,j})
                s{i,j} = Utils.get_qg_statistics(qg, R*preds{i, j}', opts);
            end
        end
    end
end