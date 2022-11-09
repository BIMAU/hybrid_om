addpath('../');
    
if ~exist('preds4', 'var') || ~exist('ref_preds', 'var') || ~exist('preds', 'var')
    load_qg_data    
end

fname = ['movie.avi'];

fprintf([fname, '\n'])
writerObj = VideoWriter(fname, 'Motion JPEG AVI');
writerObj.FrameRate = 16;
writerObj.Quality = 90;
open(writerObj);
set(0,'DefaultFigureWindowStyle','normal')
fhandle = figure('units','pixels','position',[100,100,1200,700]);
set(gca,'position',[0.05 0.1 .92 0.85],'units','normalized');
set(gca,'color','w','fontsize',12);

crange = [-0.3,0.3];

Re_f = 1000;
Re_c = 500;
nx_f = 64;
ny_f = nx_f;
nx_c = 32;
ny_c = nx_c;

ampl = 2; % stirring amplitude
stir = 0; % stirring type: 0 = cos(5x), 1 = sin(16x)

opts = [];
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
tdim = Ldim / Udim; % in seconds
scaling = 3600*24/tdim;

% create data generator for the two models
dgen = DataGen(qg_f, qg_c);

% the grids are different so grid transfers are necessary
dgen.dimension = '2D';
dgen.build_grid_transfers('periodic');

% store the grid transfers in the options
R = dgen.R;

map = Utils.my_colmap();

T = size(preds{1,1},1);

skip   = 5;
period = 3*365;
steady = T-period+1:skip:T;
spinup = 1:skip:period;

i_range = steady;

for i = i_range
    % plot restricted reference
    subplot(2,3,1)    
    plotQG(nx_f, ny_f, 1, scaling*ref_preds{1,1}(i,:)', true);
    tstr = sprintf('Reference,   day %2d', i);
    title(tstr,'interpreter','latex');
    colormap(map);
    colorbar
    caxis(crange)
    invertcolors()
    axis off
    
    subplot(2,3,2)    
    plotQG(nx_c, ny_c, 1, scaling*preds{1,1}(i,:)', true);
    tstr = sprintf('Imperfect model');
    title(tstr,'interpreter','latex');
    colormap(map);
    colorbar
    caxis(crange)
    invertcolors()
    axis off

    subplot(2,3,3)    
    plotQG(nx_c, ny_c, 1, scaling*preds{1,2}(i,:)', true);
    tstr = sprintf('ESN');
    title(tstr,'interpreter','latex');
    colormap(map);
    colorbar
    caxis(crange)
    invertcolors()
    axis off

    subplot(2,3,4)    
    plotQG(nx_c, ny_c, 1, scaling*preds{1,3}(i,:)', true);
    tstr = sprintf('ESNc');
    title(tstr,'interpreter','latex');
    colormap(map);
    colorbar
    caxis(crange)
    invertcolors()
    axis off

    subplot(2,3,5)    
    plotQG(nx_c, ny_c, 1, scaling*preds{1,6}(i,:)', true);
    tstr = sprintf('ESN + DMDc');
    title(tstr,'interpreter','latex');
    colormap(map);
    colorbar
    caxis(crange)
    invertcolors()
    axis off

    subplot(2,3,6)    
    plotQG(nx_c, ny_c, 1, scaling*preds4{1,2}(i,:)', true);
    tstr = sprintf('DMDc');
    title(tstr,'interpreter','latex');
    colormap(map);
    colorbar
    caxis(crange)
    invertcolors()
    axis off

    % subplot(2,3,7)    
    % plotQG(nx_c, ny_c, 1, scaling*preds{1,6}(i,:)', true);
    % tstr = sprintf('correction only');
    % tstr = sprintf('hybrid esn plus dmd');
    % title(tstr);
    % colormap(map);
    % colorbar
    % caxis(crange)

    % subplot(2,3,8)    
    % plotQG(nx_c, ny_c, 1, scaling*preds{1,7}(i,:)', true);
    % tstr = sprintf('esn plus dmd');
    % title(tstr);
    % colormap(map);
    % colorbar
    % caxis(crange)

    % subplot(2,3,9)    
    % plotQG(nx_c, ny_c, 1, scaling*preds{1,8}(i,:)', true);
    % tstr = sprintf('hybrid esn plus dmd');
    % title(tstr);
    % colormap(map);
    % colorbar
    % caxis(crange)

    frame = getframe(gcf);
    writeVideo(writerObj, frame);
end

fprintf('\n');
close(writerObj);