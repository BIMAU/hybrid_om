function [nums, mdat, preds, truths] = plot_qg_transient(self, opts)
    [errs, nums, pids, mdat, preds, truths] = ...
        self.gather_data(self.dir);
    
    qg = QG(opts.nx, opts.ny, 1);  % QG with periodic bdc
    qg.set_par(5,  opts.Re);   % Reynolds number for coarse model
    qg.set_par(18, opts.stir); % stirring type: 0 = cos(5x), 1 = sin(16x)
    qg.set_par(11, opts.ampl); % stirring amplitude

    
end