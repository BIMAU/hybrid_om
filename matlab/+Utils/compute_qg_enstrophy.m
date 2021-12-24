function [out] = compute_qg_enstrophy(field)
% assume QG ordering
    nun = 2;
    out = sum(field(1:nun:end).^2);
end
