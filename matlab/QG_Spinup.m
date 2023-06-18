function [dir] = QG_Spinup(xinit_mat, name, years, data_dir)
    Utils.add_paths();

    % Create perfect/fine QG model
    % Create two QG models with different grids and different Reynolds
    % numbers.
    Re_f = 2000;
    Re_c = 500;
    nx_f = 256;
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

    % get QG nondimensionalization
    [Ldim, ~, Udim] = qg_f.get_nondim();

    % create coarse QG with periodic bdc
    qg_c = QG(nx_c, ny_c, 1);
    qg_c.set_par(5,  Re_c);  % Reynolds number
    qg_c.set_par(11, ampl);  % stirring amplitude
    qg_c.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)

    % set initial solution in datagen
    if nargin >= 1 && strcmp(xinit_mat, 'noise')
        random_init = true;
    else
        random_init = false;
    end

    if nargin >= 1 && ~random_init
        x_init = load(xinit_mat).x;
    else
        fprintf('initialize randomly\n');
        x_init = 0.001*randn(qg_f.N,1);
    end

    % create data generator
    dgen = DataGen(qg_f, qg_c);
    if nargin >= 2
        dgen.rename(name);
    end

    % set output dir for datagen
    if nargin >= 4
        dgen.set_data_dir(data_dir);
    end

    % we want to store the results on the coarse grid
    dgen.store_restricted = true;
    dgen.dimension = '2D';
    dgen.build_grid_transfers('periodic', qg_c);

    dgen.x_init_prf = x_init;
    dgen.chunking = true;

    % set the time step to one day
    Tdim = Ldim / Udim; % in seconds
    day  = 24*3600; % in seconds
    year = day*365; % in seconds
    dt_prf = day / Tdim;
    dgen.dt_prf = dt_prf;

    % run for <years> years, default is 250 years
    if nargin >= 3
        dgen.T = round(years * year / Tdim);
    else
        dgen.T = round(250 * year / Tdim);
    end

    % output frequency
    dgen.output_freq = round(year / Tdim / dt_prf); % yearly output

    dgen

    dgen.generate_prf_transient();
end