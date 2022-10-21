function [dir] = QG_Spinup(varargin)
    [pid, procs] = Utils.input_handling(nargin, varargin);
    Utils.add_paths();

    % Create perfect/fine QG model 
    Re_f = 1000;
    nx_f = 128;
    ny_f = nx_f;

    ampl = 2; % stirring amplitude
    stir = 0; % stirring type: 0 = cos(5x), 1 = sin(16x)

    % fine QG with periodic bdc
    qg_f = QG(nx_f, ny_f, 1);
    qg_f.set_par(5,  Re_f);  % Reynolds number
    qg_f.set_par(11, ampl);  % stirring amplitude
    qg_f.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)

    % get QG nondimensionalization
    [Ldim, ~, Udim] = qg_f.get_nondim();
    
    % create data generator for a single model
    dgen = DataGen(qg_f);  %## TODO

    % set initial solution in datagen
    x_init = 0.001*randn(qg_f.N,1);
    dgen.x_init_prf = x_init;

    % set the time step to one day
    Tdim = Ldim / Udim; % in seconds
    day  = 24*3600; % in seconds
    year = day*365; % in seconds
    dt_prf = day / Tdim;
    dgen.dt_prf = dt_prf;

    dgen.T = round(100 * year / Tdim);
    dgen.verbosity = 30;
    dgen.generate_prf_transient();    
end
