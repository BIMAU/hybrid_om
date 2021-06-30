function [description] = create_description(self, mdat)
    par_names = fieldnames(mdat.hyp);
    default = 1;

    description = sprintf('%18s: %1.1d', 'ESN', mdat.esn_on);
    description = sprintf('%s\n%18s: %1.1d', description, 'Model', mdat.model_on);
    for i = 1:numel(par_names)
        value_start = mdat.hyp_range(i, 1);
        value_end   = mdat.hyp_range(i, end);
        description = sprintf('%s\n%18s: %1.1d-%1.1d', description, ...
                              par_names{i}, value_start, value_end);
    end
end