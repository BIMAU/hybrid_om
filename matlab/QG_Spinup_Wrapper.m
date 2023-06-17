function [dir] = QG_Spinup_Wrapper(varargin)
    [pid, procs] = Utils.input_handling(nargin, varargin);
    Utils.add_paths();
    
    start_solutions = ['/home/erik/Projects/hybrid_om/',...
                       'data/QGmodel/starting_solutions'];    
    
    basename = 'modelonly';
    
    % spinup time
    years = 1;
    
    N_ensemble = 50;
    
    my_inds = Utils.my_indices(pid, procs, N_ensemble);
    for i = my_inds
        init_name = sprintf('%s/%s_prediction_%d.mat', ...
                            start_solutions, basename, i);
        spinup_name = sprintf('return_from_%s/spinup_%d_', basename, i);
        QG_Spinup(init_name, spinup_name, years)
    end    
    
end