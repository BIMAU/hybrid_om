function create_descriptors(self)
    self.hyp_ids = fieldnames(self.hyp);    

    self.exp_ind    = [];
    self.file_descr = [];

    for i = 1:numel(self.exp_id)
        self.exp_ind{i}    = self.id2ind(self.hyp_ids, self.exp_id{i});
        self.file_descr{i} = self.hyp.(self.exp_id{i}).descr;
    end

    assert(~isempty(self.exp_ind));

    self.name = [[self.file_descr{:}], ...
                 'ESN', num2str(self.esn_on), '_', ...
                 'MDL', num2str(self.model_on)];    
    
    self.print(' name: %s\n', self.name)
end