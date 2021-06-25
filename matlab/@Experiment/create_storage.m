function create_storage(self)
    % total number of realizations
    N_rl = self.reps*self.shifts;

    self.predictions = cell(N_rl, self.num_hyp_settings);
    self.truths      = cell(N_rl, self.num_hyp_settings);
    self.errors      = cell(N_rl, self.num_hyp_settings);
    self.ESN_states  = cell(N_rl, self.num_hyp_settings);

    % Number of predicted time steps that are within the error limit.
    self.num_predicted = zeros(self.shifts*self.reps, self.num_hyp_settings);
end