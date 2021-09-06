function [] = print_hyperparams(self, exp_idx)
    str = [];
    for hyp_idx = 1:numel(self.hyp_ids)
        id = self.hyp_ids{hyp_idx};

        value = self.hyp_range(...
            self.id2ind(self.hyp_ids, id), exp_idx);

        % in case the numeric value indicates an option, we can use that
        if isfield(self.hyp.(id), 'opts')
            value = self.hyp.(id).opts{value};
        else
            value = num2str(value);
        end

        str{hyp_idx} = ['\n    ', id, ': ', value, ''];
    end
    str = [str, '\n'];
    self.print([str{:}]);
end
