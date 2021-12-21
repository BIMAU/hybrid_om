function [Pm, Pv] = get_qg_mean_spectrum(qg, states, opts)
    if nargin < 3
        range = 1:size(states,2);
        
    elseif isfield(opts, 'trunc') && ...
            isfield(opts, 'skip') && ...
            isfield(opts, 'T')

        range = opts.trunc+1:opts.skip:opts.T;
    else        
        error('bad range specification');        
    end

    maxr = Utils.get_maxr(qg.nx, qg.ny);
    Np = numel(range);
    P = zeros(maxr, Np);
    for i = 1:Np
        rPrf = Utils.get_qg_spectrum(qg, states(:,range(i)));
        P(:,i) = rPrf;
    end

    Pm = mean(P')';
    Pv = var(P')';
end