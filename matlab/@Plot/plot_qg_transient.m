function [nums, mdat, preds, truths, s] = plot_qg_transient(self, opts)
    [errs, nums, pids, mdat, preds, truths] = ...
        self.gather_data(self.dir);

    qg = QG(opts.nx, opts.ny, 1); % QG with periodic bdc
    qg.set_par(5, opts.Re); % Reynolds number for coarse model
    qg.set_par(18, opts.stir); % stirring type: 0 = cos(5x), 1 = sin(16x)
    qg.set_par(11, opts.ampl); % stirring amplitude
    
    [n_shifts, n_hyp] = size(preds);
    s = cell(n_shifts, n_hyp);
    
    % get all statistics
    for j = 1:n_hyp
        for i = 1:n_shifts
            fprintf('Getting statistics, shift: %d, hyp: %d\n', i, j);
            s{i,j} = self.get_qg_statistics(qg, preds{i, j}', opts)
        end
    end
end