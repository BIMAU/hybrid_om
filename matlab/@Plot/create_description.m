function [description] = create_description(self, mdat)
    par_names = fieldnames(mdat.hyp);
    default = 1;

    description = sprintf('');

    for i = 1:numel(par_names)
        has_opts = isfield(mdat.hyp.(par_names{i}), 'opts');

        if has_opts
            value_start = mdat.hyp.(par_names{i}).opts{mdat.hyp_range(i, 1)};
            value_end   = mdat.hyp.(par_names{i}).opts{mdat.hyp_range(i, end)};
            description = sprintf('%s\n%21s: %s-%s', description, ...
                                  par_names{i}, value_start, value_end);
        else
            value_start = mdat.hyp_range(i, 1);
            value_end   = mdat.hyp_range(i, end);
            description = sprintf('%s\n%21s: %1.1d-%1.1d', description, ...
                                  par_names{i}, value_start, value_end);
        end
    end
end