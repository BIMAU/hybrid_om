function [mx] = max_available_hyp(self, hyp_name)

    hyp_id2value = @ (id, idx) ...
        self.hyp_range(self.id2ind(self.hyp_ids, id), idx);

    mx = 0;
    for idx = 1:self.num_hyp_settings
        val = hyp_id2value(hyp_name, idx);
        mx = max(mx, val);
    end
end