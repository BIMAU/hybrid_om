function [Pm, Pv] = get_qg_mean_spectrum(qg, states, opts)

    range = opts.trunc+1:opts.skip:opts.T;
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