Re_f = 1000;
Re_c = 500;
nx_f = 64;
ny_f = nx_f;
nx_c = 32;
ny_c = nx_c;

ampl = 2; % stirring amplitude
stir = 0; % stirring type: 0 = cos(5x), 1 = sin(16x)

opts.nun = 2;
opts.nx = nx_c;
opts.ny = ny_c;
opts.Re = Re_c;
opts.ampl = ampl;
opts.stir = stir;

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
[Ldim, ~, Udim] = qg_c.get_nondim();
opts.Ldim = Ldim;
opts.Udim = Udim;

% create data generator for the two models
dgen = DataGen(qg_f, qg_c);

% the grids are different so grid transfers are necessary
dgen.dimension = '2D';
dgen.build_grid_transfers('periodic');

% store the grid transfers in the options
opts.R = dgen.R;

% load appropriate initial solution for QG
init_sol = load('~/Projects/hybrid_om/data/QGmodel/starting_solutions/equilibrium_nx64_Re1e3_ampl2_stir0_rot1.mat');

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
day = 24*3600; % in seconds
year = day*365; % in seconds
dt_prf = day / Tdim;
dgen.dt_prf = dt_prf;

% compute 100 years, which should roughly give 36500 snapshots
dgen.T = round(100 * year / Tdim);
dgen.verbosity = 10;
dgen.generate_prf_transient();

%% ------------------------------------------------------------------
base_dir = '~/Projects/hybrid_om/data/experiments/';
exp_dir = 'QG_reference_transient/MC_1-1_serial_param_1.00e+03/';
dir = [base_dir, exp_dir, '/'];
p = Plot(dir);
training_samples = 10000;
X = opts.R*dgen.X(:,1:training_samples);

opts.windowsize = 10;

stats_0 = p.get_qg_statistics(qg_c, X, opts);

[~, ~, ref_preds, ~, ref_stats] = p.get_qg_transient_data(opts);

%%------------------------------------------------------------------
exp_dir = 'QG_transient/MC_1-8_SC_1-5_parallel_param_5.00e+02/';
dir = [base_dir, exp_dir, '/'];
p = Plot(dir);
[~, exp_mdat, preds, ~, stats] = p.get_qg_transient_data(opts);


%%--------------------------------------------
% in several plots we ignore initial transient (20 years)
trunc = 20*365;

%subplot(3,2,1)
cols = [0,0,0; lines(16)];

start_idx = [opts.windowsize, opts.windowsize, 1];
quantity = {'Km', 'Ke', 'Z'};
for idx = 1:3
    figure(idx)
    subplot(3,1,1)

    trange = (start_idx(idx):size(X,2)) / 365;
    plot(trange, stats_0.(quantity{idx}), '.-', 'markersize', 1, 'color', cols(1,:)); 
    hold on;

    trange = (size(X,2)+start_idx(idx):size(X,2)+size(preds{1,1}, 1)) / 365;
    plot(trange, ref_stats{1,1}.(quantity{idx}), '.-', 'markersize', 1, 'color', cols(1,:)); hold on;
    plot(trange, ...
         repmat(mean(ref_stats{1,1}.(quantity{idx}))+2*sqrt(var(ref_stats{1,1}.(quantity{idx}))),1,numel(ref_stats{1,1}.(quantity{idx}))), ...
         '--', 'markersize', 1, 'color', cols(1,:));
    plot(trange, ...
         repmat(mean(ref_stats{1,1}.(quantity{idx}))-2*sqrt(var(ref_stats{1,1}.(quantity{idx}))),1,numel(ref_stats{1,1}.(quantity{idx}))), ...
         '--', 'markersize', 1, 'color', cols(1,:));

    
    [n_shifts, n_hyp] = size(preds);
    trange = (size(X,2)+start_idx(idx):size(X,2)+size(preds{1,1}, 1)) / 365;
    for j = 1:n_hyp
        for i = 1:n_shifts
            plot(trange, stats{i,j}.(quantity{idx}), '.-', 'markersize', 1, 'color', cols(j+1,:)); hold on;
        end
    end
    hold off
    
    title(exp_dir,'interpreter','none');

    legend('reference run', 'reference run','reference run','reference run', ...
           'model_only', 'esn_only', 'dmd_only', ...
           'hybrid_esn', 'hybrid_dmd', 'corr_only', ...
           'esn_plus_dmd', 'hybrid_esn_dmd','interpreter','none','location','bestoutside')
    % legend('reference run', 'reference run','reference run','reference run', ...
    %        'model_only', 'esn_only',  ...
    %        'hybrid_esn', 'hybrid_dmd', 'corr_only', ...
    %        'hybrid_esn_dmd','interpreter','none','location','bestoutside')

    ylabel(quantity{idx})
    xlabel('years') 

    ymin = mean(ref_stats{1,1}.(quantity{idx}))-20*sqrt(var(ref_stats{1,1}.(quantity{idx})));
    ymax = mean(ref_stats{1,1}.(quantity{idx}))+20*sqrt(var(ref_stats{1,1}.(quantity{idx})));
    ylim([ymin,ymax])

    %%

    subplot(3,2,3)
    histogram(ref_stats{1,1}.(quantity{idx})(trunc+1:end),50, 'facecolor', cols(1,:),'edgecolor', cols(1,:))
    xlabel(quantity{idx})
    hold on
    for j = [2,4]
        i = 1;
        histogram(stats{i,j}.(quantity{idx})(trunc+1:end),50, 'facecolor', cols(j+1,:),'edgecolor', cols(j+1,:))
        title('esn only and hybrid esn');
        hold on
    end
    hold off
    xlabel(quantity{idx})

    subplot(3,2,5)
    histogram(ref_stats{1,1}.(quantity{idx})(trunc+1:end),50, 'facecolor', cols(1,:),'edgecolor', cols(1,:))
    xlabel(quantity{idx})
    hold on
    for j = [4,8]
        i = 1;
        histogram(stats{i,j}.(quantity{idx})(trunc+1:end),50, 'facecolor', cols(j+1,:),'edgecolor', cols(j+1,:))
        title('model only');
        title('hybrid esn + dmd and hybrid esn');
        hold on
    end
    hold off
    xlabel(quantity{idx})

    subplot(3,2,6)
    histogram(ref_stats{1,1}.(quantity{idx})(trunc+1:end),50, 'facecolor', cols(1,:),'edgecolor', cols(1,:))
    xlabel(quantity{idx})
    hold on
    for j = [6]
        i = 1;
        histogram(stats{i,j}.(quantity{idx})(trunc+1:end),50, 'facecolor', cols(j+1,:),'edgecolor', cols(j+1,:))
        title('correction only');
        hold on
    end
    hold off
    xlabel(quantity{idx})
end

%%

figure(1)
subplot(3,2,4)
opts.trunc = trunc;
opts.skip = 90;
opts.conf_int = false;
opts.T = size(ref_preds{1,1},1);
[f, Pm_ref, Pv_ref] = p.plot_qg_mean_spectrum(qg_c, opts.R*ref_preds{1,1}', opts, 'color', cols(1,:));
id_pos = logical(Pm_ref > 0);

diff_P = [];
for j = [1,2,4,6,8]
    hold on
    opts.conf_int = false;
    [f, Pm, Pv] = p.plot_qg_mean_spectrum(qg_c, preds{1,j}', opts, 'color', cols(j+1,:));
    
    diff_Pm = norm(log(Pm(id_pos))-log(Pm_ref(id_pos)));
    diff_Pv = norm(log(Pv(id_pos))-log(Pv_ref(id_pos)));
    diff_P = [diff_P; [j, diff_Pm, diff_Pv] ];
    drawnow
end
hold off