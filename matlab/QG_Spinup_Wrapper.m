function QG_Spinup_Wrapper(varargin)
    [pid, procs] = Utils.input_handling(nargin, varargin);
    Utils.add_paths();

    % both local and on habrok
    start_solutions = ['~/Projects/hybrid_om/', ...
                       'data/QGmodel/starting_solutions'];

    % local machine
    % data_dir = '/home/erik/Projects/hybrid_om/data';

    % habrok
    data_dir = '/scratch/p267904/Projects/hybrid_om/data';

    % basename = 'modelonly';
    basename = 'esnc';

    % spinup time
    years = 40;

    N_ensemble = 50;

    my_inds = Utils.my_indices(pid, procs, N_ensemble);

    % loop for output only
    for i = my_inds
        spinup_name = sprintf('return_from_%s/spinup_%d_', basename, i);
        fprintf('pid %d procs %d, %s \n', pid, procs, ...
                spinup_name);
    end

    % loop to call spinup routine
    for i = my_inds
        init_name = sprintf('%s/%s_prediction_%d.mat', ...
                            start_solutions, basename, i);
        spinup_name = sprintf('return_from_%s/spinup_%d_', basename, i);

        fprintf('pid %d procs %d, %s, %s \n', pid, procs, ...
                init_name, spinup_name);
        QG_Spinup(init_name, spinup_name, years, data_dir);
    end
end