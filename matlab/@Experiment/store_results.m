function [dir] = store_results(self, pairs)
    if self.procs > 1
        run_type = 'parallel';
    else
        run_type = 'serial';
    end

    dir = sprintf([self.data.base_dir, '/data/experiments/%s/%s%s/'], ...
                  self.ident, self.name, run_type);
    
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