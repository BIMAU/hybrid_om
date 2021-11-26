if 1
    base_dir = '~/Projects/hybrid_om/data/experiments/';
    ref_dir  = 'QG_reference_transient/MC_1-1_serial_param_1.00e+03/';
    exp_dir  = 'QG_transient/MC_1-8_serial_param_5.00e+02/';
    exp_dir  = 'QG_transient/MC_1-8_LB_10-10_serial_param_5.00e+02/';
    exp_dir  = 'QG_transient/MC_1-8_LB_100-100_serial_param_5.00e+02/';

    exp_dir = [base_dir, exp_dir, '/'];
    ref_dir = [base_dir, ref_dir, '/'];

    p = Plot(ref_dir);
    [~, ~, ~, ~, ref_states,~] = ...
        p.gather_data(ref_dir);
    p = Plot(exp_dir);
    [errs, nums, pids, ...
     mdat, preds, ...
     truths] =  ...
        p.gather_data(exp_dir);
end

fname = [exp_dir, '/movie2.avi'];

fprintf([fname, '\n'])
writerObj = VideoWriter(fname, 'Motion JPEG AVI');
writerObj.FrameRate = 16;
writerObj.Quality = 100;
open(writerObj);
set(0,'DefaultFigureWindowStyle','normal')
fhandle = figure('units','pixels','position',[100,100,900,700]);
set(gca,'position',[0.05 0.1 .92 0.85],'units','normalized');
set(gca,'color','w','fontsize',15);

crange = [-0.3,0.3];

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
tdim = Ldim / Udim; % in seconds
scaling = 3600*24/tdim;

% create data generator for the two models
dgen = DataGen(qg_f, qg_c);

% the grids are different so grid transfers are necessary
dgen.dimension = '2D';
dgen.build_grid_transfers('periodic');

% store the grid transfers in the options
R = dgen.R;

map = my_colmap();

T = size(ref_states{1,1},1);

skip   = 10;
period = 1*365;
steady = T-period+1:skip:T;
spinup = 1:skip:period;

i_range = steady;

for i = i_range
    % plot restricted reference
    subplot(3,3,1)    
    plotQG(nx_f, ny_f, 1, scaling*ref_states{1,1}(i,:)', true);
    tstr = sprintf('reference,   day %2d', i);
    title(tstr);
    colormap(map);
    colorbar
    caxis(crange)
    
    subplot(3,3,2)    
    plotQG(nx_c, ny_c, 1, scaling*preds{1,1}(i,:)', true);
    tstr = sprintf('model only');
    title(tstr);
    colormap(map);
    colorbar
    caxis(crange)

    subplot(3,3,3)    
    plotQG(nx_c, ny_c, 1, scaling*preds{1,2}(i,:)', true);
    tstr = sprintf('esn only');
    title(tstr);
    colormap(map);
    colorbar
    caxis(crange)

    subplot(3,3,4)    
    plotQG(nx_c, ny_c, 1, scaling*preds{1,3}(i,:)', true);
    tstr = sprintf('dmd only');
    tstr = sprintf('hybrid esn');
    title(tstr);
    colormap(map);
    colorbar
    caxis(crange)

    subplot(3,3,5)    
    plotQG(nx_c, ny_c, 1, scaling*preds{1,4}(i,:)', true);
    tstr = sprintf('hybrid esn');
    tstr = sprintf('hybrid dmd');
    title(tstr);
    colormap(map);
    colorbar
    caxis(crange)

    subplot(3,3,6)    
    plotQG(nx_c, ny_c, 1, scaling*preds{1,5}(i,:)', true);
    tstr = sprintf('hybrid dmd');
    tstr = sprintf('correction only');
    title(tstr);
    colormap(map);
    colorbar
    caxis(crange)

    subplot(3,3,7)    
    plotQG(nx_c, ny_c, 1, scaling*preds{1,6}(i,:)', true);
    tstr = sprintf('correction only');
    tstr = sprintf('hybrid esn plus dmd');
    title(tstr);
    colormap(map);
    colorbar
    caxis(crange)

    % subplot(3,3,8)    
    % plotQG(nx_c, ny_c, 1, scaling*preds{1,7}(i,:)', true);
    % tstr = sprintf('esn plus dmd');
    % title(tstr);
    % colormap(map);
    % colorbar
    % caxis(crange)

    % subplot(3,3,9)    
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