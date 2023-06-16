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

data_dir_esnc = '/home/erik/Projects/hybrid_om/data/QGmodel/return_from_esnc_131072_131072';

data_dir_modelonly = '/home/erik/Projects/hybrid_om/data/QGmodel/return_from_modelonly_131072_131072'

data_dir = data_dir_modelonly

total_T = 40;
first_day = 1;
last_day  = 5475;
freq = 365

% assuming yearly chunks
chunk_list = first_day:freq:last_day;
X = [];
for first = chunk_list
    fprintf('%d\n', first);
    last = first + 364;
    chunk = Utils.load_chunk(qg_f, data_dir, first, last, total_T);
    X = [X, R*chunk.X];
end

out_file = [data_dir, ...
            sprintf('/restricted_%d_T=%d_dt=%1.3e_param=%1.1e.mat', ...
                    dgen.N_imp, total_T, dgen.dt_prf, ...
                    dgen.model_prf.control_param())];

pairs = {{'X', X}, ...
         {'Nt_prf', size(X,2)}, ...
         {'T', size(X,2)/365}};

fprintf('saving to %s\n', out_file)
Utils.save_pairs(out_file, pairs, false);