function save_pairs(file, pairs)
    Np = numel(pairs);
    for i = 1:Np
        var = pairs{i}{1};
        eval([var, ' = pairs{i}{2};'])
        if (i == 1)
            save(file, var, '-v7.3')
        else
            save(file, var, '-append')
        end
    end
end