function create_workspace(self)
% The core experiment is repeated with <reps>*<shifts> realizations of
% the network. The range of the training data changes with <shifts>.

    cvec = combvec((1:self.reps),(1:self.shifts))';
    rvec = cvec(:,1);
    svec = cvec(:,2);
    num_realizations = numel(svec); % total number of realizations

    self.predictions = cell(num_realizations, self.num_hyp_settings);
    self.truths      = cell(num_realizations, self.num_hyp_settings);
    self.errs        = cell(num_realizations, self.num_hyp_settings);
    self.esnXsnaps   = cell(num_realizations, self.num_hyp_settings);

    self.num_predicted = zeros(self.shifts*self.reps, self.num_hyp_settings);
end