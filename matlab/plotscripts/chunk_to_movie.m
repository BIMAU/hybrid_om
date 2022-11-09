addpath('~/local/matlab')
addpath('../');

first_day = 90521;
last_day = 90885;

Re_f = 2000;
Re_c = 500;
nx_f = 256;
nx_c = 32;
ny_f = nx_f;
ny_c = nx_c;
nun = 2;
dim = nun * nx_f * ny_f;

data_dir = sprintf(['/data/p267904/Projects/hybrid_om/data/QGmodel',...
                    '/%d_%d'], dim, dim)

data_fname = sprintf(['%s/transient_T=250_dt=2.740e-03_param=%1.1e.chunk_%d-%d.mat'], ...
                     data_dir, Re_f, first_day, last_day);

data = load(data_fname)

moviename = sprintf('%s/movie_%d-%d_Re%1.1e_nx%d.avi', data_dir, first_day, last_day, Re_f, nx_f);
fprintf([moviename, '\n'])
writerObj = VideoWriter(moviename, 'Motion JPEG AVI');
writerObj.FrameRate = 16;
writerObj.Quality = 100;
open(writerObj);
set(0,'DefaultFigureWindowStyle','normal')
fhandle = figure('units','pixels','position',[100,100,1200,900]);
set(gca,'position',[0.05 0.1 .92 0.85],'units','normalized');
set(gca,'color','w','fontsize',16);

crange = [-0.35,0.35];

ampl = 2; % stirring amplitude
stir = 0; % stirring type: 0 = cos(5x), 1 = sin(16x)

% fine QG with periodic bdc
qg_f = QG(nx_f, ny_f, 1);
qg_f.set_par(5,  Re_f);  % Reynolds number
qg_f.set_par(11, ampl);  % stirring amplitude
qg_f.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)

qg_c = QG(nx_c, ny_c, 1);
qg_c.set_par(5,  Re_c);  % Reynolds number
qg_c.set_par(11, ampl);  % stirring amplitude
qg_c.set_par(18, stir);  % stirring type: 0 = cos(5x), 1 = sin(16x)

% create data generator for the two models
dgen = DataGen(qg_f, qg_c);

% the grids are different so grid transfers are necessary
dgen.dimension = '2D';
dgen.build_grid_transfers('periodic');

R = dgen.R;
P = dgen.P;

% get QG nondimensionalization, which is the same for qg_f and qg_c
[Ldim, ~, Udim] = qg_f.get_nondim();
tdim = Ldim / Udim; % in seconds
scaling = 3600*24/tdim;

T = size(data.X, 2);

skip   = 6
frames = 1:skip:T;

p = Plot();
spec_opts.power_laws = false;
spec_opts.stircol = 'k';
spec_opts.trunc = 0;
spec_opts.skip = 1;
spec_opts.T = 1;

XR = R*data.X;

for i = frames
    fprintf('%d\n', i)
    % plot restricted reference
    subplot(2,2,1)
    plotQG(nx_f, ny_f, 1, scaling*data.X(:,i), true);
    tstr = sprintf('Vorticity (day$^{-1}$),   day %2d', first_day + i - 1);
    title(tstr,'interpreter','latex');
    caxis(crange)
    map = Utils.my_colmap();
    colormap(map);
    colorbar
    % invertcolors()
    axis off

    subplot(2,2,2)
    p.plot_qg_mean_spectrum(qg_f, data.X(:,i), spec_opts, ...
                            'linewidth', 2);
    title('spectrum', 'interpreter','latex');
    ylim([1e-7,1e7]);

    subplot(2,2,3)
    plotQG(nx_c, ny_c, 1, scaling*XR(:,i), true);
    tstr = sprintf('Restricted vorticity (day$^{-1}$),   day %2d', first_day + i - 1);
    title(tstr,'interpreter','latex');
    caxis(crange)
    map = Utils.my_colmap();
    colormap(map);
    colorbar
    % invertcolors()
    axis off

    subplot(2,2,4)
    p.plot_qg_mean_spectrum(qg_c, XR(:,i), spec_opts, ...
                            'linewidth', 2);
    title('spectrum', 'interpreter','latex');
    ylim([1e-7,1e7]);
    
    frame = getframe(gcf);
    writeVideo(writerObj, frame);
end

fprintf('\n');
close(writerObj);
fprintf(['see ', moviename, '\n'])