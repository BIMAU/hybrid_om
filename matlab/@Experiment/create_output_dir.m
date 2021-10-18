function [] = create_output_dir(self)
    if self.procs > 1
        run_type = 'parallel';
    else
        run_type = 'serial';
    end

    ctrlpar_str = sprintf('_param_%1.2e', self.model.control_param());
    self.output_dir = sprintf([self.data.base_dir, '/data/experiments/%s/%s%s%s/'], ...
                              self.ident, self.name, run_type, ctrlpar_str);
    
    eval(['mkdir ', self.output_dir]);
end