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

    % Spinup initialization:
    % current options: 'modelonly', 'esn', 'esnc', 'noise'
    % init_type = 'modelonly';
    % init_type = 'esnc';
    % init_type = 'esn';
    init_type = 'noise';

    % spinup time
    years = 40;

    N_ensemble = 50;

    my_inds = Utils.my_indices(pid, procs, N_ensemble);

    % loop for output only
    for i = my_inds
        spinup_name = sprintf('return_from_%s/spinup_%d_', init_type, i);
        fprintf('pid %d procs %d, %s \n', pid, procs, ...
                spinup_name);
    end

    % loop to call spinup routine
    for i = my_inds
        init_name = sprintf('%s/%s_prediction_%d.mat', ...
                            start_solutions, init_type, i);
        if strcmp(init_type, 'noise')
            init_name = init_type;

            % Seed the rng with time and pid
            now = clock;
            seed = round(100*pid*sqrt(now(end)));


            fprintf('Random init, pid: %d, seeding with %f\n', pid, seed)
            rng(seed);
        end

        spinup_name = sprintf('return_from_%s/spinup_%d_', init_type, i);

        fprintf('pid %d procs %d, %s, %s \n', pid, procs, ...
                init_name, spinup_name);
        QG_Spinup(init_name, spinup_name, years, data_dir);
    end
end