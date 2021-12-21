function [maxr, midx, midy] = get_maxr(nx, ny)
% get largest radius used to obtain powerspectrum
    midx = nx/2+1;
    midy = ny/2+1;
    maxr = floor(sqrt(midx^2 + midy^2)) + 1;
end