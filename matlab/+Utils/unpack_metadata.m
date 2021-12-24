function [labels, Nvalues, par_names, exp_ind, I, opts_str] = unpack_metadata(mdat)
    [exp_ind, I] = sort( [mdat.exp_ind{:}] );
    Nexp = numel(exp_ind);

    labels  = [];
    Nvalues = [];

    opts_str = [];
    for i = 1:Nexp
        labels{i}  = mdat.hyp_range(exp_ind(i), :);
        Nvalues(i) = numel(unique(labels{i}));
        par_names{i} = mdat.xlab{I(i)};
        par_name = par_names{i};
        has_opts = isfield(mdat.hyp.(par_name), 'opts');

        for j = 1:numel(labels{i})
            value = labels{i}(j);
            if has_opts
                opts_str{i,j} = [par_names{i}, ':', mdat.hyp.(par_name).opts{value}, ' '];
            else
                opts_str{i,j} = [par_names{i}, ':', num2str(value), ' '];
            end
        end
    end
end