function [] = add_field_to_memory(self, name, field)
    wsize = self.windowsize;

    if isfield(self.memory, name)
        % append to mem
        self.memory(name) = [self.memory(name), field];

        % retain max windowsize fields
        memsize = size(self.memory(name), 2);
        self.memory(name) = ...
            self.memory(name)(:, max(1,memsize-wsize+1):memsize);
    else
        % create field
        self.memory(name) = field;
    end
end