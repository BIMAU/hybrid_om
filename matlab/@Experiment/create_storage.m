function create_storage(self)
% The core experiment is repeated with <reps>*<shifts> realizations of
% the network. The range of the training data changes with <shifts>.

    cvec = combvec((1:self.reps),(1:self.shifts))';
    rvec = cvec(:,1);
    svec = cvec(:,2);
    N_rl = numel(svec); % total number of realizations

    self.predictions = cell(N_rl, self.num_hyp_settings);
    self.truths      = cell(N_rl, self.num_hyp_settings);
    self.errors      = cell(N_rl, self.num_hyp_settings);
    self.ESN_states  = cell(N_rl, self.num_hyp_settings);

    % Number of predicted time steps that are within the error limit.
    self.num_predicted = zeros(self.shifts*self.reps, self.num_hyp_settings);
end