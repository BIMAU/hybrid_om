function [] = add_field_to_memory(self, name, field)
    wsize = self.nrmse_windowsize;

    if isfield(self.nrmse_memory, name)
        % append to mem
        self.nrmse_memory.(name) = [self.nrmse_memory.(name), field];
        
        % retain max windowsize fields
        memsize = size(self.nrmse_memory.(name), 2);
        self.nrmse_memory.(name) = ...
            self.nrmse_memory.(name)(:, max(1,memsize-wsize+1):memsize);
    else
        % create field
        self.nrmse_memory.(name) = field;
    end
end