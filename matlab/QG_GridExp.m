function [dir] = QG_GridExp(varargin)
    [pid, procs] = Utils.input_handling(nargin, varargin);

    % Create two QG models with different grids and different Reynolds
    % numbers.
    Re_f = 1000;
    Re_c = 500;
    nx_f = 64;
    ny_f = nx_f;
    nx_c = 32;
    ny_c = nx_c;

    ampl = 2; % stirring amplitude
    stir = 0; % stirring type: 0 = cos(5x), 1 = sin(16x)

    % fine QG with periodic bdc
    qg_f = QG(nx_f, ny_f, 1);
    qg_f.set_par(5,  Re_f);  % Reynolds number
    qg_f.set_par(11, ampl);  % stirring amplitude
    qg_f.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)

    % coarse QG with periodic bdc
    qg_c = QG(nx_c, ny_c, 1);
    qg_c.set_par(5,  Re_c);  % Reynolds number
    qg_c.set_par(11, ampl);  % stirring amplitude
    qg_c.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)

    % get QG nondimensionalization, which is the same for qg_f and qg_c
    [Ldim, ~, Udim] = qg_f.get_nondim();

    % create data generator for the two models
    dgen = DataGen(qg_f, qg_c);

    % the grids are different so grid transfers are necessary
    dgen.dimension = '2D';
    dgen.build_grid_transfers('periodic');

    % load appropriate initial solution for QG
    init_sol = load('../data/QGmodel/starting_solutions/equilibrium_nx64_Re1e3_ampl2_stir0_rot1.mat');

    % check that what we got is ok
    assert(init_sol.Re == Re_f);
    assert(init_sol.nx == nx_f);
    assert(init_sol.ny == ny_f);
    assert(init_sol.ampl == ampl);
    assert(init_sol.stir == stir);

    % set initial solution in datagen
    dgen.x_init_prf = init_sol.x_init;

    % set the time step to one day
    Tdim = Ldim / Udim; % in seconds
    day  = 24*3600; % in seconds
    year = day*365; % in seconds
    dt_prf = day / Tdim;
    dgen.dt_prf = dt_prf;

    % compute 100 years, which should give 36500 snapshots
    dgen.T = 100 * year / Tdim;
    dgen.verbosity = 10;
    dgen.generate_prf_transient();

end