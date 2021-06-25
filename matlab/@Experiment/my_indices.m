function [inds] = my_indices(self, pid, procs, Ni)
% a simple decomposition to take care of parallel needs

    assert((pid < procs) && (pid >= 0), ...
           ['assertion erred, pid ', num2str(pid)])

    assert((procs <= Ni), ...
           ['assertion failed, pid ', num2str(pid)])

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