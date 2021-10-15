function [pid, procs,syscalls] = input_handling(n_argin, var_argin)
    switch n_argin
      case 0
        pid   = 0;
        procs = 1;
      case 2
        pid   = Utils.arg_to_value(var_argin{1});
        procs = Utils.arg_to_value(var_argin{2});
      otherwise
        error('Unexpected input');
    end

    if pid == 0
        syscalls = true;
        fprintf('syscalls enabled for pid %d\n', pid);
    else
        syscalls = false;
    end

    fprintf('pid %d  procs %d \n', pid, procs);
end