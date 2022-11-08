% function [dir] = QG_GridTransferTest(varargin)
%     [pid, procs] = Utils.input_handling(nargin, varargin);
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
[x_f, y_f] = qg_f.grid();
dx_f = x_f(2)-x_f(1);
dy_f = y_f(nx_f+1)-y_f(1);

% coarse QG with periodic bdc
qg_c = QG(nx_c, ny_c, 1);
qg_c.set_par(5,  Re_c);  % Reynolds number
qg_c.set_par(11, ampl);  % stirring amplitude
qg_c.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)
[x_c, y_c] = qg_c.grid();
dx_c = x_c(2)-x_c(1);
dy_c = y_c(nx_c+1)-y_c(1);

% get QG nondimensionalization, which is the same for qg_f and qg_c
[Ldim, ~, Udim] = qg_f.get_nondim();

% create data generator for the two models
dgen = DataGen(qg_f, qg_c);

% the grids are different so grid transfers are necessary
dgen.dimension = '2D';
dgen.build_grid_transfers('periodic');

R = dgen.R;
P = dgen.P;

% load chunk
first_day = 90521;
last_day  = 90885;
total_T = 250;

chunk = Utils.load_chunk(qg_f, dgen, first_day, last_day, total_T);

% compute mass
dim = qg_f.nun * qg_f.nx * qg_f.ny;
id_psi = 2:qg_f.nun:dim;
PSI  = chunk.X(id_psi,:);
mass = sum(PSI*dx_f*dy_f, 1);

% compute restricted mass
dim_c = qg_c.nun * qg_c.nx * qg_c.ny;
X_R = R * chunk.X;
id_psi_R = 2:qg_c.nun:dim_c;
PSI_R = X_R(id_psi_R,:);
mass_R = sum(PSI_R*dx_c*dy_c, 1);

diffnorm = norm(mass-mass_R);
tol = 1e-10;
fprintf('mass conservation, diffnorm: %3.3e < tol\n', diffnorm)
assert(diffnorm < tol)

% compute prolongated mass
X_RP = P * X_R;
PSI_RP = X_RP(id_psi,:);
mass_RP = sum(PSI_RP*dx_f*dy_f, 1);
diffnorm = norm(mass_RP-mass);
fprintf('mass conservation, diffnorm: %3.3e < tol\n', diffnorm)
assert(diffnorm < tol)
