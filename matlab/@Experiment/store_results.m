function [] = store_results(self, pairs)
    if self.procs > 1
        run_type = 'parallel';
    else
        run_type = 'serial';
    end

    path = sprintf('../data/experiments/%s_%s', self.name, run_type);
    syscall = sprintf('mkdir -p %s', path);
    system(syscall);

    if strcmp(run_type, 'parallel')
        fname = sprintf('%s/results_%d.mat', path, self.pid);
    elseif strcmp(run_type, 'serial')
        fname = sprintf('%s/results.mat', path);
    end

    fprintf('saving results to %s\n', fname);
    
    self.data.save_pairs(fname, pairs);
end