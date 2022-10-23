function save_pairs(file, pairs, backup)
    
    if nargin < 3
        backup = true
    end
    
    if backup    
        backupfile = [file(1:end-4),'.bak.mat'];
        fprintf('create backup\n')
        [~, msg] = system(['cp -v ', file, ' ', backupfile]);
    end
    
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