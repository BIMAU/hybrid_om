function [dir] = store_results(self, pairs)
    if self.procs > 1
        run_type = 'parallel';
    else
        run_type = 'serial';
    end

    ctrlpar_str = sprintf('_param_%1.2e', self.model.control_param());
    dir = sprintf([self.data.base_dir, '/data/experiments/%s/%s%s%s/'], ...
                  self.ident, self.name, run_type, ctrlpar_str);

    syscall = sprintf('mkdir -p %s', dir);
    system(syscall);

    if strcmp(run_type, 'parallel')
        fname = sprintf('%sresults_%d.mat', dir, self.pid);
    elseif strcmp(run_type, 'serial')
        fname = sprintf('%sresults.mat', dir);
    end

    fprintf('  saving results to %s\n', fname);
    Utils.save_pairs(fname, pairs);
end