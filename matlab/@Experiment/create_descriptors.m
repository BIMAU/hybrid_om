function create_descriptors(self)
% create descriptors exp_ind, file_descr and name
    self.hyp_ids = fieldnames(self.hyp);

    self.exp_ind    = [];
    self.file_descr = [];

    for i = 1:numel(self.exp_id)
        self.exp_ind{i}    = self.id2ind(self.hyp_ids, self.exp_id{i});
        self.file_descr{i} = self.hyp.(self.exp_id{i}).descr;
    end

    assert(~isempty(self.exp_ind));

    self.name = [[self.file_descr{:}]];
    self.print(' name: %s\n', self.name)
end