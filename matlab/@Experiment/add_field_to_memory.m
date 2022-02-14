function [] = add_field_to_memory(self, name, field)
    wsize = self.error_windowsize;

    if isfield(self.error_memory, name)
        % append to mem
        self.error_memory.(name) = [self.error_memory.(name), field];
        
        % retain max windowsize fields
        memsize = size(self.error_memory.(name), 2);
        self.error_memory.(name) = ...
            self.error_memory.(name)(:, max(1,memsize-wsize+1):memsize);
    else
        % create field
        self.error_memory.(name) = field;
    end
end