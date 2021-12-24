function [out] = compute_qg_energy(field)
% assume QG ordering
    nun = 2;
    out = sum(field(1:nun:end).*field(2:nun:end));
end
