% Goal here is to restrict a bunch of chunks. For that we need the
% correct DataGen object.
Utils.add_paths();

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

% coarse QG with periodic bdc
qg_c = QG(nx_c, ny_c, 1);
qg_c.set_par(5,  Re_c);  % Reynolds number
qg_c.set_par(11, ampl);  % stirring amplitude
qg_c.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)

% create data generator for the two models
dgen = DataGen(qg_f, qg_c);
dgen.dt_prf = 1/365.
dgen.dt_imp = 1/365.

% create grid transfers
dgen.dimension = '2D';
dgen.build_grid_transfers('periodic');

R = dgen.R;
P = dgen.P;

total_T = 250;
% Take year 200 to 250 in a 250 year spinup.
first_day = 73001;
last_day  = 91250;
T = 100;

% Take year 100 to 200 in a 250 year spinup.
first_day = 36501;
last_day  = 73000;
T = 100;

% Take year 0 to 100 in a 250 year spinup.
first_day = 1;
last_day  = 36500;
T = 100;

first_day = 73001;
last_day  = 91250;
T = 50;

% assuming yearly chunks
chunk_list = first_day:365:last_day;
X = [];
for first = chunk_list
    fprintf('%d\n', first);
    last = first + 364;
    chunk = Utils.load_chunk(qg_f, dgen, first, last, total_T);
    X = [X, R*chunk.X];
end

out_file_path = sprintf([dgen.data_dir, '/%s/%d_%d/'], ...
                        dgen.model_prf.name, ...
                        dgen.N_prf, dgen.N_imp);

out_file = [out_file_path, ...
            sprintf('remainder_T=%d_dt=%1.3e_param=%1.1e.mat', ...
                    T, dgen.dt_prf, ...
                    dgen.model_prf.control_param())];

pairs = {{'X', X}, ...
         {'Nt_prf', size(X,2)}, ...
         {'T', T}};

Utils.save_pairs(out_file, pairs, false);