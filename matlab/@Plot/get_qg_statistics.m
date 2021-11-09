function [stats] = get_qg_statistics(self, qg, states, opts)
    time = tic;
    fprintf(' computing statistics ... \n');
    wsize = opts.windowsize;
    track_points = false;

    nx   = opts.nx;
    ny   = opts.ny;
    nun  = opts.nun;
    dim  = nx*ny*nun;
    Re   = opts.Re;
    ampl = opts.ampl;
    stir = opts.stir;
    
    Ldim    = opts.Ldim;
    Udim    = opts.Udim;
    tdim    = Ldim / Udim;  % in seconds
    scaling = 3600*24/tdim; % in days

    T    = size(states, 2); % number of samples
    assert(T > wsize, '   T <= wsize... not good.');
    assert(nx*ny*nun == size(states,1), 'input states are probably transposed');

    stats = struct();

    stats.E  = zeros(T,1); % energy
    stats.Z  = zeros(T,1); % enstrophy
    stats.PS = zeros(T,2); % plain vorticity points
    stats.ST = zeros(T,2); % plain streamfun points
    u  = zeros(nx*ny,T); % velocity x-dir
    v  = zeros(nx*ny,T); % velocity y-dir
    fullKe = zeros(nx*ny,T); % full eddy kinetic energy fields
    fullKm = zeros(nx*ny,T); % full mean kinetic energy fields

    if track_points
        % two points to look at variability
        i = floor(nx/4);
        j = 3*floor(ny/4);
        id_ps_1 = nun*(j*nx+i)+1;
        id_st_1 = nun*(j*nx+i);
        i = floor(nx/4);
        j = floor(ny/4);
        id_ps_2 = nun*(j*nx+i)+1;
        id_st_2 = nun*(j*nx+i);
    end

    for t = 1:T
        stats.Z(t) = self.compute_qg_enstrophy(scaling*states(:,t));
        stats.E(t) = self.compute_qg_energy(scaling*states(:,t));
        [u(:,t), v(:,t)] = qg.compute_uv(scaling*states(:,t));

        if track_points
            stats.PS(t,:) = scaling*states([id_ps_1, id_ps_2], t);
            stats.ST(t,:) = scaling*states([id_st_1, id_st_2], t);
        end
    end

    stats.Zvar  = zeros(T-wsize-1, 1);
    stats.Zmean = zeros(T-wsize-1, 1);
    stats.Evar  = zeros(T-wsize-1, 1);
    stats.Emean = zeros(T-wsize-1, 1);
    stats.Ke    = zeros(T-wsize-1, 1);
    stats.Km    = zeros(T-wsize-1, 1);

    if track_points
        stats.PSvar  = zeros(T-wsize-1, 2);
        stats.PSmean = zeros(T-wsize-1, 2);
        stats.STvar  = zeros(T-wsize-1, 2);
        stats.STmean = zeros(T-wsize-1, 2);
    end

    stats.dZdt = stats.Z(2:end) - stats.Z(1:end-1);
    stats.dEdt = stats.E(2:end) - stats.E(1:end-1);
    for t = 1:T-wsize-1
        window        = t:t+wsize;

        stats.Zvar(t)     = var(stats.Z(window));
        stats.Zmean(t)    = mean(stats.Z(window));
        stats.Evar(t)     = var(stats.E(window));
        stats.Emean(t)    = mean(stats.E(window));
        stats.dZdtvar(t)  = var(stats.dZdt(window));
        stats.dZdtmean(t) = mean(stats.dZdt(window));
        stats.dEdtvar(t)  = var(stats.dEdt(window));
        stats.dEdtmean(t) = mean(stats.dEdt(window));

        % Ke
        u2m = mean(u(:,window).^2,2);
        um2 = mean(u(:,window),2).^2;
        v2m = mean(v(:,window).^2,2);
        vm2 = mean(v(:,window),2).^2;

        fullKe(:,t) = (u2m - um2) + (v2m - vm2);
        stats.Ke(t) = sum( fullKe(:,t) );

        % Km
        fullKm(:,t) = um2 + vm2;
        stats.Km(t) = sum( fullKm(:,t) );

        if track_points
            stats.PSvar(t,:)  = var(stats.PS(window,:));
            stats.PSmean(t,:) = mean(stats.PS(window,:));
            stats.STvar(t,:)  = var(stats.ST(window,:));
            stats.STmean(t,:) = mean(stats.ST(window,:));
        end
    end
    fprintf(' computing statistics ... done (%f)\n', toc(time));
end