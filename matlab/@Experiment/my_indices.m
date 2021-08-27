function [inds] = my_indices(self, pid, procs, Ni)
% a simple decomposition to take care of parallel needs

    assert((pid < procs) && (pid >= 0), ...
           ['assertion erred, invalid pid ', num2str(pid), ...
            ', procs ', num2str(procs)])

    assert((procs <= Ni), ...
           ['assertion failed, more procs than Ni=repetitions*shifts, ',...
            'pid ', num2str(pid), ...
            ', procs ', num2str(procs),...
            ', Ni ', num2str(Ni)])

    k = procs;
    decomp = [];
    offset = 0;
    remain = Ni; % elements that remain
    decomp = cell(procs);
    for i = 1:procs
        subset    = floor(remain / k);
        decomp{i} = offset + 1: offset + subset;
        offset    = offset + subset;

        k      = k-1;
        remain = remain - subset;
    end

    inds = decomp{pid+1,:};
end