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
    Np = numel(pairs);
    for i = 1:Np
        var = pairs{i}{1};
        eval([var, ' = pairs{i}{2};'])
        fprintf(' %s', var)
        if (i == 1)
            save(fname, var)
        else
            save(fname, var, '-append')
        end
    end
    fprintf('\n\n')
end