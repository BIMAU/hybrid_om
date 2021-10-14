function [dir] = store_results(self, pairs)
    assert(~isempty(self.output_dir), 'output dir not set');
    if self.procs > 1
        fname = sprintf('%sresults_%d.mat', self.output_dir, self.pid);
    else
        fname = sprintf('%sresults.mat', self.output_dir);
    end
    fprintf('  saving results to %s\n', fname);
    Utils.save_pairs(fname, pairs);
end