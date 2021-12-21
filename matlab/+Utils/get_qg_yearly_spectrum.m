function [Pmean, Pvar] = get_qg_yearly_spectrum(qg, states)
% 
    if ~strcmp(qg.name, 'QGmodel');
        fprintf('This routine is only available for QG!\n');
        Pmean = 0;
        Pvar = 0;
        return;
    end

    [n, T] = size(states);
    assert(n == qg.nx*qg.ny*qg.nun, 'input data in wrong form');

    i_size = 365; % assuming dt = 1 day

    N_spectra = ceil(T / i_size);
    maxr = Utils.get_maxr(qg.nx, qg.ny);
    
    Pmean = zeros(maxr, N_spectra);
    Pvar = zeros(maxr, N_spectra);
    
    for i = 1:N_spectra
        interval = (i-1)*i_size+1:min(i_size*i,T);
        [Pm, Pv] = Utils.get_qg_mean_spectrum(qg, states(:,interval));
        Pmean(:,i) = Pm;
        Pvar(:,i) = Pv;
    end    
end