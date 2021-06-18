function create_hyp_range(self)
    hyp_ids = fieldnames(self.hyp);    
    evalstr = '';
    for i = 1:numel(hyp_ids)
        % if not an active experiment, set the hyp range to a single default
        % value
        if ~sum(strcmp(hyp_ids{i}, self.exp_id))
            self.hyp.(hyp_ids{i}).range = ...
                self.hyp.(hyp_ids{i}).default;
        end

        % create a call to combvec, combine all ranges for all hyperparameters
        evalstr = [evalstr, 'self.hyp.(hyp_ids{', num2str(i), '}).range'];
        if i < numel(hyp_ids)
            evalstr = [evalstr, ', '];
        end
    end

    % create hyp range
    eval(['self.hyp_range = combvec(', evalstr, ');']);
    
    % total number of different hyperparameter settings
    self.num_hyp_settings = size(self.hyp_range,2);
end