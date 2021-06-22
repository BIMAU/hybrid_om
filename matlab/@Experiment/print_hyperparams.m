function [] = print_hyperparams(self, exp_idx)
    str = [];
    for hyp_idx = 1:numel(self.hyp_ids)
        id = self.hyp_ids{hyp_idx};

        value = num2str(self.hyp_range(...
            self.id2ind(self.hyp_ids, id), exp_idx)...
                        );
        
        str{hyp_idx} = ['\n    ', id, ': ', value, ''];
    end
    str = [str, '\n'];
    self.print([str{:}]);
end
