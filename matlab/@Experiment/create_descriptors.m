function create_descriptors(self)
    id2ind = @ (str) find(strcmp(self.hyp_ids, str));

    self.hyp_ids    = fieldnames(self.hyp);
    self.exp_ind    = [];
    self.file_descr = [];

    for i = 1:numel(self.exp_id)
        self.exp_ind{i}    = id2ind(self.exp_id{i});
        self.file_descr{i} = self.hyp.(self.exp_id{i}).descr;
    end

    assert(~isempty(self.exp_ind));

    self.name = [[self.file_descr{:}], ...
                 'ESN', num2str(self.esn_on), '_', ...
                 'MDL', num2str(self.model_on)];    
end