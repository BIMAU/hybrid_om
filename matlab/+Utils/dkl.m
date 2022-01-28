% Compute the Kullback-Leibler divergence of q from p. The bin range
% of p and q should be equal, which we cannot test here.
function [out] = dkl(p, q, use_eps)
    if use_eps
        % replace zeros with eps
        p(p == 0) = eps;
        q(q == 0) = eps;
    end
    N = size(q,2);

    assert( size(p,2) == 1, 'p should be column vector');
    assert( size(p,1) == size(q,1), ...
            'p and q should have same number of bins');

    % p and q should sum to 1
    assert( abs(1.0 - sum(p)) < 1e-11 , 'p not a pdf');
    for i = 1:N
        assert( abs(1.0 - sum(q(:,i))) < 1e-11 , 'q not a pdf');
    end

    if use_eps
        out = sum(p.*log(p./q));
    else
        out = nansum(p.*log(p./q));
    end
end